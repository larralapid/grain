import Foundation
import SwiftData

class AnalyticsService: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func generateSpendingAnalytics(for period: AnalyticsPeriod, startDate: Date, endDate: Date) async -> SpendingAnalytics? {
        let predicate = #Predicate<Receipt> { receipt in
            receipt.date >= startDate && receipt.date <= endDate
        }
        
        let descriptor = FetchDescriptor<Receipt>(predicate: predicate)
        
        do {
            let receipts = try modelContext.fetch(descriptor)
            
            let totalSpent = receipts.reduce(Decimal(0)) { total, receipt in
                total + receipt.total
            }
            
            let categoryBreakdown = calculateCategoryBreakdown(from: receipts)
            let brandBreakdown = calculateBrandBreakdown(from: receipts)
            let merchantBreakdown = calculateMerchantBreakdown(from: receipts)
            
            let averageTransactionAmount = receipts.isEmpty ? Decimal(0) : totalSpent / Decimal(receipts.count)
            let transactionCount = receipts.count
            
            let topCategories = Array(categoryBreakdown.sorted { $0.value > $1.value }.prefix(10).map { $0.key })
            let topBrands = Array(brandBreakdown.sorted { $0.value > $1.value }.prefix(10).map { $0.key })
            let topMerchants = Array(merchantBreakdown.sorted { $0.value > $1.value }.prefix(10).map { $0.key })
            
            let taxDeductibleAmount = calculateTaxDeductibleAmount(from: receipts)
            
            return SpendingAnalytics(
                period: period,
                startDate: startDate,
                endDate: endDate,
                totalSpent: totalSpent,
                categoryBreakdown: categoryBreakdown,
                brandBreakdown: brandBreakdown,
                merchantBreakdown: merchantBreakdown,
                averageTransactionAmount: averageTransactionAmount,
                transactionCount: transactionCount,
                topCategories: topCategories,
                topBrands: topBrands,
                topMerchants: topMerchants,
                taxDeductibleAmount: taxDeductibleAmount
            )
        } catch {
            print("Error generating analytics: \(error)")
            return nil
        }
    }
    
    private func calculateCategoryBreakdown(from receipts: [Receipt]) -> [String: Decimal] {
        var breakdown: [String: Decimal] = [:]
        
        for receipt in receipts {
            for item in receipt.items {
                let category = item.category ?? "Uncategorized"
                breakdown[category, default: 0] += item.totalPrice
            }
        }
        
        return breakdown
    }
    
    private func calculateBrandBreakdown(from receipts: [Receipt]) -> [String: Decimal] {
        var breakdown: [String: Decimal] = [:]
        
        for receipt in receipts {
            for item in receipt.items {
                let brand = item.brand ?? "Unknown Brand"
                breakdown[brand, default: 0] += item.totalPrice
            }
        }
        
        return breakdown
    }
    
    private func calculateMerchantBreakdown(from receipts: [Receipt]) -> [String: Decimal] {
        var breakdown: [String: Decimal] = [:]
        
        for receipt in receipts {
            breakdown[receipt.merchantName, default: 0] += receipt.total
        }
        
        return breakdown
    }
    
    private func calculateTaxDeductibleAmount(from receipts: [Receipt]) -> Decimal {
        return receipts.reduce(Decimal(0)) { total, receipt in
            if receipt.category == "Business" || receipt.category == "Medical" || receipt.category == "Charitable" {
                return total + receipt.total
            }
            return total
        }
    }
    
    func getBrandSpending(for brand: String, in period: DateInterval) async -> [PricePoint] {
        let predicate = #Predicate<ReceiptItem> { item in
            item.brand == brand &&
            item.receipt != nil &&
            item.receipt!.date >= period.start &&
            item.receipt!.date <= period.end
        }
        
        let descriptor = FetchDescriptor<ReceiptItem>(predicate: predicate)
        
        do {
            let items = try modelContext.fetch(descriptor)
            return items.compactMap { item in
                guard let receipt = item.receipt else { return nil }
                return PricePoint(
                    price: item.totalPrice,
                    date: receipt.date,
                    merchantName: receipt.merchantName
                )
            }
        } catch {
            print("Error fetching brand spending: \(error)")
            return []
        }
    }
    
    func getSpendingTrends(for category: String, groupedBy period: AnalyticsPeriod) async -> [SpendingTrend] {
        let predicate = #Predicate<ReceiptItem> { item in
            item.category == category
        }
        
        let descriptor = FetchDescriptor<ReceiptItem>(predicate: predicate)
        
        do {
            let items = try modelContext.fetch(descriptor)
            let groupedItems = groupItemsByPeriod(items, period: period)
            
            return groupedItems.map { (dateKey, items) in
                let totalSpent = items.reduce(Decimal(0)) { $0 + $1.totalPrice }
                return SpendingTrend(
                    period: dateKey,
                    amount: totalSpent,
                    transactionCount: items.count
                )
            }.sorted { $0.period < $1.period }
        } catch {
            print("Error fetching spending trends: \(error)")
            return []
        }
    }

    func getProductTrendReport(for productName: String, category: String? = nil, months: Int = 6) async -> ProductTrendReport {
        let predicate = #Predicate<ReceiptItem> { item in
            item.name == productName && item.receipt != nil
        }

        let descriptor = FetchDescriptor<ReceiptItem>(predicate: predicate)

        do {
            let items = try modelContext.fetch(descriptor)
            let itemsWithReceipts = items.compactMap { item -> (ReceiptItem, Receipt)? in
                guard let receipt = item.receipt else { return nil }
                return (item, receipt)
            }

            let groupedByMonth = Dictionary(grouping: itemsWithReceipts) { pair in
                Calendar.current.dateInterval(of: .month, for: pair.1.date)?.start ?? pair.1.date
            }

            let monthlyTrends = groupedByMonth.map { monthStart, monthPairs in
                let monthItems = monthPairs.map(\.0)
                let totalSpend = monthItems.reduce(Decimal(0)) { $0 + $1.totalPrice }
                let averagePrice = monthItems.isEmpty ? Decimal(0) : totalSpend / Decimal(monthItems.count)
                return ProductMonthlyTrend(
                    monthStart: monthStart,
                    averagePrice: averagePrice,
                    totalSpend: totalSpend,
                    purchaseCount: monthItems.count
                )
            }
            .sorted { $0.monthStart < $1.monthStart }

            let clippedMonthlyTrends = Array(monthlyTrends.suffix(months))
            let forecastAveragePrice = calculateLinearForecast(for: clippedMonthlyTrends.map(\.averagePrice))
            let forecastTotalSpend = calculateLinearForecast(for: clippedMonthlyTrends.map(\.totalSpend))

            let retailerComparison = Dictionary(grouping: items, by: { $0.receipt?.merchantName ?? "Unknown" })
                .map { retailer, retailerItems in
                    let total = retailerItems.reduce(Decimal(0)) { $0 + $1.totalPrice }
                    let averagePrice = retailerItems.isEmpty ? Decimal(0) : total / Decimal(retailerItems.count)
                    return RetailerPriceComparison(
                        retailer: retailer,
                        averagePrice: averagePrice,
                        purchaseCount: retailerItems.count
                    )
                }
                .sorted { $0.purchaseCount > $1.purchaseCount }

            let categoryComparison: ProductCategoryComparison?
            if let category, !category.isEmpty {
                let categoryPredicate = #Predicate<ReceiptItem> { item in
                    item.category == category
                }
                let categoryDescriptor = FetchDescriptor<ReceiptItem>(predicate: categoryPredicate)
                let categoryItems = try modelContext.fetch(categoryDescriptor)
                let categoryAverage = categoryItems.isEmpty
                    ? Decimal(0)
                    : categoryItems.reduce(Decimal(0)) { $0 + $1.totalPrice } / Decimal(categoryItems.count)
                let productAverage = items.isEmpty
                    ? Decimal(0)
                    : items.reduce(Decimal(0)) { $0 + $1.totalPrice } / Decimal(items.count)

                categoryComparison = ProductCategoryComparison(
                    categoryName: category,
                    productAveragePrice: productAverage,
                    categoryAveragePrice: categoryAverage,
                    difference: productAverage - categoryAverage
                )
            } else {
                categoryComparison = nil
            }

            return ProductTrendReport(
                productName: productName,
                monthlyTrends: clippedMonthlyTrends,
                forecastAveragePrice: forecastAveragePrice,
                forecastTotalSpend: forecastTotalSpend,
                retailerComparison: retailerComparison,
                categoryComparison: categoryComparison
            )
        } catch {
            return ProductTrendReport(
                productName: productName,
                monthlyTrends: [],
                forecastAveragePrice: nil,
                forecastTotalSpend: nil,
                retailerComparison: [],
                categoryComparison: nil
            )
        }
    }

    func getRetailerTrendReport(for retailerName: String, months: Int = 6) async -> RetailerTrendReport {
        let receiptPredicate = #Predicate<Receipt> { receipt in
            receipt.merchantName == retailerName
        }
        let receiptDescriptor = FetchDescriptor<Receipt>(predicate: receiptPredicate)

        do {
            let receipts = try modelContext.fetch(receiptDescriptor)
            let groupedByMonth = Dictionary(grouping: receipts) { receipt in
                Calendar.current.dateInterval(of: .month, for: receipt.date)?.start ?? receipt.date
            }

            let monthlyTrends = groupedByMonth.map { monthStart, monthReceipts in
                let totalSpend = monthReceipts.reduce(Decimal(0)) { $0 + $1.total }
                return RetailerMonthlyTrend(
                    monthStart: monthStart,
                    totalSpend: totalSpend,
                    receiptCount: monthReceipts.count
                )
            }
            .sorted { $0.monthStart < $1.monthStart }

            let clippedMonthlyTrends = Array(monthlyTrends.suffix(months))
            let forecastTotalSpend = calculateLinearForecast(for: clippedMonthlyTrends.map(\.totalSpend))

            let retailerItems = receipts.flatMap(\.items)
            let allItemsDescriptor = FetchDescriptor<ReceiptItem>()
            let allItems = try modelContext.fetch(allItemsDescriptor)
            let groupedRetailerItems = Dictionary(grouping: retailerItems, by: \.name)
            let groupedAllItems = Dictionary(grouping: allItems, by: \.name)

            let productComparisons = groupedRetailerItems.map { productName, itemsAtRetailer in
                let retailerAverage = averagePrice(for: itemsAtRetailer)
                let marketAverage = averagePrice(for: groupedAllItems[productName] ?? [])
                return RetailerProductComparison(
                    productName: productName,
                    retailerAveragePrice: retailerAverage,
                    marketAveragePrice: marketAverage,
                    difference: retailerAverage - marketAverage,
                    purchaseCount: itemsAtRetailer.count
                )
            }
            .sorted { $0.purchaseCount > $1.purchaseCount }

            return RetailerTrendReport(
                retailerName: retailerName,
                monthlyTrends: clippedMonthlyTrends,
                forecastTotalSpend: forecastTotalSpend,
                productComparisons: productComparisons
            )
        } catch {
            return RetailerTrendReport(
                retailerName: retailerName,
                monthlyTrends: [],
                forecastTotalSpend: nil,
                productComparisons: []
            )
        }
    }
    
    private func groupItemsByPeriod(_ items: [ReceiptItem], period: AnalyticsPeriod) -> [String: [ReceiptItem]] {
        var grouped: [String: [ReceiptItem]] = [:]
        
        let formatter = DateFormatter()
        
        switch period {
        case .weekly:
            formatter.dateFormat = "yyyy-'W'ww"
        case .monthly:
            formatter.dateFormat = "yyyy-MM"
        case .quarterly:
            formatter.dateFormat = "yyyy-'Q'Q"
        case .yearly:
            formatter.dateFormat = "yyyy"
        case .custom:
            formatter.dateFormat = "yyyy-MM-dd"
        }
        
        for item in items {
            guard let receipt = item.receipt else { continue }
            let key = formatter.string(from: receipt.date)
            grouped[key, default: []].append(item)
        }
        
        return grouped
    }

    private func averagePrice(for items: [ReceiptItem]) -> Decimal {
        guard !items.isEmpty else { return 0 }
        return items.reduce(Decimal(0)) { $0 + $1.totalPrice } / Decimal(items.count)
    }

    private func calculateLinearForecast(for values: [Decimal]) -> Decimal? {
        guard values.count >= 2 else { return nil }

        let points = values.enumerated().map { index, value in
            (x: Double(index), y: (value as NSDecimalNumber).doubleValue)
        }

        let count = Double(points.count)
        let sumX = points.reduce(0.0) { $0 + $1.x }
        let sumY = points.reduce(0.0) { $0 + $1.y }
        let sumXY = points.reduce(0.0) { $0 + ($1.x * $1.y) }
        let sumX2 = points.reduce(0.0) { $0 + ($1.x * $1.x) }

        let denominator = (count * sumX2) - (sumX * sumX)
        guard denominator != 0 else { return nil }

        let slope = ((count * sumXY) - (sumX * sumY)) / denominator
        let intercept = (sumY - slope * sumX) / count
        let nextX = Double(values.count)
        let forecast = max((slope * nextX) + intercept, 0)

        return Decimal(forecast)
    }
}

