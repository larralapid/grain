import SwiftUI
import VisionKit
import UIKit

struct ReceiptScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var scannerService = ReceiptScannerService()
    @State private var isShowingCamera = false
    @State private var scannedReceipt: Receipt?
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false

    var body: some View {
        ZStack {
            (AppearanceManager.shared.isDarkMode
                ? Color(red: 0.067, green: 0.067, blue: 0.067)
                : Color(red: 0.949, green: 0.945, blue: 0.933))
                .ignoresSafeArea()

            if let scannedReceipt = scannedReceipt {
                proofSheet(scannedReceipt)
            } else {
                scannerInterface
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                processImage(image)
            }
        }
    }

    // MARK: - Scanner Interface (dark viewfinder)

    private var scannerInterface: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                // Viewfinder frame
                Rectangle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: 280, height: 400)

                if isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("POSITION RECEIPT IN FRAME")
                        .font(GrainTheme.mono(12))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            // Capture button
            Button {
                isShowingCamera = true
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.9), lineWidth: 3)
                        .frame(width: 68, height: 68)

                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 56, height: 56)
                }
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Proof Sheet (thermal receipt)

    private func proofSheet(_ receipt: Receipt) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                thermalReceipt(receipt)
                    .padding(.top, 24)

                // Save button
                Button {
                    saveReceipt(receipt)
                } label: {
                    Text("SAVE RECEIPT")
                        .font(GrainTheme.mono(12))
                        .tracking(1)
                        .foregroundColor(.white)
                        .frame(maxWidth: 300)
                        .padding(.vertical, 14)
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.top, 16)

                Button("edit before saving") {
                    // TODO: edit flow
                }
                .font(GrainTheme.mono(11))
                .foregroundColor(.white.opacity(0.4))
                .tracking(0.5)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
    }

    private func thermalReceipt(_ receipt: Receipt) -> some View {
        VStack(spacing: 0) {
            // Torn edge top
            thermalTornEdge

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 2) {
                    Text(receipt.merchantName.uppercased())
                        .font(GrainTheme.mono(14, weight: .semibold))
                        .tracking(0.8)
                        .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))

                    if let address = receipt.merchantAddress {
                        Text(address)
                            .font(GrainTheme.mono(9))
                            .foregroundColor(.gray)
                            .tracking(0.3)
                    }

                    Text(receipt.date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year() .hour().minute()))
                        .font(GrainTheme.mono(9))
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
                .padding(.bottom, 12)

                thermalDashedLine

                // Items
                ForEach(receipt.items, id: \.id) { item in
                    HStack {
                        Text(item.name.uppercased())
                            .font(GrainTheme.mono(11))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                        Spacer()
                        Text(item.totalPrice.formatted(.number.precision(.fractionLength(2))))
                            .font(GrainTheme.mono(11))
                            .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                    }
                    .padding(.vertical, 3)
                }

                thermalDashedLine

                // Totals
                thermalTotalRow("SUBTOTAL", amount: receipt.subtotal)
                thermalTotalRow("TAX", amount: receipt.tax)

                thermalDashedLine

                HStack {
                    Text("TOTAL")
                        .font(GrainTheme.mono(14, weight: .semibold))
                        .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                    Spacer()
                    Text(receipt.total.formatted(.number.precision(.fractionLength(2))))
                        .font(GrainTheme.mono(14, weight: .semibold))
                        .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                }
                .padding(.top, 6)

                // Footer
                VStack(spacing: 4) {
                    thermalDashedLine
                        .padding(.top, 10)

                    Text("THANK YOU FOR SHOPPING")
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
            .background(Color(red: 1, green: 0.996, blue: 0.973)) // #FFFEF8

            // Torn edge bottom
            thermalTornEdge
        }
        .frame(maxWidth: 300)
    }

    private var thermalTornEdge: some View {
        HStack(spacing: 2) {
            ForEach(0..<50, id: \.self) { i in
                Rectangle()
                    .fill(Color(red: 1, green: 0.996, blue: 0.973))
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

    private func thermalTotalRow(_ label: String, amount: Decimal) -> some View {
        HStack {
            Text(label)
                .font(GrainTheme.mono(11))
                .foregroundColor(.gray)
            Spacer()
            Text(amount.formatted(.number.precision(.fractionLength(2))))
                .font(GrainTheme.mono(11))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Actions

    private func processImage(_ image: UIImage) {
        isProcessing = true

        Task {
            let receipt = await scannerService.scanReceipt(from: image)

            await MainActor.run {
                self.scannedReceipt = receipt
                self.isProcessing = false
            }
        }
    }

    private func saveReceipt(_ receipt: Receipt) {
        modelContext.insert(receipt)

        do {
            try modelContext.save()
            scannedReceipt = nil
            selectedImage = nil
        } catch {
            print("Error saving receipt: \(error)")
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ReceiptScannerView()
        .modelContainer(for: [Receipt.self, ReceiptItem.self], inMemory: true)
}
