import SwiftUI
import UIKit
import Vision

// MARK: - OCR Line Model

/// A single detected text line plus its Vision bounding box.
/// `boundingBox` is normalized (0–1) in Vision's coordinate space (origin bottom-left).
struct OCRLine: Identifiable {
    let id = UUID()
    let text: String
    let boundingBox: CGRect
}

/// Re-runs Vision text recognition on a saved receipt image to recover per-line geometry.
/// Line bounding boxes are not persisted on the model, so we recompute them on demand.
/// Lines are returned in reading order (top → bottom).
func recognizeLines(in image: UIImage) async -> [OCRLine] {
    guard let cgImage = image.cgImage else { return [] }

    return await withCheckedContinuation { continuation in
        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let lines: [OCRLine] = observations.compactMap { observation in
                guard let text = observation.topCandidates(1).first?.string else { return nil }
                return OCRLine(text: text, boundingBox: observation.boundingBox)
            }
            // Vision origin is bottom-left, so larger maxY == higher on the page.
            // Sort descending by maxY to get top → bottom reading order.
            let sorted = lines.sorted { $0.boundingBox.maxY > $1.boundingBox.maxY }
            continuation.resume(returning: sorted)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            continuation.resume(returning: [])
        }
    }
}

// MARK: - Split View

/// Full-screen "proof" view: digital OCR lines on top, the scanned image below.
/// Scrolling is locked between the two panes — a single `activeIndex` drives both,
/// and a translucent cursor tracks the focused line over the image.
struct ReceiptSplitView: View {
    let receipt: Receipt
    @Environment(\.dismiss) private var dismiss

    @State private var lines: [OCRLine] = []
    @State private var activeIndex: Int = 0
    @State private var scrollPositionID: Int?
    @State private var isLoading = true
    @State private var uiImage: UIImage?

    /// Lines sourced from re-running Vision (preferred — carries geometry) or, when there is
    /// no image, from the stored `ocrText` so demo/seeded receipts still render the top pane.
    private var displayLines: [OCRLine] {
        if !lines.isEmpty { return lines }
        return fallbackTextLines
    }

    /// Text-only lines (no geometry) parsed from the persisted OCR string.
    private var fallbackTextLines: [OCRLine] {
        (receipt.ocrText ?? "")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { OCRLine(text: $0, boundingBox: .zero) }
    }

