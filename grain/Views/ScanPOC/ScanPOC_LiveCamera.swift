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
    var errorMessage: String?

    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private let processingQueue = DispatchQueue(label: "grain.camera.processing")
    private var isConfigured = false
    private var isCapturing = false

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
            startRunning()
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
        startRunning()
    }

    func stopSession() {
        processingQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func captureCurrentFrame() {
        guard !isCapturing else { return }
        isCapturing = true

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func clearCapture() {
        capturedImage = nil
        isCapturing = false
    }

    private func startRunning() {
        processingQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }
}

extension LiveCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard !isCapturing,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectRectanglesRequest { [weak self] request, error in
            guard let self else { return }

            if let error {
                DispatchQueue.main.async {
                    self.errorMessage = "Rectangle detection failed: \(error.localizedDescription)"
                }
                return
            }

            guard let results = request.results as? [VNRectangleObservation],
                  let bestRect = results.first else {
                DispatchQueue.main.async {
                    self.detectedRectangle = nil
                }
                return
            }

            DispatchQueue.main.async {
                self.detectedRectangle = bestRect
            }
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

extension LiveCameraManager: AVCapturePhotoCaptureDelegate {
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
            self?.capturedImage = image
            self?.isCapturing = false
        }
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

    // MARK: - Camera Preview

    private var cameraPreview: some View {
        ZStack {
            CameraPreviewLayer(session: cameraManager.session)
                .ignoresSafeArea()

            EdgeDetectionOverlay(rectangle: cameraManager.detectedRectangle)
                .ignoresSafeArea()

            VStack {
                topBar
                Spacer()
                bottomControls
            }
        }
    }

    private var topBar: some View {
        HStack {
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
            .disabled(cameraManager.capturedImage != nil)
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
              device.hasTorch else {
            cameraManager.errorMessage = "This device does not support flash."
            return
        }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            cameraManager.errorMessage = "Flash could not be updated: \(error.localizedDescription)"
        }
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
