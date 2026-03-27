import Foundation
import SwiftData

@MainActor
enum DemoDataSeeder {
    static func seedIfNeeded(in modelContext: ModelContext, referenceDate: Date = .now) {
        var descriptor = FetchDescriptor<Receipt>()
        descriptor.fetchLimit = 1

        do {
            if try !modelContext.fetch(descriptor).isEmpty {
                return
            }

            let templates = DemoReceiptTemplate.samples(referenceDate: referenceDate)
            var brandCache: [String: Brand] = [:]
            var productCache: [ProductKey: Product] = [:]

            for template in templates {
                let receipt = Receipt(
                    date: template.date,
                    merchantName: template.merchantName,
                    merchantAddress: template.merchantAddress,
                    total: template.total,
                    subtotal: template.subtotal,
                    tax: template.tax,
                    ocrText: template.ocrText,
                    bankTransactionId: template.bankTransactionId,
                    category: template.category,
                    notes: template.notes
                )
                modelContext.insert(receipt)

                var brandSpendByReceipt: [String: Decimal] = [:]
                var productsByBrand: [String: [Product]] = [:]

                for itemTemplate in template.items {
                    let item = ReceiptItem(
                        name: itemTemplate.name,
                        brand: itemTemplate.brand,
                        category: itemTemplate.category,
                        quantity: itemTemplate.quantity,
                        unitPrice: itemTemplate.unitPrice,
                        totalPrice: itemTemplate.totalPrice
                    )
                    item.receipt = receipt
                    receipt.items.append(item)
                    modelContext.insert(item)

                    let productKey = ProductKey(
                        name: itemTemplate.name,
                        brand: itemTemplate.brand,
                        category: itemTemplate.category
                    )
                    let product = productCache[productKey] ?? makeProduct(
                        from: itemTemplate,
                        key: productKey,
                        in: modelContext
                    )
                    productCache[productKey] = product
                    item.product = product

                    let pricePoint = PricePoint(
                        price: item.unitPrice,
                        date: template.date,
                        merchantName: template.merchantName
                    )
                    pricePoint.product = product
                    pricePoint.receiptItem = item
                    product.priceHistory.append(pricePoint)
                    product.averagePrice = averagePrice(for: product.priceHistory)
                    modelContext.insert(pricePoint)

                    guard let brandName = itemTemplate.brand else {
                        continue
                    }

                    let brand = brandCache[brandName] ?? makeBrand(
                        name: brandName,
                        category: itemTemplate.category,
                        in: modelContext
                    )
                    brandCache[brandName] = brand
                    brandSpendByReceipt[brandName, default: 0] += item.totalPrice
                    productsByBrand[brandName, default: []].append(product)
                }

                for (brandName, totalSpend) in brandSpendByReceipt {
                    guard let brand = brandCache[brandName] else {
                        continue
                    }

                    brand.totalSpent += totalSpend
                    brand.transactionCount += 1
                    brand.averageTransactionAmount = brand.totalSpent / Decimal(brand.transactionCount)

                    for product in productsByBrand[brandName, default: []] {
                        if !brand.products.contains(where: { $0.id == product.id }) {
                            brand.products.append(product)
                        }
                    }
                }
            }

            try modelContext.save()
        } catch {
            assertionFailure("Failed to seed demo data: \(error)")
        }
    }

    static func sampleReceipts(referenceDate: Date = .now) -> [Receipt] {
        DemoReceiptTemplate.samples(referenceDate: referenceDate).map { template in
            let receipt = Receipt(
                date: template.date,
                merchantName: template.merchantName,
                merchantAddress: template.merchantAddress,
                total: template.total,
                subtotal: template.subtotal,
                tax: template.tax,
                ocrText: template.ocrText,
                bankTransactionId: template.bankTransactionId,
                category: template.category,
                notes: template.notes
            )

            receipt.items = template.items.map { itemTemplate in
                let item = ReceiptItem(
                    name: itemTemplate.name,
                    brand: itemTemplate.brand,
                    category: itemTemplate.category,
                    quantity: itemTemplate.quantity,
                    unitPrice: itemTemplate.unitPrice,
                    totalPrice: itemTemplate.totalPrice
                )
                item.receipt = receipt
                return item
            }

            return receipt
        }
    }

