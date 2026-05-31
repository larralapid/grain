import SwiftUI
import Charts
import SwiftData

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var analyticsService: AnalyticsService
    @State private var currentAnalytics: SpendingAnalytics?
    @State private var isLoading = false
    @State private var currentPage = 0
    @State private var monthChange: Double?
    @Query private var products: [Product]

    init(modelContext: ModelContext) {
        self._analyticsService = StateObject(wrappedValue: AnalyticsService(modelContext: modelContext))
    }

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Sub-page dots
                HStack(spacing: 6) {
                    Circle()
                        .fill(currentPage == 0 ? GrainTheme.textSecondary : GrainTheme.dateHeader)
                        .frame(width: 5, height: 5)
                    Circle()
                        .fill(currentPage == 1 ? GrainTheme.textSecondary : GrainTheme.dateHeader)
                        .frame(width: 5, height: 5)
                }
                .padding(.top, 16)
                .padding(.bottom, 4)

                // Swipeable pages
                TabView(selection: $currentPage) {
                    spendingPage.tag(0)
                    itemWatchPage.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear { loadAnalytics() }
    }

    // MARK: - Page 1: Spending

    private var spendingPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(monthLabel)
                    .font(GrainTheme.mono(12))
                    .tracking(1)
                    .foregroundColor(GrainTheme.textSecondary)
                    .padding(.top, 8)

                if let analytics = currentAnalytics {
                    Text(analytics.totalSpent.formatted(.currency(code: "USD")))
                        .font(GrainTheme.mono(48, weight: .regular))
                        .tracking(-2)
                        .foregroundColor(GrainTheme.textPrimary)
                        .padding(.top, 12)

                    Text(spendingSummary(analytics))
                        .font(GrainTheme.mono(11))
                        .foregroundColor(GrainTheme.textSecondary)
                        .lineSpacing(4)
                        .padding(.top, 4)
                } else {
                    Text("$0.00")
                        .font(GrainTheme.mono(48, weight: .regular))
                        .tracking(-2)
                        .foregroundColor(GrainTheme.textPrimary)
                        .padding(.top, 12)

                    Text("no data yet. scan some receipts.")
                        .font(GrainTheme.mono(11))
                        .foregroundColor(GrainTheme.textSecondary)
                        .padding(.top, 4)
                }

                analyticsDivider

                if let analytics = currentAnalytics {
                    sectionLabel("category")
                    categoryBars(analytics.categoryBreakdown)

                    analyticsDivider

                    sectionLabel("store")
                    storeBars(analytics.merchantBreakdown)
                }

                Text("swipe for item watch \u{2192}")
                    .font(GrainTheme.mono(9))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundColor(GrainTheme.dateHeader)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Page 2: Item Watch

    private var itemWatchPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("ITEM WATCH")
                    .font(GrainTheme.mono(12))
                    .tracking(1)
                    .foregroundColor(GrainTheme.textSecondary)
                    .padding(.top, 8)

                Text("tracking price changes across purchases")
                    .font(GrainTheme.mono(10))
                    .foregroundColor(GrainTheme.dateHeader)
                    .tracking(0.4)
                    .padding(.top, 4)

                analyticsDivider

                // Real product price history (populated by ProductIndexer on every save).
                if watchedItems.isEmpty {
                    Text("not enough purchase history yet. buy the same items a few times to see price trends.")
                        .font(GrainTheme.mono(10))
                        .foregroundColor(GrainTheme.dateHeader)
                        .lineSpacing(4)
                        .padding(.top, 16)
                } else {
                    ForEach(watchedItems) { item in
                        itemWatchRow(
                            name: item.name,
                            brand: item.brand,
                            price: item.latestPrice.formatted(.currency(code: "USD")),
                            trend: item.trend,
                            avgPrice: item.avgPrice.formatted(.currency(code: "USD")),
                            purchases: item.purchases,
                            sparkHeights: item.sparkHeights
                        )
                    }
                }

                Text("\u{2190} swipe for spending")
                    .font(GrainTheme.mono(9))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundColor(GrainTheme.dateHeader)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Components

    private enum PriceTrend {
        case up, down, flat
    }

    private func itemWatchRow(
        name: String, brand: String, price: String,
        trend: PriceTrend, avgPrice: String, purchases: Int,
        sparkHeights: [CGFloat]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .font(GrainTheme.mono(13))
                    .foregroundColor(GrainTheme.textPrimary)
                    .tracking(0.2)

                Spacer()

                HStack(spacing: 4) {
                    Text(price)
                        .font(GrainTheme.mono(13))
                        .foregroundColor(GrainTheme.textSecondary)

                    switch trend {
                    case .up:
                        Text("\u{2191}")
                            .font(GrainTheme.mono(12))
                            .foregroundColor(GrainTheme.priceUp)
                    case .down:
                        Text("\u{2193}")
                            .font(GrainTheme.mono(12))
                            .foregroundColor(GrainTheme.priceDown)
                    case .flat:
                        Text("\u{2014}")
                            .font(GrainTheme.mono(12))
                            .foregroundColor(GrainTheme.priceFlat)
                    }
                }
            }

            Text("\(brand) \u{00B7} avg \(avgPrice) \u{00B7} \(purchases) purchases")
                .font(GrainTheme.mono(10))
                .foregroundColor(GrainTheme.dateHeader)
                .tracking(0.3)
                .padding(.top, 4)

            // Sparkline
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(sparkHeights.enumerated()), id: \.offset) { index, height in
                    Rectangle()
                        .fill(GrainTheme.textPrimary.opacity(
                            index == sparkHeights.count - 1 ? 0.8 : 0.2
                        ))
                        .frame(width: 6, height: height * 20)
                }
            }
            .frame(height: 20, alignment: .bottom)
            .padding(.top, 8)
        }
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
        }
    }

    private func categoryBars(_ breakdown: [String: Decimal]) -> some View {
        let sorted = breakdown.sorted { $0.value > $1.value }.prefix(5)
        let maxVal = sorted.first?.value ?? 1

        return VStack(spacing: 8) {
            ForEach(Array(sorted), id: \.key) { category, amount in
                chartBarRow(
                    label: category.lowercased(),
                    value: amount.formatted(.currency(code: "USD")),
                    ratio: maxVal > 0 ? CGFloat(truncating: (amount / maxVal) as NSDecimalNumber) : 0
                )
            }
        }
        .padding(.vertical, 12)
    }

    private func storeBars(_ breakdown: [String: Decimal]) -> some View {
        let sorted = breakdown.sorted { $0.value > $1.value }.prefix(4)
        let maxVal = sorted.first?.value ?? 1

        return VStack(spacing: 8) {
            ForEach(Array(sorted), id: \.key) { merchant, amount in
                chartBarRow(
                    label: merchant.lowercased(),
                    value: amount.formatted(.currency(code: "USD")),
                    ratio: maxVal > 0 ? CGFloat(truncating: (amount / maxVal) as NSDecimalNumber) : 0
                )
            }
        }
        .padding(.vertical, 12)
    }

    private func chartBarRow(label: String, value: String, ratio: CGFloat) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(GrainTheme.mono(10))
                .tracking(0.4)
                .foregroundColor(GrainTheme.textSecondary)
                .frame(width: 76, alignment: .trailing)
                .lineLimit(1)
                .padding(.trailing, 10)

            GeometryReader { geo in
                Rectangle()
                    .fill(GrainTheme.surface)
                    .frame(width: geo.size.width)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(GrainTheme.textPrimary)
                            .frame(width: geo.size.width * ratio)
                    }
            }
            .frame(height: 24)

            Text(value)
                .font(GrainTheme.mono(10))
                .foregroundColor(GrainTheme.textSecondary)
                .frame(width: 44, alignment: .trailing)
                .lineLimit(1)
                .padding(.leading, 8)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(GrainTheme.mono(10))
            .tracking(1.4)
            .foregroundColor(GrainTheme.textSecondary)
    }

    private var analyticsDivider: some View {
        Rectangle()
            .fill(GrainTheme.border)
            .frame(height: 1)
            .padding(.vertical, 20)
    }

    // MARK: - Derived display

    private var monthLabel: String {
        Date().formatted(.dateTime.month(.abbreviated).year()).uppercased()
    }

    /// Honest one-liner: real month-over-month change (when there's prior spend to
    /// compare) plus the top merchants — no hardcoded numbers.
    private func spendingSummary(_ analytics: SpendingAnalytics) -> String {
        let lead: String
        if let pct = monthChange {
            lead = "\(pct >= 0 ? "+" : "")\(Int(pct.rounded()))% vs last month."
        } else {
            lead = "\(analytics.transactionCount) receipt\(analytics.transactionCount == 1 ? "" : "s") this month."
        }
        let merchants = analytics.topMerchants.prefix(2).joined(separator: ", ").lowercased()
        return merchants.isEmpty ? lead : "\(lead) top: \(merchants)."
    }

    private struct WatchedItem: Identifiable {
        let id: UUID
        let name: String
        let brand: String
        let latestPrice: Decimal
        let avgPrice: Decimal
        let trend: PriceTrend
        let purchases: Int
        let sparkHeights: [CGFloat]
    }

    /// Products with at least two recorded prices, most-tracked first — the real
    /// price-history feed behind Item Watch (populated by `ProductIndexer` on save).
    private var watchedItems: [WatchedItem] {
        products
            .map { ($0, $0.priceHistory.sorted { $0.date < $1.date }) }
            .filter { $0.1.count >= 2 }
            .sorted { $0.1.count > $1.1.count }
            .prefix(6)
            .map { product, history in
                let prices = history.map(\.price)
                let latest = prices.last ?? 0
                let avg = product.averagePrice ?? (prices.reduce(0, +) / Decimal(max(prices.count, 1)))
                let trend: PriceTrend = latest > avg * Decimal(1.02) ? .up
                    : (latest < avg * Decimal(0.98) ? .down : .flat)
                let maxP = prices.max() ?? 0
                let minP = prices.min() ?? 0
                let range = maxP - minP
                let heights: [CGFloat] = prices.map { price in
                    range > 0 ? 0.4 + 0.6 * CGFloat(truncating: ((price - minP) / range) as NSDecimalNumber) : 0.6
                }
                return WatchedItem(
                    id: product.id,
                    name: product.name,
                    brand: (product.brand ?? "").lowercased(),
                    latestPrice: latest,
                    avgPrice: avg,
                    trend: trend,
                    purchases: history.count,
                    sparkHeights: heights
                )
            }
    }

    // MARK: - Data

    private func loadAnalytics() {
        isLoading = true
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
        let prevStart = calendar.date(byAdding: .month, value: -1, to: startOfMonth) ?? startOfMonth

        Task {
            let analytics = await analyticsService.generateSpendingAnalytics(
                for: .monthly, startDate: startOfMonth, endDate: endOfMonth
            )
            let previous = await analyticsService.generateSpendingAnalytics(
                for: .monthly, startDate: prevStart, endDate: startOfMonth
            )

            // Real month-over-month change, only when there's prior-month spend to compare.
            var change: Double?
            if let current = analytics, let prev = previous, prev.totalSpent > 0 {
                let delta = (current.totalSpent - prev.totalSpent) / prev.totalSpent * 100
                change = Double(truncating: delta as NSDecimalNumber)
            }

            await MainActor.run {
                self.currentAnalytics = analytics
                self.monthChange = change
                self.isLoading = false
            }
        }
    }
}

#Preview {
    AnalyticsView(modelContext: ModelContext(try! ModelContainer(for: Receipt.self, SpendingAnalytics.self)))
}
