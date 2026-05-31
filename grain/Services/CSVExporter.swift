import Foundation

/// Turns receipts into CSV and writes a temp `.csv` file for sharing.
///
/// Grain's value is granular, per–line-item data, so the CSV emits **one row per
/// line item**. A receipt with no items still emits a single row (item columns
/// blank) so it is never silently dropped from the export.
///
/// Output is locale-independent: money is rendered as plain decimal strings
/// (no currency symbol, no thousands separators) and dates as ISO `yyyy-MM-dd`,
/// which keeps the generated file stable across devices and testable.
enum CSVExporter {

    /// Column header, in emit order.
    static let header = "date,merchant,category,item,quantity,unit_price,line_total,receipt_total"

    // MARK: - CSV generation

    /// Builds the full CSV document (header + one row per line item) for the
    /// given receipts. Receipts with no items contribute one row with blank
    /// item columns.
    static func makeCSV(from receipts: [Receipt]) -> String {
        var lines: [String] = [header]

        for receipt in receipts {
            let date = isoDate(receipt.date)
            let merchant = receipt.merchantName
            let receiptTotal = decimalString(receipt.total)

            if receipt.items.isEmpty {
                lines.append(row(
                    date: date,
                    merchant: merchant,
                    category: receipt.category ?? "",
                    item: "",
                    quantity: "",
                    unitPrice: "",
                    lineTotal: "",
                    receiptTotal: receiptTotal
                ))
            } else {
                for item in receipt.items {
                    // Prefer the item's own category, fall back to the receipt's.
                    let category = item.category ?? receipt.category ?? ""
                    lines.append(row(
                        date: date,
                        merchant: merchant,
                        category: category,
                        item: item.name,
                        quantity: String(item.quantity),
                        unitPrice: decimalString(item.unitPrice),
                        lineTotal: decimalString(item.totalPrice),
                        receiptTotal: receiptTotal
                    ))
                }
            }
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - File writing

    /// Writes the CSV for `receipts` to a `.csv` file in the temporary directory
    /// and returns its URL.
    ///
    /// - Parameters:
    ///   - receipts: Receipts to export.
    ///   - fileName: File name (without extension). Defaults to a stable
    ///     `grain-export` so tests get a deterministic path; callers wanting a
    ///     unique file per export can pass a timestamped name.
    /// - Returns: URL of the written `.csv` file.
    @discardableResult
    static func writeCSV(from receipts: [Receipt], fileName: String = "grain-export") throws -> URL {
        let csv = makeCSV(from: receipts)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension("csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Row + field helpers

    private static func row(
        date: String,
        merchant: String,
        category: String,
        item: String,
        quantity: String,
        unitPrice: String,
        lineTotal: String,
        receiptTotal: String
    ) -> String {
        [
            date,
            merchant,
            category,
            item,
            quantity,
            unitPrice,
            lineTotal,
            receiptTotal
        ]
        .map(escape)
        .joined(separator: ",")
    }

    /// RFC 4180 escaping: a field containing a comma, double-quote, or newline
    /// is wrapped in double-quotes, and any internal double-quotes are doubled.
    static func escape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r") else {
            return field
        }
        let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    /// Plain, locale-independent decimal string for money values.
    /// e.g. `4.99`, `1234.5`, `0` — never `$4.99`, `4,99`, or `1,234.5`.
    static func decimalString(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).description(withLocale: nil)
    }

    /// Stable ISO `yyyy-MM-dd` date, independent of device locale/timezone settings.
    static func isoDate(_ date: Date) -> String {
        Self.isoFormatter.string(from: date)
    }

    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}
