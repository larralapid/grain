// ScanPOC_GuidedCapture.swift
// POC 3: Guided capture with haptic feedback and auto-capture
// Related: #21

import SwiftUI
import AVFoundation
import Vision
import UIKit
import Observation

// MARK: - Capture State

enum GuidedCaptureState: Equatable {
    case searching
    case aligning
    case holdSteady(progress: Double)
    case captured

    var prompt: String {
        switch self {
        case .searching: return "ALIGN RECEIPT"
        case .aligning: return "ALIGN RECEIPT"
        case .holdSteady: return "HOLD STEADY"
        case .captured: return "CAPTURED"
        }
    }
}

// MARK: - Guided Camera Manager

@Observable
final class GuidedCameraManager: NSObject {
    let session = AVCaptureSession()
    var isAuthorized = false
    var captureState: GuidedCaptureState = .searching
    var detectedRectangle: VNRectangleObservation?
    var capturedImages: [UIImage] = []
    var errorMessage: String?
    var scanCount: Int { capturedImages.count }

    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private let processingQueue = DispatchQueue(label: "grain.guided.processing")
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    private let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let hapticNotification = UINotificationFeedbackGenerator()

    // Stability tracking
    private var stableFrameCount = 0
    private var lastRectCenter: CGPoint = .zero
    private let stabilityThreshold: CGFloat = 0.02
    private let requiredStableFrames = 45 // ~1.5s at 30fps
    private var isCapturing = false
    private var isConfigured = false

    func requestAccess() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        default:
            isAuthorized = false
        }
    }

    func startSession() {
        guard isAuthorized else { return }
        if isConfigured {
            processingQueue.async { [weak self] in
                guard let self, !self.session.isRunning else { return }
                self.session.startRunning()
            }
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            errorMessage = "No back camera is available on this device."
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input) else {
                session.commitConfiguration()
                errorMessage = "The camera input could not be attached."
                return
            }
            session.addInput(input)
        } catch {
            session.commitConfiguration()
            errorMessage = "The camera could not start: \(error.localizedDescription)"
            return
        }

        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true

        guard session.canAddOutput(videoOutput) else {
            session.commitConfiguration()
            errorMessage = "Live frame output is unavailable."
            return
        }
        session.addOutput(videoOutput)

        guard session.canAddOutput(photoOutput) else {
            session.commitConfiguration()
            errorMessage = "Still photo capture is unavailable."
            return
        }
        session.addOutput(photoOutput)

        session.commitConfiguration()
        isConfigured = true

        hapticImpact.prepare()
        hapticHeavy.prepare()

        processingQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        processingQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func manualCapture() {
        capturePhoto()
    }

    func resetForNextScan() {
        captureState = .searching
        stableFrameCount = 0
        isCapturing = false
    }

    private func capturePhoto() {
        guard !isCapturing else { return }
        isCapturing = true

        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func checkStability(for rect: VNRectangleObservation) {
        let center = CGPoint(
            x: (rect.topLeft.x + rect.bottomRight.x) / 2,
            y: (rect.topLeft.y + rect.bottomRight.y) / 2
        )

        let distance = hypot(center.x - lastRectCenter.x, center.y - lastRectCenter.y)
        lastRectCenter = center

        if distance < stabilityThreshold {
            stableFrameCount += 1

            let progress = Double(stableFrameCount) / Double(requiredStableFrames)

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if progress < 1.0 {
                    if self.stableFrameCount == 1 {
                        self.hapticImpact.impactOccurred()
                    }
                    self.captureState = .holdSteady(progress: min(progress, 1.0))
                } else if !self.isCapturing {
                    self.captureState = .captured
                    self.hapticHeavy.impactOccurred()
                    self.capturePhoto()
                }
            }
        } else {
            stableFrameCount = 0
            DispatchQueue.main.async { [weak self] in
                if case .holdSteady = self?.captureState {
                    self?.captureState = .aligning
                }
            }
        }
    }
}

extension GuidedCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard !isCapturing,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectRectanglesRequest { [weak self] request, error in
            if let error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Rectangle detection failed: \(error.localizedDescription)"
                }
                return
            }

            guard let results = request.results as? [VNRectangleObservation],
                  let bestRect = results.first else {
                DispatchQueue.main.async {
                    self?.detectedRectangle = nil
                    self?.captureState = .searching
                    self?.stableFrameCount = 0
                }
                return
            }

            DispatchQueue.main.async {
                self?.detectedRectangle = bestRect
                if self?.captureState == .searching {
                    self?.captureState = .aligning
                    self?.hapticImpact.impactOccurred()
                }
            }

            self?.checkStability(for: bestRect)
        }

        request.minimumConfidence = 0.6
        request.maximumObservations = 1
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 1.0

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Rectangle detection failed: \(error.localizedDescription)"
            }
        }
    }
}

