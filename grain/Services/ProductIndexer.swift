import Foundation
import SwiftData

/// Builds the product index (Product / PricePoint / Brand) from a saved `Receipt`.
///
/// Scanning or manually entering a receipt only creates `Receipt` + `ReceiptItem`; without this
/// step the Index tab, price history, and `Product.averagePrice` stay empty for all real (non-demo)
/// data. This mirrors the linking + rollup performed by `DemoDataSeeder`, but fetch-or-creates
/// `Product`/`Brand` from the `ModelContext` (a `FetchDescriptor` query) instead of the seeder's
/// in-memory caches, so it dedupes across app sessions.
///
/// Call immediately before `modelContext.save()` at every receipt-save site. Items that already
/// have a linked `product` are skipped, so re-indexing an edited receipt only picks up newly-added
/// line items.
@MainActor
enum ProductIndexer {
    static func index(_ receipt: Receipt, in context: ModelContext) {
        for item in receipt.items where item.product == nil {
            let product = fetchOrCreateProduct(for: item, in: context)
            item.product = product

            let pricePoint = PricePoint(
                price: item.unitPrice,
                date: receipt.date,
                merchantName: receipt.merchantName
            )
            pricePoint.product = product
            pricePoint.receiptItem = item
            context.insert(pricePoint)
            product.priceHistory.append(pricePoint)
            product.averagePrice = averagePrice(for: product.priceHistory)
            product.updatedAt = Date()

            guard let brandName = item.brand, !brandName.isEmpty else {
                continue
            }

            let brand = fetchOrCreateBrand(named: brandName, category: item.category, in: context)
            brand.totalSpent += item.totalPrice
            brand.transactionCount += 1
            brand.averageTransactionAmount = brand.totalSpent / Decimal(brand.transactionCount)
            if !brand.products.contains(where: { $0.id == product.id }) {
                brand.products.append(product)
            }
            brand.updatedAt = Date()
        }
    }

    // MARK: - Fetch-or-create

    /// Finds an existing `Product` matching the item's (name, brand, category) or creates one.
    /// Locals are captured before the `#Predicate` so SwiftData can compare optionals cleanly:
    /// `category` is normalised to a non-optional `String` (Product.category is non-optional),
    /// while `brand` stays an optional `String?` matched against `Product.brand`.
    private static func fetchOrCreateProduct(for item: ReceiptItem, in context: ModelContext) -> Product {
        let name = item.name
        let brand = item.brand
        let category = item.category ?? ""

        var descriptor = FetchDescriptor<Product>(
            predicate: #Predicate { product in
                product.name == name
                    && product.brand == brand
                    && product.category == category
            }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let product = Product(name: name, brand: brand, category: category)
        context.insert(product)
        return product
    }

    /// Finds an existing `Brand` by name or creates one. Brand identity is the name alone
    /// (matching `DemoDataSeeder`'s `brandCache` keyed by brand name).
    private static func fetchOrCreateBrand(named name: String, category: String?, in context: ModelContext) -> Brand {
        var descriptor = FetchDescriptor<Brand>(
            predicate: #Predicate { brand in
                brand.name == name
            }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let brand = Brand(name: name, category: category)
        context.insert(brand)
        return brand
    }

    // MARK: - Rollup

    private static func averagePrice(for history: [PricePoint]) -> Decimal {
        guard !history.isEmpty else {
            return 0
        }

        let total = history.reduce(Decimal.zero) { partialResult, point in
            partialResult + point.price
        }
        return total / Decimal(history.count)
    }
}
