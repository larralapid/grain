import SwiftUI
import SwiftData

struct ReceiptListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Receipt.date, order: .reverse) private var receipts: [Receipt]
    @State private var navigationPath = NavigationPath()
    @State private var showingManualEntry = false

    private var monthTotal: Decimal {
        let calendar = Calendar.current
        let now = Date()
        return receipts
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(Decimal(0)) { $0 + $1.total }
    }

    private var currentMonthName: String {
        Date().formatted(.dateTime.month(.abbreviated).year())
            .lowercased()
    }

    private var groupedReceipts: [(String, [Receipt])] {
        let calendar = Calendar.current
        let now = Date()
        let thisMonth = receipts.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }

        let grouped = Dictionary(grouping: thisMonth) { receipt in
            calendar.startOfDay(for: receipt.date)
        }

        return grouped.sorted { $0.key > $1.key }.map { (key, value) in
            let label = key.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
                .lowercased()
            return (label, value.sorted { $0.date > $1.date })
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    divider
                    recentHeader

                    if receipts.isEmpty {
                        emptyState
                    } else {
                        receiptJournal
                    }
                }
                .padding(.horizontal, 24)
            }
            .grainScreen()
            .navigationBarHidden(true)
            .navigationDestination(for: Receipt.self) { receipt in
                ReceiptDetailView(receipt: receipt)
            }
            .navigationDestination(for: ReceiptItem.self) { item in
                ItemAnalyticsView(item: item)
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualReceiptEntryView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("grain")
                .font(GrainTheme.mono(11, weight: .regular))
                .tracking(2.2)
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.top, 12)

            HStack(alignment: .firstTextBaseline) {
                Text(monthTotal.formatted(.currency(code: "USD")))
                    .font(GrainTheme.mono(36, weight: .regular))
                    .tracking(-1)
                    .foregroundColor(GrainTheme.textPrimary)

                Spacer()

                Text(currentMonthName)
                    .font(GrainTheme.mono(14))
                    .tracking(0.5)
                    .foregroundColor(GrainTheme.textSecondary)
                    .textCase(.lowercase)
            }
            .padding(.top, 20)

            Text("groceries + home. tap a receipt to explore.")
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textSecondary)
                .lineSpacing(4)
                .padding(.top, 6)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(GrainTheme.border)
            .frame(height: 1)
            .padding(.vertical, 24)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(GrainTheme.mono(10))
            .tracking(1.4)
            .textCase(.uppercase)
            .foregroundColor(GrainTheme.textSecondary)
            .padding(.bottom, 16)
    }

    private var recentHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            sectionLabel("recent")

            Spacer()

            Button {
                showingManualEntry = true
            } label: {
                Text("+ add")
                    .font(GrainTheme.mono(10))
                    .tracking(1.4)
                    .textCase(.uppercase)
                    .foregroundColor(GrainTheme.textPrimary)
                    .padding(.bottom, 16)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("add receipt manually")
        }
    }

    private var receiptJournal: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(groupedReceipts, id: \.0) { dateLabel, dayReceipts in
                dateHeaderView(dateLabel)

                ForEach(dayReceipts) { receipt in
                    NavigationLink(value: receipt) {
                        receiptRow(receipt)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func dateHeaderView(_ label: String) -> some View {
        VStack(spacing: 0) {
            Text(label)
                .font(GrainTheme.mono(10))
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundColor(GrainTheme.dateHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.bottom, 8)

            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
        }
    }

    private func receiptRow(_ receipt: Receipt) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text(receipt.merchantName)
                    .font(GrainTheme.mono(13))
                    .tracking(0.3)
                    .foregroundColor(GrainTheme.textPrimary)

                HStack(spacing: 0) {
                    let parts = [
                        receipt.date.formatted(.dateTime.weekday(.wide)).lowercased(),
                        "\(receipt.items.count) item\(receipt.items.count == 1 ? "" : "s")",
                        receipt.category ?? ""
                    ].filter { !$0.isEmpty }

                    Text(parts.joined(separator: " \u{00B7} "))
                        .foregroundColor(GrainTheme.textSecondary)
                    + Text(receipt.needsReview ? " \u{00B7} needs review" : "")
                        .foregroundColor(GrainTheme.priceUp)
                }
                .font(GrainTheme.mono(11))
                .tracking(0.2)
            }

            Spacer()

            Text(receipt.total.formatted(.currency(code: "USD")))
                .font(GrainTheme.mono(15))
                .foregroundColor(GrainTheme.textPrimary)
        }
        .padding(.vertical, 14)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("no receipts yet")
                .font(GrainTheme.mono(14))
                .foregroundColor(GrainTheme.textSecondary)

            Text("scan your first receipt using the scan tab")
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.dateHeader)
                .multilineTextAlignment(.center)

            Button {
                showingManualEntry = true
            } label: {
                Text("+ ADD RECEIPT")
                    .font(GrainTheme.mono(11, weight: .semibold))
                    .tracking(0.8)
                    .foregroundColor(GrainTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        Rectangle()
                            .stroke(GrainTheme.border, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("add receipt manually")
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

#Preview {
    ReceiptListView()
        .modelContainer(for: [Receipt.self, ReceiptItem.self], inMemory: true)
}
