import Foundation
import UIKit

/// Picks the best available extraction tier per user settings + on-device availability,
/// runs it, and falls back to the regex parser on any failure so a scan always saves.
enum ExtractorCoordinator {

    static func selectExtractor() -> (source: ExtractionSource, extractor: ReceiptExtractor) {
        // Enhanced tier: opt-in + user-supplied key.
        if AIConfig.aiEnabled, AIConfig.claudeEnabled,
           let key = AIConfig.claudeAPIKey, !key.isEmpty {
            return (.claude, ClaudeReceiptExtractor(apiKey: key, model: AIConfig.claudeModel))
        }
        // Baseline tier: on-device Foundation Models when available.
        if AIConfig.aiEnabled, #available(iOS 26.0, *), OnDeviceReceiptExtractor.isAvailable {
            return (.onDevice, OnDeviceReceiptExtractor())
        }
        // Universal fallback.
        return (.regex, RegexReceiptExtractor())
    }

    static func extract(image: UIImage?, ocrText: String) async -> (source: ExtractionSource, receipt: ExtractedReceipt) {
        let (source, extractor) = selectExtractor()
        do {
            return (source, try await extractor.extract(image: image, ocrText: ocrText))
        } catch {
            // Network/model failure → regex fallback (never throws) so the save still happens.
            let regex = (try? await RegexReceiptExtractor().extract(image: image, ocrText: ocrText))
                ?? ExtractedReceipt(merchantName: "UNKNOWN", merchantAddress: nil, date: nil, subtotal: 0, tax: 0, total: 0, items: [])
            return (.regex, regex)
        }
    }
}

extension ExtractedReceipt {
    /// Builds a SwiftData `Receipt` (with items) from this extraction, tagging the producing
    /// tier and stashing the raw extraction JSON for the correction/eval corpus. The caller
    /// inserts + saves (mirroring DemoDataSeeder).
    func makeReceipt(imageData: Data?, source: ExtractionSource, ocrText: String) -> Receipt {
        let receipt = Receipt(
            date: date ?? .now,
            merchantName: merchantName.isEmpty ? "UNKNOWN" : merchantName,
            merchantAddress: merchantAddress,
            total: total,
            subtotal: subtotal,
            tax: tax,
            imageData: imageData,
            ocrText: ocrText
        )
        receipt.extractionSource = source.rawValue
        receipt.originalExtractionJSON = jsonString()

        receipt.items = items.map { item in
            let receiptItem = ReceiptItem(
                name: item.name,
                brand: item.brand,
                category: item.category,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                totalPrice: item.totalPrice
            )
            receiptItem.receipt = receipt
            return receiptItem
        }
        return receipt
    }

    /// JSON snapshot of the raw extraction, persisted so a later user correction can be
    /// diffed against it (the eval/regression corpus).
    func jsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
