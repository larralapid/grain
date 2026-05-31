import SwiftUI
import SwiftData

/// Triage list of receipts the user flagged as incorrect. Tapping one opens the detail
/// view, where editing + saving corrects the data and clears the flag.
struct ReceiptReviewQueueView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Receipt> { $0.needsReview }, sort: \Receipt.date, order: .reverse)
    private var flagged: [Receipt]

    var body: some View {
        NavigationStack {
            ZStack {
                GrainTheme.bg.ignoresSafeArea()

                if flagged.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(flagged) { receipt in
                                NavigationLink(value: receipt) {
                                    row(receipt)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("review queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("close") { dismiss() }
                }
            }
            .navigationDestination(for: Receipt.self) { receipt in
                ReceiptDetailView(receipt: receipt)
            }
        }
    }

    private func row(_ receipt: Receipt) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text(receipt.merchantName)
                    .font(GrainTheme.mono(13))
                    .foregroundColor(GrainTheme.textPrimary)

                Text([receipt.extractionSource.map { "via \($0)" }, "\(receipt.items.count) items"]
                    .compactMap { $0 }
                    .joined(separator: " \u{00B7} "))
                    .font(GrainTheme.mono(11))
                    .foregroundColor(GrainTheme.textSecondary)
            }

            Spacer()

            Text(receipt.total.formatted(.currency(code: "USD")))
                .font(GrainTheme.mono(14))
                .foregroundColor(GrainTheme.textPrimary)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle().fill(GrainTheme.border).frame(height: 1)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("nothing to review")
                .font(GrainTheme.mono(14))
                .foregroundColor(GrainTheme.textSecondary)

            Text("flag a receipt as incorrect to triage it here")
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.dateHeader)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}
