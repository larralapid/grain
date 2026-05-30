import Foundation
import UIKit

/// Structured result of extracting a receipt from OCR text (+ optional image).
/// A plain value type (iOS 17+) shared by every extractor tier so the tiers are
/// interchangeable and unit-testable without touching SwiftData, the network, or the model.
struct ExtractedReceipt: Codable, Equatable {
    var merchantName: String
    var merchantAddress: String?
    var date: Date?
    var subtotal: Decimal
    var tax: Decimal
    var total: Decimal
    var items: [ExtractedItem]
}

struct ExtractedItem: Codable, Equatable {
    var name: String
    var quantity: Int
    var unitPrice: Decimal
    var totalPrice: Decimal
    var brand: String?
    var category: String?
}

/// A strategy for turning OCR text (+ optional image) into a structured receipt.
/// Implementations: regex (universal fallback), on-device Foundation Models, cloud Claude.
protocol ReceiptExtractor {
    func extract(image: UIImage?, ocrText: String) async throws -> ExtractedReceipt
}

/// Identifies which tier produced an extraction (persisted on `Receipt.extractionSource`).
enum ExtractionSource: String {
    case regex
    case onDevice
    case claude
}

/// Universal fallback tier. Reuses the existing regex parser; always available (iOS 17+),
/// works offline, and never leaves the device.
struct RegexReceiptExtractor: ReceiptExtractor {
    func extract(image: UIImage?, ocrText: String) async throws -> ExtractedReceipt {
        // `ReceiptScannerService` is @MainActor; build + parse on the main actor, then map
        // the (detached) Receipt into the plain value type.
        await MainActor.run {
            let parsed = ReceiptScannerService().parseReceiptFromText(ocrText)
            return ExtractedReceipt(
                merchantName: parsed?.merchantName ?? "UNKNOWN",
                merchantAddress: parsed?.merchantAddress,
                date: parsed?.date,
                subtotal: parsed?.subtotal ?? 0,
                tax: parsed?.tax ?? 0,
                total: parsed?.total ?? 0,
                items: (parsed?.items ?? []).map { item in
                    ExtractedItem(
                        name: item.name,
                        quantity: item.quantity,
                        unitPrice: item.unitPrice,
                        totalPrice: item.totalPrice,
                        brand: item.brand,
                        category: item.category
                    )
                }
            )
        }
    }
}
