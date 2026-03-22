import SwiftUI
import SwiftData

struct ItemAnalyticsView: View {
    let item: ReceiptItem
    @Environment(\.dismiss) private var dismiss
    @Query private var allItems: [ReceiptItem]

    private var relatedPurchases: [ReceiptItem] {
        allItems
            .filter { $0.name == item.name }
            .sorted { ($0.receipt?.date ?? .distantPast) > ($1.receipt?.date ?? .distantPast) }
    }

    private var prices: [Decimal] {
        relatedPurchases.map { $0.totalPrice }
    }

    private var avgPrice: Decimal {
        guard !prices.isEmpty else { return 0 }
        return prices.reduce(0, +) / Decimal(prices.count)
    }

    private var lowPrice: Decimal { prices.min() ?? 0 }
    private var highPrice: Decimal { prices.max() ?? 0 }

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    itemHeader
                    sparkline
                    priceStats
                    purchaseHistory
                    boughtWith
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("\u{2190} back")
                        .font(GrainTheme.mono(12))
                        .foregroundColor(GrainTheme.textSecondary)
                }
            }
        }
    }

    private var itemHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.name)
                .font(GrainTheme.mono(18))
                .foregroundColor(GrainTheme.textPrimary)
                .tracking(0.2)
                .padding(.top, 8)

            if let brand = item.brand, !brand.isEmpty {
                Text(brand.lowercased())
                    .font(GrainTheme.mono(11))
                    .foregroundColor(GrainTheme.textSecondary)
                    .tracking(0.2)
                    .padding(.top, 2)
            }

            Text("\(relatedPurchases.count) purchase\(relatedPurchases.count == 1 ? "" : "s") \u{00B7} avg \(avgPrice.formatted(.currency(code: "USD")))")
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.top, 2)
        }
    }

    private var sparkline: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(Array(prices.suffix(8).enumerated()), id: \.offset) { index, price in
                let maxP = highPrice == 0 ? 1 : highPrice
                let height = CGFloat(truncating: (price / maxP) as NSDecimalNumber) * 32

                Rectangle()
                    .fill(GrainTheme.accent.opacity(index == prices.suffix(8).count - 1 ? 1.0 : 0.6))
                    .frame(width: 8, height: max(height, 2))
            }
        }
        .frame(height: 32, alignment: .bottom)
        .padding(.vertical, 16)
    }

    private var priceStats: some View {
        VStack(spacing: 0) {
            HStack {
                statColumn("low", value: lowPrice.formatted(.currency(code: "USD")))
                Spacer()
                statColumn("avg", value: avgPrice.formatted(.currency(code: "USD")))
                Spacer()
                statColumn("high", value: highPrice.formatted(.currency(code: "USD")))
                Spacer()
                statColumn("last", value: item.totalPrice.formatted(.currency(code: "USD")))
            }
            .padding(.bottom, 20)

            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
        }
    }

    private func statColumn(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.textSecondary)
            Text(value)
                .font(GrainTheme.mono(14))
                .foregroundColor(GrainTheme.textPrimary)
        }
    }

    private var purchaseHistory: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("PURCHASE HISTORY")
                .font(GrainTheme.mono(10))
                .tracking(1.4)
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.top, 24)
                .padding(.bottom, 16)

            ForEach(relatedPurchases.prefix(5), id: \.id) { purchase in
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(purchase.receipt?.merchantName ?? "Unknown")
                            .font(GrainTheme.mono(13))
                            .foregroundColor(GrainTheme.textPrimary)

                        Text(purchase.receipt?.date.formatted(.dateTime.month(.abbreviated).day()) ?? "")
                            .font(GrainTheme.mono(11))
                            .foregroundColor(GrainTheme.textSecondary)
                    }

                    Spacer()

                    Text(purchase.totalPrice.formatted(.currency(code: "USD")))
                        .font(GrainTheme.mono(15))
                        .foregroundColor(GrainTheme.textPrimary)
                }
                .padding(.vertical, 14)
            }
        }
    }

    private var boughtWith: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
                .padding(.vertical, 24)

            Text("BOUGHT WITH")
                .font(GrainTheme.mono(10))
                .tracking(1.4)
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.bottom, 8)

            let companions = findCompanionItems()
            if !companions.isEmpty {
                Text(companions.joined(separator: " \u{00B7} "))
                    .font(GrainTheme.mono(11))
                    .foregroundColor(GrainTheme.textSecondary)
                    .lineSpacing(6)
            }

            Spacer().frame(height: 40)
        }
    }

    private func findCompanionItems() -> [String] {
        let receiptsWithItem = relatedPurchases.compactMap { $0.receipt }
        var companions: [String: Int] = [:]

        for receipt in receiptsWithItem {
            for otherItem in receipt.items where otherItem.name != item.name {
                companions[otherItem.name.lowercased(), default: 0] += 1
            }
        }

        return companions
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
    }
}
