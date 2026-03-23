// ScanPOC_DocumentScanner.swift
// POC 2: VisionKit Document Scanner wrapper with post-scan review
// Related: #21

import SwiftUI
import UIKit
import Observation
import VisionKit
import Vision
import PhotosUI

// MARK: - Document Scanner Coordinator

struct DocumentScannerSheet: UIViewControllerRepresentable {
    @Binding var scannedPages: [UIImage]
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerSheet

        init(_ parent: DocumentScannerSheet) {
            self.parent = parent
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            var pages: [UIImage] = []
            for i in 0..<scan.pageCount {
                pages.append(scan.imageOfPage(at: i))
            }
            parent.scannedPages = pages
            parent.dismiss()
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            parent.dismiss()
        }
    }
}

// MARK: - OCR Processing

@Observable
final class DocumentScanProcessor {
    var ocrText: String = ""
    var isProcessing = false
    var merchantName = ""
    var total = ""
    var itemCount = 0

    func processPages(_ pages: [UIImage]) async {
        isProcessing = true
        var allText = ""

        for page in pages {
            guard let cgImage = page.cgImage else { continue }

            let text = await withCheckedContinuation { continuation in
                let request = VNRecognizeTextRequest { request, _ in
                    let observations = request.results as? [VNRecognizedTextObservation] ?? []
                    let pageText = observations
                        .compactMap { $0.topCandidates(1).first?.string }
                        .joined(separator: "\n")
                    continuation.resume(returning: pageText)
                }
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true

                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    // If the handler throws, the request's completion handler will never be called.
                    // Ensure the continuation is still resumed to avoid hanging.
                    continuation.resume(returning: "")
                }
            }

            allText += text + "\n---\n"
        }

        ocrText = allText
        parseBasicFields(from: allText)
        isProcessing = false
    }

    private func parseBasicFields(from text: String) {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // First non-empty, non-numeric line as merchant
        merchantName = lines.first(where: { line in
            !line.contains("$") && !line.contains("TOTAL") && !line.allSatisfy(\.isNumber)
        }) ?? "UNKNOWN"

        // Find total
        for line in lines {
            if line.uppercased().contains("TOTAL") && !line.uppercased().contains("SUB") {
                let pattern = #"\$?(\d+\.\d{2})"#
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                   let range = Range(match.range(at: 0), in: line) {
                    total = String(line[range])
                }
            }
        }

        // Count lines with prices as rough item count
        let pricePattern = #"\$?\d+\.\d{2}"#
        let priceRegex = try? NSRegularExpression(pattern: pricePattern)
        itemCount = lines.filter { line in
            let isTotal = line.uppercased().contains("TOTAL") || line.uppercased().contains("TAX") || line.uppercased().contains("CHANGE")
            let hasPrice = (priceRegex?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line))) != nil
            return hasPrice && !isTotal
        }.count
    }
}

// MARK: - Document Scanner View

struct ScanPOC_DocumentScanner: View {
    @State private var isShowingScanner = false
    @State private var scannedPages: [UIImage] = []
    @State private var selectedPageIndex: Int = 0
    @State private var processor = DocumentScanProcessor()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showProofSheet = false

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            if scannedPages.isEmpty {
                emptyState
            } else {
                scannedContent
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            DocumentScannerSheet(scannedPages: $scannedPages)
        }
        .onChange(of: scannedPages) { _, pages in
            guard !pages.isEmpty else { return }
            Task {
                await processor.processPages(pages)
                showProofSheet = true
            }
        }
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    scannedPages = [image]
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("DOCUMENT SCANNER")
                    .font(GrainTheme.mono(14, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(GrainTheme.textPrimary)

                Text("auto edge detection + perspective correction")
                    .font(GrainTheme.mono(10))
                    .foregroundColor(GrainTheme.textSecondary)
                    .tracking(0.5)
            }

            VStack(spacing: 12) {
                // Camera scan button
                Button {
                    isShowingScanner = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.viewfinder")
                            .font(.system(size: 14))
                        Text("SCAN RECEIPT")
                            .font(GrainTheme.mono(12))
                            .tracking(1)
                    }
                    .foregroundColor(GrainTheme.textPrimary)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 14)
                    .overlay(
                        Rectangle()
                            .stroke(GrainTheme.border, lineWidth: 1)
                    )
                }