    /// True only when we have real Vision geometry to drive the cursor.
    private var hasGeometry: Bool { !lines.isEmpty && uiImage != nil }

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if isLoading {
                    loadingState
                } else if displayLines.isEmpty && uiImage == nil {
                    emptyState
                } else {
                    GeometryReader { proxy in
                        let paneHeight = proxy.size.height / 2

                        VStack(spacing: 0) {
                            textPane
                                .frame(height: paneHeight)

                            Rectangle()
                                .fill(GrainTheme.border)
                                .frame(height: 1)

                            imagePane(paneHeight: paneHeight)
                                .frame(height: paneHeight)
                        }
                    }
                }
            }
        }
        .task {
            await loadLines()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("PROOF")
                .font(GrainTheme.mono(12, weight: .semibold))
                .tracking(2)
                .foregroundColor(GrainTheme.textPrimary)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("close")
                    .font(GrainTheme.mono(12))
                    .tracking(0.5)
                    .foregroundColor(GrainTheme.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
        }
    }

    // MARK: - Top Pane (digital OCR lines)

    private var textPane: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(displayLines.enumerated()), id: \.element.id) { index, line in
                    textRow(index: index, line: line)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPositionID, anchor: .center)
        .onChange(of: scrollPositionID) { _, newValue in
            // The scroll-position binding is the single source of truth for the focused line.
            // Both user scrolls and programmatic taps write to it, so there is no second
            // mechanism (ScrollViewReader) to oscillate against.
            if let newValue, newValue != activeIndex {
                activeIndex = newValue
            }
        }
    }

    private func textRow(index: Int, line: OCRLine) -> some View {
        let isActive = index == activeIndex
        return HStack(alignment: .top, spacing: 10) {
            Text(String(format: "%02d", index + 1))
                .font(GrainTheme.mono(10))
                .foregroundColor(isActive ? GrainTheme.accent : GrainTheme.textSecondary.opacity(0.6))

            Text(line.text)
                .font(GrainTheme.mono(12))
                .foregroundColor(isActive ? GrainTheme.textPrimary : GrainTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(isActive ? GrainTheme.accent.opacity(0.12) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            // Drive the scroll-position binding (which updates activeIndex via onChange) —
            // one mechanism, so there's no ScrollViewReader cross-talk / oscillation.
            withAnimation(.easeInOut(duration: 0.2)) {
                scrollPositionID = index
            }
        }
    }

    // MARK: - Bottom Pane (scanned image + cursor)

    @ViewBuilder
    private func imagePane(paneHeight: CGFloat) -> some View {
        if let image = uiImage {
            GeometryReader { geo in
                // Aspect-fit-to-WIDTH: the image fills the pane width and its height
                // is whatever the aspect ratio dictates (often taller than the pane).
                let displayedW = geo.size.width
                let aspect = image.size.height / max(image.size.width, 1)
                let displayedH = displayedW * aspect

                // Offset so the focused line's center sits at the vertical middle of the pane.
                let offsetY = focusedImageOffset(displayedH: displayedH, viewportH: geo.size.height)

                ZStack(alignment: .topLeading) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: displayedW, height: displayedH)

                    // Cursor: only when we have real Vision geometry for the active line.
                    if hasGeometry, lines.indices.contains(activeIndex) {
                        let box = lines[activeIndex].boundingBox
                        let viewY = (1 - box.maxY) * displayedH
                        let viewH = box.height * displayedH

                        GrainTheme.accent
                            .opacity(0.25)
                            .frame(width: displayedW, height: max(viewH, 2))
                            .offset(y: viewY)
                    }
                }
                .offset(y: offsetY)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                .clipped()
                .animation(.easeInOut(duration: 0.2), value: activeIndex)
            }
        } else {
            noImageState
        }
    }

    /// Vertical content offset that centers the focused line within the viewport,
    /// clamped so we never scroll past the top or bottom of the image.
    private func focusedImageOffset(displayedH: CGFloat, viewportH: CGFloat) -> CGFloat {
        // Only scroll the image when we have real Vision geometry to align to; otherwise keep
        // it static rather than implying a line correspondence that doesn't exist.
        guard hasGeometry, lines.indices.contains(activeIndex) else { return 0 }
        // If the image is shorter than the viewport, no scrolling needed.
        guard displayedH > viewportH else { return 0 }

        let box = lines[activeIndex].boundingBox
        let lineCenterY = (1 - box.midY) * displayedH

        // We want lineCenterY to land at viewportH/2 → offset = viewportH/2 - lineCenterY.
        let rawOffset = viewportH / 2 - lineCenterY
        let minOffset = viewportH - displayedH // most-negative (bottom of image)
        return min(0, max(minOffset, rawOffset))
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .tint(GrainTheme.textSecondary)
            Text("reading lines\u{2026}")
                .font(GrainTheme.mono(11))
                .tracking(0.5)
                .foregroundColor(GrainTheme.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("no detected text")
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textPrimary)
            Text("this receipt has no scan or ocr text")
                .font(GrainTheme.mono(10))
                .foregroundColor(GrainTheme.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noImageState: some View {
        ZStack {
            GrainTheme.surface
            VStack(spacing: 6) {
                Text("no scan image")
                    .font(GrainTheme.mono(11))
                    .foregroundColor(GrainTheme.textSecondary)
                Text("text only")
                    .font(GrainTheme.mono(9))
                    .tracking(1)
                    .foregroundColor(GrainTheme.textSecondary.opacity(0.6))
            }
        }
    }

    // MARK: - Loading

    private func loadLines() async {
        if let data = receipt.imageData, let image = UIImage(data: data) {
            uiImage = image
            lines = await recognizeLines(in: image)
        }
        isLoading = false
        // Seed explicit scroll state now that the line count is known.
        if !displayLines.isEmpty {
            activeIndex = min(activeIndex, displayLines.count - 1)
            scrollPositionID = activeIndex
        }
    }
}
