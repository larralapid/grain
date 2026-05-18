import SwiftUI
import SwiftData

enum IndexSubview: String, CaseIterable {
    case products, brands, retailers
}

struct ProductsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Product]
    @Query private var brands: [Brand]
    @Query(sort: \Receipt.date, order: .reverse) private var receipts: [Receipt]
    @State private var selectedView: IndexSubview = .products
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {
                GrainTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header
                        viewToggle
                        viewContent
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("grain")
                .font(GrainTheme.mono(11))
                .tracking(2.2)
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.top, 16)

            Text("who gets paid when you buy things")
                .font(GrainTheme.mono(10))
                .foregroundColor(GrainTheme.dateHeader)
                .tracking(0.4)
                .padding(.top, 4)
        }
    }

    // MARK: - Toggle

    private var viewToggle: some View {
        HStack(spacing: 16) {
            ForEach(IndexSubview.allCases, id: \.self) { view in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedView = view
                    }
                } label: {
                    Text(view.rawValue.uppercased())
                        .font(GrainTheme.mono(12))
                        .tracking(1)
                        .foregroundColor(selectedView == view ? GrainTheme.textPrimary : GrainTheme.textSecondary)
                        .padding(.vertical, 4)
                        .overlay(alignment: .bottom) {
                            if selectedView == view {
                                Rectangle()
                                    .fill(GrainTheme.accent)
                                    .frame(height: 1.5)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    // MARK: - Content

    @ViewBuilder
    private var viewContent: some View {
        switch selectedView {
        case .products:
            productsSubview
        case .brands:
            brandsSubview
        case .retailers:
            retailersSubview
        }
    }

    // MARK: - Products (alphabetical index)

    private var productsSubview: some View {
        let grouped = groupProductsByLetter()

        return VStack(alignment: .leading, spacing: 0) {
            if grouped.isEmpty {
                emptyContent("no products yet")
            } else {
                ForEach(grouped, id: \.0) { letter, items in
                    Text(letter)
                        .font(GrainTheme.mono(20, weight: .light))
                        .foregroundColor(GrainTheme.textPrimary)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                    ForEach(items, id: \.name) { item in
                        NavigationLink {
                            ProductMarketTrendsView(
                                product: item,
                                analyticsService: AnalyticsService(modelContext: modelContext)
                            )
                        } label: {
                            HStack(alignment: .firstTextBaseline) {
                                Text(item.name)
                                    .font(GrainTheme.mono(13))
                                    .foregroundColor(GrainTheme.textPrimary)
                                    .tracking(0.2)

                                Spacer()

                                if let avg = item.averagePrice {
                                    Text("avg \(avg.formatted(.currency(code: "USD")))")
                                        .font(GrainTheme.mono(14))
                                        .foregroundColor(GrainTheme.textSecondary)
                                }

                                Text("›")
                                    .font(GrainTheme.mono(14))
                                    .foregroundColor(GrainTheme.textSecondary)
                                    .padding(.leading, 8)
                            }
                            .padding(.vertical, 10)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(GrainTheme.border)
                                    .frame(height: 1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Spacer().frame(height: 40)
        }
    }

    // MARK: - Brands (cards)

    private var brandsSubview: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WHO MAKES WHAT YOU BUY")
                .font(GrainTheme.mono(9))
                .tracking(0.6)
                .foregroundColor(GrainTheme.dateHeader)
                .padding(.bottom, 16)

            if brands.isEmpty {
                emptyContent("no brands yet")
            } else {
                ForEach(brands.sorted(by: { $0.totalSpent > $1.totalSpent })) { brand in
                    indexCard(
                        name: brand.name,
                        total: brand.totalSpent.formatted(.currency(code: "USD")),
                        meta: "\(brand.products.count) product\(brand.products.count == 1 ? "" : "s") \u{00B7} \(brand.transactionCount) purchase\(brand.transactionCount == 1 ? "" : "s")"
                    )
                }
            }
            Spacer().frame(height: 40)
        }
    }

    // MARK: - Retailers (cards)

    private var retailersSubview: some View {
        let retailers = groupReceiptsByRetailer()

        return VStack(alignment: .leading, spacing: 0) {
            Text("WHERE YOUR MONEY GOES")
                .font(GrainTheme.mono(9))
                .tracking(0.6)
                .foregroundColor(GrainTheme.dateHeader)
                .padding(.bottom, 16)

            if retailers.isEmpty {
                emptyContent("no retailers yet")
            } else {
                ForEach(retailers, id: \.name) { retailer in
                    NavigationLink {
                        RetailerMarketTrendsView(
                            retailerName: retailer.name,
                            analyticsService: AnalyticsService(modelContext: modelContext)
                        )
                    } label: {
                        indexCard(
                            name: retailer.name,
                            total: retailer.total.formatted(.currency(code: "USD")),
                            meta: "\(retailer.receiptCount) receipt\(retailer.receiptCount == 1 ? "" : "s") \u{00B7} \(retailer.productCount) product\(retailer.productCount == 1 ? "" : "s")"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer().frame(height: 40)
        }
    }

    // MARK: - Components

    private func indexCard(name: String, total: String, meta: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .font(GrainTheme.mono(13))
                    .foregroundColor(GrainTheme.textPrimary)
                    .tracking(0.2)

                Spacer()

                Text(total)
                    .font(GrainTheme.mono(15))
                    .foregroundColor(GrainTheme.accent)
            }

            Text(meta)
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.top, 6)
        }
        .padding(20)
        .overlay(
            Rectangle()
                .stroke(GrainTheme.border, lineWidth: 1)
        )
        .padding(.bottom, 12)
    }

    private func emptyContent(_ message: String) -> some View {
        Text(message)
            .font(GrainTheme.mono(12))
            .foregroundColor(GrainTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }

    // MARK: - Data helpers

    private func groupProductsByLetter() -> [(String, [Product])] {
        let grouped = Dictionary(grouping: products) { product in
            String(product.name.prefix(1)).uppercased()
        }
        return grouped.sorted { $0.key < $1.key }
    }

    private struct RetailerInfo {
        let name: String
        let total: Decimal
        let receiptCount: Int
        let productCount: Int
    }

    private func groupReceiptsByRetailer() -> [RetailerInfo] {
        let grouped = Dictionary(grouping: receipts) { $0.merchantName }
        return grouped.map { name, receipts in
            RetailerInfo(
                name: name,
                total: receipts.reduce(Decimal(0)) { $0 + $1.total },
                receiptCount: receipts.count,
                productCount: receipts.reduce(0) { $0 + $1.items.count }
            )
        }
        .sorted { $0.total > $1.total }
    }
}

#Preview {
    ProductsView()
        .modelContainer(for: [Product.self, Brand.self, Receipt.self], inMemory: true)
}

struct ProductMarketTrendsView: View {
    let product: Product
    let analyticsService: AnalyticsService
    @State private var report: ProductTrendReport?

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(product.name)
                        .font(GrainTheme.mono(18))
                        .foregroundColor(GrainTheme.textPrimary)
                        .padding(.top, 8)

                    if let brand = product.brand, !brand.isEmpty {
                        Text(brand.lowercased())
                            .font(GrainTheme.mono(11))
                            .foregroundColor(GrainTheme.textSecondary)
                            .padding(.top, 2)
                    }

                    if let report {
                        trendSection(title: "MARKET TREND", points: report.monthlyTrends.map(\.averagePrice))
                        forecastRow(
                            label: "forecast next avg",
                            value: report.forecastAveragePrice?.formatted(.currency(code: "USD")) ?? "insufficient data"
                        )
                        forecastRow(
                            label: "forecast next spend",
                            value: report.forecastTotalSpend?.formatted(.currency(code: "USD")) ?? "insufficient data"
                        )

                        sectionDivider
                        sectionLabel("RETAILER CROSS ANALYSIS")
                            .padding(.top, 20)
                            .padding(.bottom, 8)

                        if report.retailerComparison.isEmpty {
                            Text("no retailer data yet")
                                .font(GrainTheme.mono(11))
                                .foregroundColor(GrainTheme.textSecondary)
                        } else {
                            ForEach(Array(report.retailerComparison.prefix(5).enumerated()), id: \.offset) { _, row in
                                crossRow(
                                    title: row.retailer,
                                    subtitle: "\(row.purchaseCount) purchase\(row.purchaseCount == 1 ? "" : "s")",
                                    value: row.averagePrice.formatted(.currency(code: "USD"))
                                )
                            }
                        }

                        if let categoryComparison = report.categoryComparison {
                            sectionDivider
                            sectionLabel("CATEGORY CROSS ANALYSIS")
                                .padding(.top, 20)
                                .padding(.bottom, 8)

                            crossRow(
                                title: categoryComparison.categoryName.lowercased(),
                                subtitle: "category avg \(categoryComparison.categoryAveragePrice.formatted(.currency(code: "USD")))",
                                value: signedCurrency(categoryComparison.difference)
                            )
                        }
                    } else {
                        Text("loading trends...")
                            .font(GrainTheme.mono(12))
                            .foregroundColor(GrainTheme.textSecondary)
                            .padding(.top, 24)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                report = await analyticsService.getProductTrendReport(
                    for: product.name,
                    category: product.category
                )
            }
        }
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(GrainTheme.border)
            .frame(height: 1)
            .padding(.top, 20)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(GrainTheme.mono(10))
            .tracking(1)
            .foregroundColor(GrainTheme.textSecondary)
    }

    private func trendSection(title: String, points: [Decimal]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionDivider
            sectionLabel(title)
                .padding(.top, 20)
                .padding(.bottom, 10)

            HStack(alignment: .bottom, spacing: 4) {
                let maxValue = max(points.max() ?? 0, Decimal(1))
                ForEach(Array(points.suffix(6).enumerated()), id: \.offset) { _, point in
                    let ratio = CGFloat(truncating: (point / maxValue) as NSDecimalNumber)
                    Rectangle()
                        .fill(GrainTheme.accent)
                        .frame(width: 12, height: max(4, ratio * 36))
                }
            }
            .frame(height: 36, alignment: .bottom)
        }
    }

    private func forecastRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.textSecondary)
            Spacer()
            Text(value)
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textPrimary)
        }
        .padding(.top, 10)
    }

    private func crossRow(title: String, subtitle: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(GrainTheme.mono(12))
                    .foregroundColor(GrainTheme.textPrimary)
                Text(subtitle)
                    .font(GrainTheme.mono(10))
                    .foregroundColor(GrainTheme.textSecondary)
            }
            Spacer()
            Text(value)
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textPrimary)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
        }
    }

    private func signedCurrency(_ value: Decimal) -> String {
        let sign = value > 0 ? "+" : ""
        return "\(sign)\(value.formatted(.currency(code: "USD")))"
    }
}

