import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var analyticsService: AnalyticsService
    @State private var currentAnalytics: SpendingAnalytics?
    @State private var isLoading = false
    @State private var currentPage = 0

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
                        .fill(currentPage == 0 ? Color(white: 0.533) : Color(white: 0.2))
                        .frame(width: 5, height: 5)
                    Circle()
                        .fill(currentPage == 1 ? Color(white: 0.533) : Color(white: 0.2))
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
                Text("MAR 2026")
                    .font(GrainTheme.mono(12))
                    .tracking(1)
                    .foregroundColor(GrainTheme.textSecondary)
                    .padding(.top, 8)

                if let analytics = currentAnalytics {
                    Text(analytics.totalSpent.formatted(.currency(code: "USD")))
                        .font(GrainTheme.mono(48, weight: .ultraLight))
                        .tracking(-2)
                        .foregroundColor(GrainTheme.textPrimary)
                        .padding(.top, 12)

                    Text("+12% from feb. \(analytics.topMerchants.prefix(2).joined(separator: ", ").lowercased()). dining flat.")
                        .font(GrainTheme.mono(11))
                        .foregroundColor(GrainTheme.textSecondary)
                        .lineSpacing(4)
                        .padding(.top, 4)
                } else {
                    Text("$0.00")
                        .font(GrainTheme.mono(48, weight: .ultraLight))
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
                    .foregroundColor(Color(white: 0.2))
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

                // Sample watched items (from receipt data)
                itemWatchRow(
                    name: "Oat Milk", brand: "oatly", price: "$4.79",
                    trend: .up, avgPrice: "$4.50", purchases: 8,
                    sparkHeights: [0.55, 0.60, 0.55, 0.65, 0.58, 0.55, 0.68, 0.78]
                )
                itemWatchRow(
                    name: "Paper Towels", brand: "seventh gen", price: "$8.29",
                    trend: .up, avgPrice: "$7.80", purchases: 3,
                    sparkHeights: [0.70, 0.75, 0.90]
                )
                itemWatchRow(
                    name: "Chicken Breast", brand: "foster farms", price: "$6.49/lb",
                    trend: .down, avgPrice: "$6.99/lb", purchases: 5,
                    sparkHeights: [0.75, 0.80, 0.85, 0.70, 0.60]
                )
                itemWatchRow(
                    name: "Greek Yogurt", brand: "fage", price: "$5.49",
                    trend: .flat, avgPrice: "$5.49", purchases: 4,
                    sparkHeights: [0.70, 0.70, 0.70, 0.70]
                )
                itemWatchRow(
                    name: "Olive Oil", brand: "california olive ranch", price: "$8.99",
                    trend: .up, avgPrice: "$8.29", purchases: 3,
                    sparkHeights: [0.55, 0.70, 0.85]
                )

                Text("\u{2190} swipe for spending")
                    .font(GrainTheme.mono(9))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundColor(Color(white: 0.2))
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
                        .foregroundColor(Color(white: 0.533))

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
                .foregroundColor(Color(white: 0.4))
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

    // MARK: - Data

    private func loadAnalytics() {
        isLoading = true
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now

        Task {
            let analytics = await analyticsService.generateSpendingAnalytics(
                for: .monthly,
                startDate: startOfMonth,
                endDate: endOfMonth
            )

            await MainActor.run {
                self.currentAnalytics = analytics
                self.isLoading = false
            }
        }
    }
}

#Preview {
    AnalyticsView(modelContext: ModelContext(try! ModelContainer(for: Receipt.self, SpendingAnalytics.self)))
}