    static func makePreviewContainer() -> ModelContainer {
        let schema = Schema([
            Receipt.self,
            ReceiptItem.self,
            Product.self,
            PricePoint.self,
            Brand.self,
            BankTransaction.self,
            SpendingAnalytics.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            seedIfNeeded(in: container.mainContext)
            return container
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }

    private static func makeBrand(name: String, category: String?, in modelContext: ModelContext) -> Brand {
        let brand = Brand(name: name, category: category)
        modelContext.insert(brand)
        return brand
    }

    private static func makeProduct(
        from itemTemplate: DemoItemTemplate,
        key: ProductKey,
        in modelContext: ModelContext
    ) -> Product {
        let product = Product(
            name: key.name,
            brand: key.brand,
            category: key.category
        )
        modelContext.insert(product)
        return product
    }

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

private struct ProductKey: Hashable {
    let name: String
    let brand: String?
    let category: String
}

private struct DemoReceiptTemplate {
    let merchantName: String
    let merchantAddress: String
    let category: String
    let notes: String
    let bankTransactionId: String
    let date: Date
    let items: [DemoItemTemplate]
    let subtotal: Decimal
    let tax: Decimal
    let total: Decimal
    let ocrText: String

    static func samples(referenceDate: Date) -> [DemoReceiptTemplate] {
        let calendar = Calendar.current
        let receipts: [(String, String, String, String, Int, Int, [DemoItemTemplate], Decimal)] = [
            ("Trader Joe's", "5727 College Ave, Oakland, CA", "Groceries", "weeknight restock", 0, 18, [
                .init(name: "Bananas", brand: "Trader Joe's", category: "Produce", quantity: 2, unitPrice: 0.29, totalPrice: 0.58),
                .init(name: "Greek Yogurt", brand: "Fage", category: "Dairy", quantity: 1, unitPrice: 5.49, totalPrice: 5.49),
                .init(name: "Sourdough Bread", brand: "Acme", category: "Bakery", quantity: 1, unitPrice: 6.99, totalPrice: 6.99),
                .init(name: "Baby Spinach", brand: "Earthbound Farm", category: "Produce", quantity: 1, unitPrice: 3.49, totalPrice: 3.49)
            ], 1.41),
            ("Whole Foods Market", "230 Bay Pl, Oakland, CA", "Groceries", "fridge refill", 1, 17, [
                .init(name: "Oat Milk", brand: "Oatly", category: "Dairy Alternatives", quantity: 2, unitPrice: 4.79, totalPrice: 9.58),
                .init(name: "Eggs", brand: "Vital Farms", category: "Dairy", quantity: 1, unitPrice: 7.29, totalPrice: 7.29),
                .init(name: "Avocados", brand: "Whole Foods", category: "Produce", quantity: 4, unitPrice: 1.49, totalPrice: 5.96)
            ], 1.93),
            ("Target", "1555 40th St, Emeryville, CA", "Home", "paper goods + pantry", 2, 14, [
                .init(name: "Paper Towels", brand: "Up&Up", category: "Household", quantity: 1, unitPrice: 8.29, totalPrice: 8.29),
                .init(name: "Dish Soap", brand: "Method", category: "Household", quantity: 1, unitPrice: 4.99, totalPrice: 4.99),
                .init(name: "Pasta", brand: "Good & Gather", category: "Pantry", quantity: 2, unitPrice: 1.79, totalPrice: 3.58),
                .init(name: "Marinara Sauce", brand: "Rao's", category: "Pantry", quantity: 1, unitPrice: 7.49, totalPrice: 7.49)
            ], 2.31),
            ("Safeway", "6310 College Ave, Oakland, CA", "Groceries", "produce run", 3, 16, [
                .init(name: "Blueberries", brand: "Driscoll's", category: "Produce", quantity: 1, unitPrice: 4.99, totalPrice: 4.99),
                .init(name: "Chicken Breast", brand: "Open Nature", category: "Meat", quantity: 1, unitPrice: 11.42, totalPrice: 11.42),
                .init(name: "Rice", brand: "Mahatma", category: "Pantry", quantity: 1, unitPrice: 3.99, totalPrice: 3.99)
            ], 1.82),
            ("Costco", "4801 Central Ave, Richmond, CA", "Home", "bulk haul", 4, 11, [
                .init(name: "Toilet Paper", brand: "Kirkland", category: "Household", quantity: 1, unitPrice: 24.99, totalPrice: 24.99),
                .init(name: "Olive Oil", brand: "California Olive Ranch", category: "Pantry", quantity: 1, unitPrice: 18.49, totalPrice: 18.49),
                .init(name: "Frozen Berries", brand: "Kirkland", category: "Frozen", quantity: 1, unitPrice: 12.99, totalPrice: 12.99)
            ], 4.50),
            ("Berkeley Bowl", "2020 Oregon St, Berkeley, CA", "Groceries", "weekend market stop", 5, 13, [
                .init(name: "Heirloom Tomatoes", brand: "Berkeley Bowl", category: "Produce", quantity: 2, unitPrice: 3.49, totalPrice: 6.98),
                .init(name: "Fresh Basil", brand: "Berkeley Bowl", category: "Produce", quantity: 1, unitPrice: 2.29, totalPrice: 2.29),
                .init(name: "Mozzarella", brand: "BelGioioso", category: "Dairy", quantity: 1, unitPrice: 6.79, totalPrice: 6.79)
            ], 1.43),
            ("Sprouts Farmers Market", "3035 Broadway, Oakland, CA", "Groceries", "salad prep", 6, 15, [
                .init(name: "Kale", brand: "Sprouts", category: "Produce", quantity: 2, unitPrice: 1.99, totalPrice: 3.98),
                .init(name: "Almond Butter", brand: "Justin's", category: "Pantry", quantity: 1, unitPrice: 8.99, totalPrice: 8.99),
                .init(name: "Granola", brand: "Purely Elizabeth", category: "Breakfast", quantity: 1, unitPrice: 5.99, totalPrice: 5.99)
            ], 1.61),
            ("CVS Pharmacy", "2655 Telegraph Ave, Berkeley, CA", "Home", "household basics", 7, 19, [
                .init(name: "Toothpaste", brand: "Crest", category: "Personal Care", quantity: 1, unitPrice: 5.49, totalPrice: 5.49),
                .init(name: "Laundry Detergent", brand: "Tide", category: "Household", quantity: 1, unitPrice: 12.99, totalPrice: 12.99),
                .init(name: "Hand Soap", brand: "Softsoap", category: "Personal Care", quantity: 2, unitPrice: 2.79, totalPrice: 5.58)
            ], 2.17),
            ("H Mart", "3385 Grand Ave, Oakland, CA", "Groceries", "asian pantry refill", 8, 12, [
                .init(name: "Kimchi", brand: "Jongga", category: "Refrigerated", quantity: 1, unitPrice: 7.49, totalPrice: 7.49),
                .init(name: "Short Grain Rice", brand: "Nishiki", category: "Pantry", quantity: 1, unitPrice: 15.99, totalPrice: 15.99),
                .init(name: "Scallions", brand: "H Mart", category: "Produce", quantity: 2, unitPrice: 0.99, totalPrice: 1.98)
            ], 2.26),
            ("Home Depot", "3838 Hollis St, Emeryville, CA", "Home", "kitchen storage bins", 9, 10, [
                .init(name: "Storage Bin", brand: "HDX", category: "Home Organization", quantity: 2, unitPrice: 9.98, totalPrice: 19.96),
                .init(name: "Shelf Liner", brand: "Duck", category: "Home Organization", quantity: 1, unitPrice: 6.49, totalPrice: 6.49)
            ], 2.38)
        ]

        return receipts.enumerated().map { index, receipt in
            let date = sampleDate(
                dayOffset: receipt.4,
                hour: receipt.5,
                minute: 12 + index,
                referenceDate: referenceDate,
                calendar: calendar
            )
            let subtotal = receipt.6.reduce(Decimal.zero) { total, item in
                total + item.totalPrice
            }
            let tax = receipt.7

            return DemoReceiptTemplate(
                merchantName: receipt.0,
                merchantAddress: receipt.1,
                category: receipt.2,
                notes: receipt.3,
                bankTransactionId: "demo-\(index + 1)",
                date: date,
                items: receipt.6,
                subtotal: subtotal,
                tax: tax,
                total: subtotal + tax,
                ocrText: makeOCRText(
                    merchantName: receipt.0,
                    address: receipt.1,
                    items: receipt.6,
                    subtotal: subtotal,
                    tax: tax
                )
            )
        }
    }

    private static func sampleDate(
        dayOffset: Int,
        hour: Int,
        minute: Int,
        referenceDate: Date,
        calendar: Calendar
    ) -> Date {
        let shiftedDate = calendar.date(byAdding: .day, value: -dayOffset, to: referenceDate) ?? referenceDate
        var components = calendar.dateComponents([.year, .month, .day], from: shiftedDate)
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? shiftedDate
    }

    private static func makeOCRText(
        merchantName: String,
        address: String,
        items: [DemoItemTemplate],
        subtotal: Decimal,
        tax: Decimal
    ) -> String {
        let itemLines = items.map { item in
            "\(item.name) \(item.totalPrice.formatted(.number.precision(.fractionLength(2))))"
        }
        let total = subtotal + tax

        return ([merchantName, address] + itemLines + [
            "SUBTOTAL \(subtotal.formatted(.number.precision(.fractionLength(2))))",
            "TAX \(tax.formatted(.number.precision(.fractionLength(2))))",
            "TOTAL \(total.formatted(.number.precision(.fractionLength(2))))"
        ]).joined(separator: "\n")
    }
}

private struct DemoItemTemplate {
    let name: String
    let brand: String?
    let category: String
    let quantity: Int
    let unitPrice: Decimal
    let totalPrice: Decimal
}