extension GuidedCameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            DispatchQueue.main.async { [weak self] in
                self?.isCapturing = false
                self?.errorMessage = "Photo capture failed: \(error.localizedDescription)"
            }
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            DispatchQueue.main.async { [weak self] in
                self?.isCapturing = false
                self?.errorMessage = "Photo capture failed because the image data was unreadable."
            }
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.capturedImages.append(image)
            self?.hapticNotification.notificationOccurred(.success)

            // Brief delay before resetting for next scan
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self?.resetForNextScan()
            }
        }
    }
}

// MARK: - Guided Capture View

struct ScanPOC_GuidedCapture: View {
    @State private var cameraManager = GuidedCameraManager()

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            if cameraManager.isAuthorized {
                cameraInterface
            } else {
                permissionPrompt
            }
        }
        .task {
            await cameraManager.requestAccess()
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .alert("Scan error", isPresented: errorAlertIsPresented) {
            Button("OK") {
                cameraManager.errorMessage = nil
            }
        } message: {
            Text(cameraManager.errorMessage ?? "")
        }
    }

    private var errorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { cameraManager.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    cameraManager.errorMessage = nil
                }
            }
        )
    }

    // MARK: - Camera Interface

    private var cameraInterface: some View {
        ZStack {
            // Camera preview
            CameraPreviewRepresentable(session: cameraManager.session)
                .ignoresSafeArea()

            // Darkened border overlay
            guideFrame

            // Edge detection overlay
            if let rect = cameraManager.detectedRectangle {
                EdgeOverlay(rectangle: rect)
                    .ignoresSafeArea()
            }

            // UI layer
            VStack(spacing: 0) {
                promptBar
                Spacer()
                bottomPanel
            }
        }
    }

    // MARK: - Guide Frame

    private var guideFrame: some View {
        GeometryReader { geo in
            let frameWidth: CGFloat = geo.size.width - 48
            let frameHeight: CGFloat = frameWidth * 1.4
            let frameX: CGFloat = 24
            let frameY: CGFloat = (geo.size.height - frameHeight) / 2 - 40

            // Animated guide rectangle
            Rectangle()
                .stroke(
                    guideFrameColor,
                    lineWidth: guideFrameLineWidth
                )
                .frame(width: frameWidth, height: frameHeight)
                .position(x: geo.size.width / 2, y: frameY + frameHeight / 2)
                .animation(.easeInOut(duration: 0.3), value: cameraManager.captureState)

            // Corner markers
            ForEach(0..<4, id: \.self) { corner in
                cornerMarker(corner: corner, frameRect: CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight))
            }
        }
    }

    private var guideFrameColor: Color {
        switch cameraManager.captureState {
        case .searching:
            return Color.white.opacity(0.3)
        case .aligning:
            return Color.white.opacity(0.6)
        case .holdSteady:
            return Color.white.opacity(0.8)
        case .captured:
            return Color.white
        }
    }

    private var guideFrameLineWidth: CGFloat {
        switch cameraManager.captureState {
        case .captured: return 2.5
        default: return 1
        }
    }

    private func cornerMarker(corner: Int, frameRect: CGRect) -> some View {
        let length: CGFloat = 20
        let positions: [(CGFloat, CGFloat)] = [
            (frameRect.minX, frameRect.minY),
            (frameRect.maxX, frameRect.minY),
            (frameRect.maxX, frameRect.maxY),
            (frameRect.minX, frameRect.maxY),
        ]
        let pos = positions[corner]

        return Canvas { context, _ in
            var path = Path()
            switch corner {
            case 0: // top-left
                path.move(to: CGPoint(x: 0, y: length))
                path.addLine(to: .zero)
                path.addLine(to: CGPoint(x: length, y: 0))
            case 1: // top-right
                path.move(to: CGPoint(x: -length, y: 0))
                path.addLine(to: .zero)
                path.addLine(to: CGPoint(x: 0, y: length))
            case 2: // bottom-right
                path.move(to: CGPoint(x: 0, y: -length))
                path.addLine(to: .zero)
                path.addLine(to: CGPoint(x: -length, y: 0))
            case 3: // bottom-left
                path.move(to: CGPoint(x: length, y: 0))
                path.addLine(to: .zero)
                path.addLine(to: CGPoint(x: 0, y: -length))
            default: break
            }
            context.stroke(path, with: .color(guideFrameColor), lineWidth: 2)
        }
        .frame(width: length * 2, height: length * 2)
        .position(x: pos.0, y: pos.1)
    }

    // MARK: - Prompt Bar

    private var promptBar: some View {
        HStack {
            Spacer()

            VStack(spacing: 6) {
                Text(cameraManager.captureState.prompt)
                    .font(GrainTheme.mono(12, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: cameraManager.captureState.prompt)

                // Progress bar for hold steady state
                if case .holdSteady(let progress) = cameraManager.captureState {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 2)

                            Rectangle()
                                .fill(Color.white)
                                .frame(width: geo.size.width * progress, height: 2)
                                .animation(.linear(duration: 0.05), value: progress)
                        }
                    }
                    .frame(width: 120, height: 2)
                    .transition(.opacity)
                }
            }

            Spacer()
        }
        .padding(.top, 16)
    }

    // MARK: - Bottom Panel

    private var bottomPanel: some View {
        VStack(spacing: 16) {
            // Thumbnail strip
            if !cameraManager.capturedImages.isEmpty {
                thumbnailStrip
            }

            // Controls
            HStack(alignment: .center) {
                // Scan count badge
                if cameraManager.scanCount > 0 {
                    ZStack {
                        Rectangle()
                            .stroke(GrainTheme.border, lineWidth: 1)
                            .frame(width: 44, height: 44)

                        Text("\(cameraManager.scanCount)")
                            .font(GrainTheme.mono(14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }

                Spacer()

                // Manual capture button
                Button {
                    cameraManager.manualCapture()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.9), lineWidth: 2)
                            .frame(width: 68, height: 68)

                        Circle()
                            .fill(captureButtonFill)
                            .frame(width: 56, height: 56)
                            .scaleEffect(cameraManager.captureState == .captured ? 0.85 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: cameraManager.captureState)
                    }
                }

                Spacer()

                // Done button
                if cameraManager.scanCount > 0 {
                    Button {
                        // TODO: finish scanning, proceed to review
                    } label: {
                        Text("DONE")
                            .font(GrainTheme.mono(11, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }

    private var captureButtonFill: Color {
        switch cameraManager.captureState {
        case .searching:
            return .white.opacity(0.3)
        case .aligning:
            return .white.opacity(0.5)
        case .holdSteady(let progress):
            return .white.opacity(0.5 + progress * 0.4)
        case .captured:
            return .white.opacity(0.95)
        }
    }

    // MARK: - Thumbnail Strip

    private var thumbnailStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(cameraManager.capturedImages.enumerated()), id: \.offset) { index, image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 64)
                        .clipped()
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .overlay(alignment: .bottomTrailing) {
                            Text("\(index + 1)")
                                .font(GrainTheme.mono(8))
                                .foregroundColor(.white)
                                .padding(2)
                                .background(Color.black.opacity(0.6))
                        }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 72)
    }

    // MARK: - Permission Prompt

    private var permissionPrompt: some View {
        VStack(spacing: 16) {
            Text("CAMERA ACCESS REQUIRED")
                .font(GrainTheme.mono(12, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(GrainTheme.textPrimary)

            Text("grain needs camera access to scan receipts")
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button("OPEN SETTINGS") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(GrainTheme.mono(11))
            .tracking(1)
            .foregroundColor(GrainTheme.textPrimary)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .overlay(
                Rectangle()
                    .stroke(GrainTheme.border, lineWidth: 1)
            )
            .padding(.top, 8)
        }
    }
}

// MARK: - Camera Preview (reusable UIView wrapper)

private struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                layer.frame = uiView.bounds
            }
        }
    }
}

// MARK: - Edge Overlay (reusable)

private struct EdgeOverlay: View {
    let rectangle: VNRectangleObservation

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let tl = convert(rectangle.topLeft, in: geo.size)
                let tr = convert(rectangle.topRight, in: geo.size)
                let br = convert(rectangle.bottomRight, in: geo.size)
                let bl = convert(rectangle.bottomLeft, in: geo.size)

                path.move(to: tl)
                path.addLine(to: tr)
                path.addLine(to: br)
                path.addLine(to: bl)
                path.closeSubpath()
            }
            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
        }
    }

    private func convert(_ point: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: point.x * size.width, y: (1 - point.y) * size.height)
    }
}

#Preview {
    ScanPOC_GuidedCapture()
}
