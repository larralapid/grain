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
                        }
                        .padding(.vertical, 10)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(GrainTheme.border)
                                .frame(height: 1)
                        }
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
                    indexCard(
                        name: retailer.name,
                        total: retailer.total.formatted(.currency(code: "USD")),
                        meta: "\(retailer.receiptCount) receipt\(retailer.receiptCount == 1 ? "" : "s") \u{00B7} \(retailer.productCount) product\(retailer.productCount == 1 ? "" : "s")"
                    )
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
