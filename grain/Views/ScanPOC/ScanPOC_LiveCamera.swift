// ScanPOC_LiveCamera.swift
// POC 1: Live camera preview with real-time document edge detection
// Related: #21

import SwiftUI
import AVFoundation
import Vision

// MARK: - Camera Preview Layer

struct CameraPreviewLayer: UIViewRepresentable {
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

// MARK: - Camera Manager

@Observable
final class LiveCameraManager: NSObject {
    let session = AVCaptureSession()
    var detectedRectangle: VNRectangleObservation?
    var isAuthorized = false
    var capturedImage: UIImage?
    var confirmedFrames: [UIImage] = []

    private let videoOutput = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "grain.camera.processing")
    private let ciContext = CIContext()
    private var captureRequested = false

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

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        session.commitConfiguration()

        processingQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        processingQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func captureCurrentFrame() {
        captureRequested = true
    }
}

extension LiveCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Capture current frame if requested
        if captureRequested {
            captureRequested = false
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            if let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) {
                let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
                DispatchQueue.main.async { [weak self] in
                    self?.capturedImage = image
                }
            }
        }

        let request = VNDetectRectanglesRequest { [weak self] request, error in
            guard error == nil,
                  let results = request.results as? [VNRectangleObservation],
                  let bestRect = results.first else {
                DispatchQueue.main.async {
                    self?.detectedRectangle = nil
                }
                return
            }

            DispatchQueue.main.async {
                self?.detectedRectangle = bestRect
            }
        }

        request.minimumConfidence = 0.6
        request.maximumObservations = 1
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 1.0

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}

// MARK: - Edge Detection Overlay

struct EdgeDetectionOverlay: View {
    let rectangle: VNRectangleObservation?

    var body: some View {
        GeometryReader { geo in
            if let rect = rectangle {
                Path { path in
                    let tl = convertPoint(rect.topLeft, in: geo.size)
                    let tr = convertPoint(rect.topRight, in: geo.size)
                    let br = convertPoint(rect.bottomRight, in: geo.size)
                    let bl = convertPoint(rect.bottomLeft, in: geo.size)

                    path.move(to: tl)
                    path.addLine(to: tr)
                    path.addLine(to: br)
                    path.addLine(to: bl)
                    path.closeSubpath()
                }
                .stroke(Color.white, lineWidth: 1.5)
                .animation(.easeInOut(duration: 0.15), value: rect.topLeft.x)
            }
        }
    }

    private func convertPoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
        // Vision coordinates: origin bottom-left, normalized 0-1
        // SwiftUI coordinates: origin top-left
        CGPoint(
            x: point.x * size.width,
            y: (1 - point.y) * size.height
        )
    }
}

// MARK: - Live Camera View

struct ScanPOC_LiveCamera: View {
    @State private var cameraManager = LiveCameraManager()
    @State private var flashOn = false

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            if cameraManager.isAuthorized {
                cameraPreview
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
        .sheet(item: Binding(
            get: { cameraManager.capturedImage.map { CapturedImageItem(image: $0) } },
            set: { if $0 == nil { cameraManager.capturedImage = nil } }
        )) { item in
            CapturedImageSheet(image: item.image) {
                cameraManager.capturedImage = nil
            } onConfirm: {
                cameraManager.confirmedFrames.append(item.image)
                cameraManager.capturedImage = nil
            }
        }
    }

    // MARK: - Camera Preview

    private var cameraPreview: some View {
        ZStack {
            // Full-screen live camera
            CameraPreviewLayer(session: cameraManager.session)
                .ignoresSafeArea()

            // Edge detection overlay
            EdgeDetectionOverlay(rectangle: cameraManager.detectedRectangle)
                .ignoresSafeArea()

            // Top bar
            VStack {
                topBar
                Spacer()
                bottomControls
            }
        }
    }

    private var topBar: some View {
        HStack {
            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(cameraManager.detectedRectangle != nil ? Color.white : GrainTheme.textSecondary)
                    .frame(width: 6, height: 6)

                Text(cameraManager.detectedRectangle != nil ? "RECEIPT DETECTED" : "SCANNING")
                    .font(GrainTheme.mono(10))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // Flash toggle
            Button {
                flashOn.toggle()
                toggleFlash(flashOn)
            } label: {
                Image(systemName: flashOn ? "bolt.fill" : "bolt.slash")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Detection confidence bar
            if let rect = cameraManager.detectedRectangle {
                HStack(spacing: 4) {
                    Text("CONFIDENCE")
                        .font(GrainTheme.mono(9))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.5))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 2)

                            Rectangle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: geo.size.width * CGFloat(rect.confidence), height: 2)
                        }
                    }
                    .frame(height: 2)

                    Text(String(format: "%.0f%%", rect.confidence * 100))
                        .font(GrainTheme.mono(9))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: 260)
                .transition(.opacity)
            }

            // Capture button
            Button {
                cameraManager.captureCurrentFrame()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.9), lineWidth: 2)
                        .frame(width: 68, height: 68)

                    Circle()
                        .fill(Color.white.opacity(cameraManager.detectedRectangle != nil ? 0.95 : 0.3))
                        .frame(width: 56, height: 56)
                }
            }
            .padding(.bottom, 24)
        }
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

    // MARK: - Helpers

    private func toggleFlash(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
}

// MARK: - Captured Image Sheet

private struct CapturedImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct CapturedImageSheet: View {
    let image: UIImage
    let onDismiss: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("CAPTURED FRAME")
                        .font(GrainTheme.mono(11, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(GrainTheme.textPrimary)

                    Spacer()

                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(GrainTheme.textSecondary)
                            .frame(width: 32, height: 32)
                            .overlay(Rectangle().stroke(GrainTheme.border, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Rectangle()
                    .fill(GrainTheme.border)
                    .frame(height: 1)

                // Captured image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(20)

                Spacer()

                Rectangle()
                    .fill(GrainTheme.border)
                    .frame(height: 1)

                // Footer actions
                HStack(spacing: 12) {
                    Button {
                        onDismiss()
                    } label: {
                        Text("RETAKE")
                            .font(GrainTheme.mono(11))
                            .tracking(1)
                            .foregroundColor(GrainTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(Rectangle().stroke(GrainTheme.border, lineWidth: 1))
                    }

                    Button {
                        onConfirm()
                    } label: {
                        Text("USE PHOTO")
                            .font(GrainTheme.mono(11, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(GrainTheme.bg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(GrainTheme.textPrimary)
                    }
                }
                .padding(20)
            }
        }
    }
}

#Preview {
    ScanPOC_LiveCamera()
}
