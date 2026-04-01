import Foundation
import Vision
import VisionKit
import UIKit

@MainActor
class ReceiptScannerService: ObservableObject {
    @Published var isScanning = false
    @Published var scannedText = ""
    @Published var lastError: Error?
    
    func scanReceipt(from image: UIImage) async -> Receipt? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        var recognizedTextResult: String? = nil
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                // Store error via main actor since service is main-actor isolated
                Task { @MainActor in
                    self?.lastError = error
                }
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            recognizedTextResult = recognizedText
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            let text = recognizedTextResult ?? ""
            // Update published property on the main actor
            self.scannedText = text
            return parseReceiptFromText(text)
        } catch {
            self.lastError = error
            return nil
        }
    }
    
    nonisolated private func parseReceiptFromText(_ text: String) -> Receipt? {
        let lines = text.components(separatedBy: .newlines)
        var merchantName = ""
        var total: Decimal = 0
        var subtotal: Decimal = 0
        var tax: Decimal = 0
        var items: [ReceiptItem] = []
        var date = Date()
        
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespaces)
            
            if cleanLine.isEmpty { continue }
            
            if merchantName.isEmpty && !cleanLine.contains("$") && !cleanLine.contains("TOTAL") {
                merchantName = cleanLine
            }
            
            if cleanLine.uppercased().contains("TOTAL") {
                if let amount = extractAmount(from: cleanLine) {
                    total = amount
                }
            }
            
            if cleanLine.uppercased().contains("SUBTOTAL") {
                if let amount = extractAmount(from: cleanLine) {
                    subtotal = amount
                }
            }
            
            if cleanLine.uppercased().contains("TAX") {
                if let amount = extractAmount(from: cleanLine) {
                    tax = amount
                }
            }
            
            if let extractedDate = extractDate(from: cleanLine) {
                date = extractedDate
            }
            
            if let item = parseReceiptItem(from: cleanLine) {
                items.append(item)
            }
        }
        
        if merchantName.isEmpty {
            merchantName = "Unknown Merchant"
        }
        
        let receipt = Receipt(
            date: date,
            merchantName: merchantName,
            total: total,
            subtotal: subtotal,
            tax: tax,
            ocrText: text
        )
        
        receipt.items = items
        return receipt
    }
    
    nonisolated private func extractAmount(from text: String) -> Decimal? {
        let pattern = #"\$?(\d+\.\d{2})"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }
        
        return Decimal(string: String(text[range]))
    }
    
    nonisolated private func extractDate(from text: String) -> Date? {
        let dateFormatter = DateFormatter()
        let patterns = [
            "MM/dd/yyyy",
            "MM-dd-yyyy",
            "yyyy-MM-dd",
            "dd/MM/yyyy",
            "MMM dd, yyyy"
        ]
        
        for pattern in patterns {
            dateFormatter.dateFormat = pattern
            if let date = dateFormatter.date(from: text) {
                return date
            }
        }
        
        return nil
    }
    
    nonisolated private func parseReceiptItem(from text: String) -> ReceiptItem? {
        let cleanLine = text.trimmingCharacters(in: .whitespaces)
        
        if cleanLine.uppercased().contains("TOTAL") ||
           cleanLine.uppercased().contains("SUBTOTAL") ||
           cleanLine.uppercased().contains("TAX") ||
           cleanLine.uppercased().contains("CHANGE") {
            return nil
        }
        
        guard let amount = extractAmount(from: cleanLine) else {
            return nil
        }
        
        let components = cleanLine.components(separatedBy: " ")
        guard components.count > 1 else {
            return nil
        }
        
        let nameComponents = components.dropLast()
        let itemName = nameComponents.joined(separator: " ")
        
        return ReceiptItem(
            name: itemName,
            quantity: 1,
            unitPrice: amount,
            totalPrice: amount
        )
    }
}
