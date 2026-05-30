import Foundation
import UIKit

/// Enhanced (opt-in) tier: sends the receipt image + Vision OCR text to the Anthropic
/// Messages API and uses *forced tool-use* to get a structured receipt back. Uses the
/// user's own API key (BYO) — never a Claude Pro/Max subscription, which Anthropic
/// prohibits in third-party apps. See ADR-0007.
struct ClaudeReceiptExtractor: ReceiptExtractor {
    let apiKey: String
    var model: String = "claude-sonnet-4-6"

    enum ExtractorError: LocalizedError {
        case noToolUse
        case http(Int, String)

        var errorDescription: String? {
            switch self {
            case .noToolUse:
                return "Claude did not return structured receipt data."
            case .http(let code, let body):
                return "Claude API error \(code): \(body.prefix(200))"
            }
        }
    }

    func extract(image: UIImage?, ocrText: String) async throws -> ExtractedReceipt {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody(image: image, ocrText: ocrText))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ExtractorError.http(-1, "no response")
        }
        guard (200..<300).contains(http.statusCode) else {
            throw ExtractorError.http(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        return try Self.parse(data)
    }

    // MARK: - Request

    private func requestBody(image: UIImage?, ocrText: String) -> [String: Any] {
        var userContent: [[String: Any]] = []
        if let image, let jpeg = image.jpegData(compressionQuality: 0.6) {
            userContent.append([
                "type": "image",
                "source": [
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": jpeg.base64EncodedString()
                ]
            ])
        }
        userContent.append([
            "type": "text",
            "text": "Extract the structured receipt. Vision OCR text follows; treat the image as the source of truth where they disagree.\n\n\(ocrText)"
        ])

        return [
            "model": model,
            "max_tokens": 2048,
            // cache_control on the static system prompt + tool schema → cheaper repeat calls.
            "system": [[
                "type": "text",
                "text": Self.systemPrompt,
                "cache_control": ["type": "ephemeral"]
            ]],
            "tools": [Self.recordReceiptTool],
            "tool_choice": ["type": "tool", "name": "record_receipt"],
            "messages": [[
                "role": "user",
                "content": userContent
            ]]
        ]
    }

    private static let systemPrompt = """
    You extract structured data from retail receipts. Return the merchant name, address if \
    present, the date (ISO 8601 if present), subtotal, tax, total, and every line item with its \
    name, quantity, unit price, and total price. Use plain numbers without currency symbols. If a \
    value is missing, use 0 or omit the optional field.
    """

    private static let recordReceiptTool: [String: Any] = [
        "name": "record_receipt",
        "description": "Record the structured contents of a scanned receipt.",
        "input_schema": [
            "type": "object",
            "properties": [
                "merchantName": ["type": "string"],
                "merchantAddress": ["type": "string"],
                "date": ["type": "string", "description": "ISO 8601 date if present"],
                "subtotal": ["type": "number"],
                "tax": ["type": "number"],
                "total": ["type": "number"],
                "items": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "name": ["type": "string"],
                            "quantity": ["type": "integer"],
                            "unitPrice": ["type": "number"],
                            "totalPrice": ["type": "number"],
                            "brand": ["type": "string"],
                            "category": ["type": "string"]
                        ],
                        "required": ["name", "quantity", "unitPrice", "totalPrice"]
                    ]
                ]
            ],
            "required": ["merchantName", "subtotal", "tax", "total", "items"]
        ]
    ]

    // MARK: - Response

    static func parse(_ data: Data) throws -> ExtractedReceipt {
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = root["content"] as? [[String: Any]],
            let toolUse = content.first(where: { ($0["type"] as? String) == "tool_use" }),
            let input = toolUse["input"] as? [String: Any]
        else {
            throw ExtractorError.noToolUse
        }

        return ExtractedReceipt(
            merchantName: input["merchantName"] as? String ?? "UNKNOWN",
            merchantAddress: input["merchantAddress"] as? String,
            date: (input["date"] as? String).flatMap(Self.parseDate),
            subtotal: decimal(input["subtotal"]),
            tax: decimal(input["tax"]),
            total: decimal(input["total"]),
            items: (input["items"] as? [[String: Any]] ?? []).map { item in
                ExtractedItem(
                    name: item["name"] as? String ?? "",
                    quantity: (item["quantity"] as? NSNumber)?.intValue ?? 1,
                    unitPrice: decimal(item["unitPrice"]),
                    totalPrice: decimal(item["totalPrice"]),
                    brand: item["brand"] as? String,
                    category: item["category"] as? String
                )
            }
        )
    }

    /// JSON numbers arrive as `NSNumber`; route through their string form to avoid binary
    /// floating-point drift on currency values.
    private static func decimal(_ value: Any?) -> Decimal {
        if let n = value as? NSNumber { return Decimal(string: n.stringValue) ?? 0 }
        if let s = value as? String { return Decimal(string: s) ?? 0 }
        return 0
    }

    private static func parseDate(_ string: String) -> Date? {
        if let d = ISO8601DateFormatter().date(from: string) { return d }
        let df = DateFormatter()
        for fmt in ["yyyy-MM-dd", "MM/dd/yyyy", "MM-dd-yyyy"] {
            df.dateFormat = fmt
            if let d = df.date(from: string) { return d }
        }
        return nil
    }
}
