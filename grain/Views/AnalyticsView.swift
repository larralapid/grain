import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var analyticsService: AnalyticsService
    @State private var selectedPeriod: AnalyticsPeriod = .monthly
    @State private var currentAnalytics: SpendingAnalytics?
    @State private var isLoading = false
    
    init(modelContext: ModelContext) {
        self._analyticsService = StateObject(wrappedValue: AnalyticsService(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    periodSelector
                    
                    if let analytics = currentAnalytics {
                        analyticsContent(analytics)
                    } else if isLoading {
                        ProgressView("Loading analytics...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .onAppear {
                loadAnalytics()
            }
        }
    }
    
    private var periodSelector: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                Text(period.rawValue.capitalized)
                    .tag(period)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: selectedPeriod) { _, _ in
            loadAnalytics()
        }
    }
    
    private func analyticsContent(_ analytics: SpendingAnalytics) -> some View {
        VStack(spacing: 20) {
            overviewCards(analytics)
            
            categoryChart(analytics)
            
            brandChart(analytics)
            
            merchantChart(analytics)
            
            taxDeductibleSection(analytics)
        }
    }
    
    private func overviewCards(_ analytics: SpendingAnalytics) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            AnalyticsCard(
                title: "Total Spent",
                value: analytics.totalSpent.formatted(.currency(code: "USD")),
                icon: "dollarsign.circle.fill",
                color: .blue
            )
            
            AnalyticsCard(
                title: "Transactions",
                value: "\(analytics.transactionCount)",
                icon: "cart.fill",
                color: .green
            )
            
            AnalyticsCard(
                title: "Average",
                value: analytics.averageTransactionAmount.formatted(.currency(code: "USD")),
                icon: "chart.line.uptrend.xyaxis",
                color: .orange
            )
            
            AnalyticsCard(
                title: "Tax Deductible",
                value: analytics.taxDeductibleAmount.formatted(.currency(code: "USD")),
                icon: "doc.text.fill",
                color: .purple
            )
        }
    }
    
    private func categoryChart(_ analytics: SpendingAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
            
            Chart {
                ForEach(Array(analytics.categoryBreakdown.prefix(5)), id: \.key) { category, amount in
                    BarMark(
                        x: .value("Category", category),
                        y: .value("Amount", amount)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func brandChart(_ analytics: SpendingAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Brands")
                .font(.headline)
            
            Chart {
                ForEach(Array(analytics.brandBreakdown.prefix(5)), id: \.key) { brand, amount in
                    BarMark(
                        x: .value("Brand", brand),
                        y: .value("Amount", amount)
                    )
                    .foregroundStyle(.green)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func merchantChart(_ analytics: SpendingAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Merchants")
                .font(.headline)
            
            Chart {
                ForEach(Array(analytics.merchantBreakdown.prefix(5)), id: \.key) { merchant, amount in
                    BarMark(
                        x: .value("Merchant", merchant),
                        y: .value("Amount", amount)
                    )
                    .foregroundStyle(.orange)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func taxDeductibleSection(_ analytics: SpendingAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tax Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Total Tax Deductible:")
                    Spacer()
                    Text(analytics.taxDeductibleAmount.formatted(.currency(code: "USD")))
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Percentage of Total:")
                    Spacer()
                    let percentage = analytics.totalSpent > 0 ? (analytics.taxDeductibleAmount / analytics.totalSpent) * 100 : 0
                    Text("\(percentage.formatted(.number.precision(.fractionLength(1))))%")
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Data Available")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Start scanning receipts to see your spending analytics")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    private func loadAnalytics() {
        isLoading = true
        
        let (startDate, endDate) = getDateRange(for: selectedPeriod)
        
        Task {
            let analytics = await analyticsService.generateSpendingAnalytics(
                for: selectedPeriod,
                startDate: startDate,
                endDate: endDate
            )
            
            await MainActor.run {
                self.currentAnalytics = analytics
                self.isLoading = false
            }
        }
    }
    
    private func getDateRange(for period: AnalyticsPeriod) -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .weekly:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            return (startOfWeek, endOfWeek)
            
        case .monthly:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
            return (startOfMonth, endOfMonth)
            
        case .quarterly:
            let currentQuarter = calendar.component(.quarter, from: now)
            let startOfQuarter = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: (currentQuarter - 1) * 3 + 1, day: 1)) ?? now
            let endOfQuarter = calendar.date(byAdding: DateComponents(month: 3, day: -1), to: startOfQuarter) ?? now
            return (startOfQuarter, endOfQuarter)
            
        case .yearly:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let endOfYear = calendar.dateInterval(of: .year, for: now)?.end ?? now
            return (startOfYear, endOfYear)
            
        case .custom:
            return (calendar.date(byAdding: .day, value: -30, to: now) ?? now, now)
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    AnalyticsView(modelContext: ModelContext(try! ModelContainer(for: Receipt.self, SpendingAnalytics.self)))
}