                // Gallery import
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 14))
                        Text("IMPORT FROM GALLERY")
                            .font(GrainTheme.mono(12))
                            .tracking(1)
                    }
                    .foregroundColor(GrainTheme.textSecondary)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 14)
                    .overlay(
                        Rectangle()
                            .stroke(GrainTheme.border.opacity(0.5), lineWidth: 1)
                    )
                }
            }

            Spacer()

            // Batch scan hint
            Text("supports multi-page batch scanning")
                .font(GrainTheme.mono(9))
                .foregroundColor(GrainTheme.textSecondary.opacity(0.6))
                .tracking(0.5)
                .padding(.bottom, 32)
        }
    }

    // MARK: - Scanned Content

    private var scannedContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    scannedPages = []
                    showProofSheet = false
                    processor = DocumentScanProcessor()
                } label: {
                    Text("DISCARD")
                        .font(GrainTheme.mono(10))
                        .tracking(1)
                        .foregroundColor(GrainTheme.textSecondary)
                }

                Spacer()

                Text("\(scannedPages.count) PAGE\(scannedPages.count == 1 ? "" : "S") SCANNED")
                    .font(GrainTheme.mono(10, weight: .semibold))
                    .tracking(1)
                    .foregroundColor(GrainTheme.textPrimary)

                Spacer()

                Button {
                    isShowingScanner = true
                } label: {
                    Text("+ ADD")
                        .font(GrainTheme.mono(10))
                        .tracking(1)
                        .foregroundColor(GrainTheme.accent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Horizontal page strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(scannedPages.enumerated()), id: \.offset) { index, page in
                        Button {
                            selectedPageIndex = index
                        } label: {
                            Image(uiImage: page)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 64, height: 88)
                                .clipped()
                                .overlay(
                                    Rectangle()
                                        .stroke(
                                            index == selectedPageIndex
                                                ? Color.white
                                                : GrainTheme.border,
                                            lineWidth: index == selectedPageIndex ? 2 : 1
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 96)

            Divider()
                .background(GrainTheme.border)

            // Main content: proof sheet or processing
            if processor.isProcessing {
                processingView
            } else if showProofSheet {
                proofSheetView
            }
        }
    }

    // MARK: - Processing

    private var processingView: some View {
        VStack(spacing: 16) {
            Spacer()

            ProgressView()
                .tint(GrainTheme.textSecondary)

            Text("PROCESSING OCR...")
                .font(GrainTheme.mono(10))
                .tracking(1.5)
                .foregroundColor(GrainTheme.textSecondary)

            Spacer()
        }
    }

    // MARK: - Proof Sheet (Thermal Receipt)

    private var proofSheetView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Thermal receipt card
                VStack(spacing: 0) {
                    thermalTornEdge

                    VStack(spacing: 0) {
                        // Header
                        Text(processor.merchantName.uppercased())
                            .font(GrainTheme.mono(14, weight: .semibold))
                            .tracking(0.8)
                            .foregroundColor(GrainTheme.textPrimary)
                            .padding(.bottom, 4)

                        Text(Date.now.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year() .hour().minute()))
                            .font(GrainTheme.mono(9))
                            .foregroundColor(.gray)
                            .tracking(0.3)
                            .padding(.bottom, 12)

                        thermalDashedLine

                        // Summary
                        HStack {
                            Text("ITEMS DETECTED")
                                .font(GrainTheme.mono(11))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(processor.itemCount)")
                                .font(GrainTheme.mono(11))
                                .foregroundColor(GrainTheme.textPrimary)
                        }
                        .padding(.vertical, 4)

                        HStack {
                            Text("PAGES")
                                .font(GrainTheme.mono(11))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(scannedPages.count)")
                                .font(GrainTheme.mono(11))
                                .foregroundColor(GrainTheme.textPrimary)
                        }
                        .padding(.vertical, 4)

                        thermalDashedLine

                        if !processor.total.isEmpty {
                            HStack {
                                Text("TOTAL")
                                    .font(GrainTheme.mono(14, weight: .semibold))
                                    .foregroundColor(GrainTheme.textPrimary)
                                Spacer()
                                Text(processor.total)
                                    .font(GrainTheme.mono(14, weight: .semibold))
                                    .foregroundColor(GrainTheme.textPrimary)
                            }
                            .padding(.top, 6)
                        }

                        // Footer
                        VStack(spacing: 4) {
                            thermalDashedLine
                                .padding(.top, 10)

                            Text("SCANNED BY GRAIN")
                                .font(GrainTheme.mono(8))
                                .foregroundColor(.gray.opacity(0.6))
                                .tracking(1)

                            Text("||||| |||| ||||| |||| |||||")
                                .font(GrainTheme.mono(7))
                                .foregroundColor(.gray.opacity(0.3))
                                .tracking(3)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(GrainTheme.surface)

                    thermalTornEdge
                }
                .frame(maxWidth: 300)
                .padding(.top, 24)

                // Action buttons
                Button {
                    // TODO: save receipt
                } label: {
                    Text("SAVE RECEIPT")
                        .font(GrainTheme.mono(12))
                        .tracking(1)
                        .foregroundColor(GrainTheme.textPrimary)
                        .frame(maxWidth: 300)
                        .padding(.vertical, 14)
                        .overlay(
                            Rectangle()
                                .stroke(GrainTheme.border, lineWidth: 1)
                        )
                }
                .padding(.top, 16)

                Button("rescan") {
                    scannedPages = []
                    showProofSheet = false
                    processor = DocumentScanProcessor()
                    isShowingScanner = true
                }
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.textSecondary)
                .tracking(0.5)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Thermal Receipt Helpers

    private var thermalTornEdge: some View {
        HStack(spacing: 2) {
            ForEach(0..<50, id: \.self) { _ in
                Rectangle()
                    .fill(GrainTheme.surface)
                    .frame(width: 4, height: 8)
            }
        }
        .frame(maxWidth: 300)
    }

    private var thermalDashedLine: some View {
        Rectangle()
            .fill(.clear)
            .frame(height: 1)
            .overlay(
                GeometryReader { geo in
                    Path { path in
                        let width = geo.size.width
                        var x: CGFloat = 0
                        while x < width {
                            path.move(to: CGPoint(x: x, y: 0.5))
                            path.addLine(to: CGPoint(x: min(x + 4, width), y: 0.5))
                            x += 8
                        }
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .padding(.vertical, 8)
    }
}

#Preview {
    ScanPOC_DocumentScanner()
}
