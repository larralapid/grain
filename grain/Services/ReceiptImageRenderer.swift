import SwiftUI
import UIKit

/// Renders a `Receipt` to a thermal-receipt-style JPEG off-screen via `ImageRenderer`.
///
/// Seeded demo receipts have no scanned image, so the proof / split / scan-overlay views fall flat
/// for demo data. This gives each one a realistic image — and because the render is clean
/// monospace black-on-white, Vision can re-OCR it, so `ReceiptSplitView`'s line cursor works too.
/// No bundled assets (keeps ADR-0003's zero-dependency / on-device stance).
@MainActor
enum ReceiptImageRenderer {
    /// JPEG of the receipt as a thermal slip, or `nil` if rendering fails.
    static func thermalJPEG(for receipt: Receipt, compressionQuality: CGFloat = 0.8) -> Data? {
        let renderer = ImageRenderer(content: ThermalReceiptCard(receipt: receipt))
        renderer.scale = 2.0   // crisp enough for Vision to re-recognize the lines
        return renderer.uiImage?.jpegData(compressionQuality: compressionQuality)
    }
}

/// Thermal-slip layout used *only* for off-screen rendering (never shown in the live UI), so the
/// white-paper / black-ink colors are intentionally literal — they represent a physical receipt,
/// not themed app chrome, and must not follow `GrainTheme`'s dark/light mode.
private struct ThermalReceiptCard: View {
    let receipt: Receipt

    private let paperWidth: CGFloat = 360

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 4) {
                Text(receipt.merchantName.uppercased())
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                if let address = receipt.merchantAddress, !address.isEmpty {
                    Text(address)
                        .font(.system(size: 11, design: .monospaced))
                        .multilineTextAlignment(.center)
                }
                Text(receipt.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11, design: .monospaced))
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 12)

            rule

            VStack(spacing: 6) {
                ForEach(receipt.items, id: \.id) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text(item.quantity > 1 ? "\(item.quantity)x \(item.name)" : item.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(money(item.totalPrice))
                    }
                    .font(.system(size: 13, design: .monospaced))
                }
            }
            .padding(.vertical, 12)

            rule

            VStack(spacing: 4) {
                totalRow("SUBTOTAL", receipt.subtotal)
                totalRow("TAX", receipt.tax)
                totalRow("TOTAL", receipt.total, emphasized: true)
            }
            .padding(.top, 12)

            Text("THANK YOU")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .frame(maxWidth: .infinity)
                .padding(.top, 18)
        }
        .padding(24)
        .frame(width: paperWidth)
        .background(Color.white)
        .foregroundColor(.black)
    }

    private var rule: some View {
        Rectangle()
            .fill(Color.black.opacity(0.55))
            .frame(height: 1)
    }

    private func totalRow(_ label: String, _ amount: Decimal, emphasized: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(money(amount))
        }
        .font(.system(size: 13, weight: emphasized ? .bold : .regular, design: .monospaced))
    }

    /// Locale-independent "$12.34" (the render must not depend on the device locale).
    private func money(_ amount: Decimal) -> String {
        String(format: "$%.2f", (amount as NSDecimalNumber).doubleValue)
    }
}