struct RetailerMarketTrendsView: View {
    let retailerName: String
    let analyticsService: AnalyticsService
    @State private var report: RetailerTrendReport?

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(retailerName)
                        .font(GrainTheme.mono(18))
                        .foregroundColor(GrainTheme.textPrimary)
                        .padding(.top, 8)

                    if let report {
                        trendSection(points: report.monthlyTrends.map(\.totalSpend))
                        forecastRow(
                            label: "forecast next spend",
                            value: report.forecastTotalSpend?.formatted(.currency(code: "USD")) ?? "insufficient data"
                        )

                        sectionDivider
                        sectionLabel("PRODUCT CROSS ANALYSIS")
                            .padding(.top, 20)
                            .padding(.bottom, 8)

                        if report.productComparisons.isEmpty {
                            Text("no product data yet")
                                .font(GrainTheme.mono(11))
                                .foregroundColor(GrainTheme.textSecondary)
                        } else {
                            ForEach(Array(report.productComparisons.prefix(5).enumerated()), id: \.offset) { _, row in
                                crossRow(
                                    title: row.productName,
                                    subtitle: "market \(row.marketAveragePrice.formatted(.currency(code: "USD")))",
                                    value: signedCurrency(row.difference)
                                )
                            }
                        }
                    } else {
                        Text("loading trends...")
                            .font(GrainTheme.mono(12))
                            .foregroundColor(GrainTheme.textSecondary)
                            .padding(.top, 24)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                report = await analyticsService.getRetailerTrendReport(for: retailerName)
            }
        }
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(GrainTheme.border)
            .frame(height: 1)
            .padding(.top, 20)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(GrainTheme.mono(10))
            .tracking(1)
            .foregroundColor(GrainTheme.textSecondary)
    }

    private func trendSection(points: [Decimal]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionDivider
            sectionLabel("MARKET TREND")
                .padding(.top, 20)
                .padding(.bottom, 10)

            HStack(alignment: .bottom, spacing: 4) {
                let maxValue = max(points.max() ?? 0, Decimal(1))
                ForEach(Array(points.suffix(6).enumerated()), id: \.offset) { _, point in
                    let ratio = CGFloat(truncating: (point / maxValue) as NSDecimalNumber)
                    Rectangle()
                        .fill(GrainTheme.accent)
                        .frame(width: 12, height: max(4, ratio * 36))
                }
            }
            .frame(height: 36, alignment: .bottom)
        }
    }

    private func forecastRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.textSecondary)
            Spacer()
            Text(value)
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textPrimary)
        }
        .padding(.top, 10)
    }

    private func crossRow(title: String, subtitle: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(GrainTheme.mono(12))
                    .foregroundColor(GrainTheme.textPrimary)
                Text(subtitle)
                    .font(GrainTheme.mono(10))
                    .foregroundColor(GrainTheme.textSecondary)
            }
            Spacer()
            Text(value)
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textPrimary)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
        }
    }

    private func signedCurrency(_ value: Decimal) -> String {
        let sign = value > 0 ? "+" : ""
        return "\(sign)\(value.formatted(.currency(code: "USD")))"
    }
}