struct SpendingTrend {
    let period: String
    let amount: Decimal
    let transactionCount: Int
}

struct ProductMonthlyTrend {
    let monthStart: Date
    let averagePrice: Decimal
    let totalSpend: Decimal
    let purchaseCount: Int
}

struct ProductCategoryComparison {
    let categoryName: String
    let productAveragePrice: Decimal
    let categoryAveragePrice: Decimal
    let difference: Decimal
}

struct RetailerPriceComparison {
    let retailer: String
    let averagePrice: Decimal
    let purchaseCount: Int
}

struct ProductTrendReport {
    let productName: String
    let monthlyTrends: [ProductMonthlyTrend]
    let forecastAveragePrice: Decimal?
    let forecastTotalSpend: Decimal?
    let retailerComparison: [RetailerPriceComparison]
    let categoryComparison: ProductCategoryComparison?
}

struct RetailerMonthlyTrend {
    let monthStart: Date
    let totalSpend: Decimal
    let receiptCount: Int
}

struct RetailerProductComparison {
    let productName: String
    let retailerAveragePrice: Decimal
    let marketAveragePrice: Decimal
    let difference: Decimal
    let purchaseCount: Int
}

struct RetailerTrendReport {
    let retailerName: String
    let monthlyTrends: [RetailerMonthlyTrend]
    let forecastTotalSpend: Decimal?
    let productComparisons: [RetailerProductComparison]
}
