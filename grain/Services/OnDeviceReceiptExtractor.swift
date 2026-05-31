import Foundation
import UIKit
import FoundationModels

/// Baseline (default) tier on iOS 26 + Apple Intelligence: structured extraction via the
/// on-device Foundation Models LLM with guided generation. No key, no cost, fully private —
/// nothing leaves the device. Availability-gated; the coordinator falls back to regex when
/// the model is unavailable (older OS, unsupported device, or Apple Intelligence off).
@available(iOS 26.0, *)
struct OnDeviceReceiptExtractor: ReceiptExtractor {

    static var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available: return true
        case .unavailable: return false
        }
    }

    func extract(image: UIImage?, ocrText: String) async throws -> ExtractedReceipt {
        let session = LanguageModelSession()
        let prompt = """
        You extract structured data from retail receipts. Use plain numbers without currency \
        symbols; if a value is missing use 0. Extract the receipt from this OCR text:

        \(ocrText)
        """
        let response = try await session.respond(to: Prompt(prompt), generating: GenerableReceipt.self)
        return response.content.toExtractedReceipt()
    }
}

@available(iOS 26.0, *)
@Generable
struct GenerableReceipt {
    @Guide(description: "The store or merchant name")
    let merchantName: String
    @Guide(description: "Store address if present, else empty")
    let merchantAddress: String
    @Guide(description: "Subtotal before tax, as a plain number")
    let subtotal: Double
    @Guide(description: "Tax amount, as a plain number")
    let tax: Double
    @Guide(description: "Grand total, as a plain number")
    let total: Double
    @Guide(description: "Every line item on the receipt")
    let items: [GenerableItem]
}

@available(iOS 26.0, *)
@Generable
struct GenerableItem {
    @Guide(description: "Item name")
    let name: String
    @Guide(description: "Quantity purchased")
    let quantity: Int
    @Guide(description: "Price per unit, as a plain number")
    let unitPrice: Double
    @Guide(description: "Total price for this line, as a plain number")
    let totalPrice: Double
}

@available(iOS 26.0, *)
private extension GenerableReceipt {
    func toExtractedReceipt() -> ExtractedReceipt {
        ExtractedReceipt(
            merchantName: merchantName.isEmpty ? "UNKNOWN" : merchantName,
            merchantAddress: merchantAddress.isEmpty ? nil : merchantAddress,
            date: nil,
            subtotal: Self.dec(subtotal),
            tax: Self.dec(tax),
            total: Self.dec(total),
            items: items.map { item in
                ExtractedItem(
                    name: item.name,
                    quantity: item.quantity,
                    unitPrice: Self.dec(item.unitPrice),
                    totalPrice: Self.dec(item.totalPrice),
                    brand: nil,
                    category: nil
                )
            }
        )
    }

    /// Route Double → Decimal through its string form to avoid floating-point drift on money.
    static func dec(_ value: Double) -> Decimal {
        Decimal(string: "\(value)") ?? 0
    }
}
