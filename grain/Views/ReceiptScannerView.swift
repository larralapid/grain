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
        NavigationView {
            VStack(spacing: 20) {
                if let scannedReceipt = scannedReceipt {
                    ReceiptPreviewView(receipt: scannedReceipt) {
                        saveReceipt(scannedReceipt)
                    }
                } else {
                    scannerInterface
                }
            }
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingCamera) {
                CameraView(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { _, newImage in
                if let image = newImage {
                    processImage(image)
                }
            }
        }
    }
    
    private var scannerInterface: some View {
        VStack(spacing: 30) {
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Scan Your Receipt")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Take a photo of your receipt to automatically extract items and prices")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if isProcessing {
                ProgressView("Processing receipt...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button("Take Photo") {
                    isShowingCamera = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding()
    }
    
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

struct ReceiptPreviewView: View {
    let receipt: Receipt
    let onSave: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                
                itemsList
                
                totals
                
                actionButtons
            }
            .padding()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(receipt.merchantName)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(receipt.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var itemsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Items")
                .font(.headline)
            
            ForEach(receipt.items, id: \.id) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.body)
                        if let brand = item.brand {
                            Text(brand)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(item.totalPrice.formatted(.currency(code: "USD")))
                        .font(.body)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var totals: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                Text("Subtotal")
                Spacer()
                Text(receipt.subtotal.formatted(.currency(code: "USD")))
            }
            
            HStack {
                Text("Tax")
                Spacer()
                Text(receipt.tax.formatted(.currency(code: "USD")))
            }
            
            HStack {
                Text("Total")
                    .fontWeight(.bold)
                Spacer()
                Text(receipt.total.formatted(.currency(code: "USD")))
                    .fontWeight(.bold)
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button("Edit") {
                // TODO: Implement edit functionality
            }
            .buttonStyle(.bordered)
            
            Button("Save Receipt") {
                onSave()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top)
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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