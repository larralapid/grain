import SwiftUI
import UIKit

struct ReceiptDetailView: View {
    let receipt: Receipt
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingScanOverlay = false
    @State private var isEditing = false

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    merchantHeader
                    itemsSection
                    totalsSection
                    annotationSection
                }
                .padding(.horizontal, 24)
            }

            if showingScanOverlay {
                scanOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("\u{2190} back")
                        .font(GrainTheme.mono(12))
                        .foregroundColor(GrainTheme.textSecondary)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("view scan") {
                        showingScanOverlay = true
                    }
                    Button("edit receipt") {
                        isEditing = true
                    }
                    Button("delete", role: .destructive) {
                        modelContext.delete(receipt)
                        dismiss()
                    }
                } label: {
                    Text("\u{00B7}\u{00B7}\u{00B7}")
                        .font(GrainTheme.mono(18))
                        .tracking(3)
                        .foregroundColor(GrainTheme.textSecondary)
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditReceiptView(receipt: receipt)
        }
    }

    private var merchantHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(receipt.merchantName)
                .font(GrainTheme.mono(18))
                .foregroundColor(GrainTheme.textPrimary)
                .tracking(0.2)
                .padding(.top, 8)

            if let address = receipt.merchantAddress {
                Text(address)
                    .font(GrainTheme.mono(11))
                    .foregroundColor(GrainTheme.textSecondary)
                    .tracking(0.2)
                    .padding(.top, 4)
            }

            Text(receipt.date.formatted(.dateTime.month(.wide).day().year().hour().minute())
                .lowercased())
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.top, 2)
                .padding(.bottom, 24)
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ITEMS")
                .font(GrainTheme.mono(10))
                .tracking(1.4)
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.bottom, 12)

            ForEach(Array(receipt.items.enumerated()), id: \.element.id) { index, item in
                NavigationLink(value: item) {
                    itemRow(item, isAlt: index % 2 == 1)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func itemRow(_ item: ReceiptItem, isAlt: Bool) -> some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(GrainTheme.mono(12))
                    .foregroundColor(GrainTheme.textPrimary)
                    .tracking(0.1)

                if let brand = item.brand, !brand.isEmpty {
                    Text(brand.lowercased())
                        .font(GrainTheme.mono(10))
                        .tracking(0.6)
                        .textCase(.uppercase)
                        .foregroundColor(GrainTheme.textSecondary)
                }
            }

            Spacer()

            Text(item.totalPrice.formatted(.currency(code: "USD")))
                .font(GrainTheme.mono(13))
                .foregroundColor(GrainTheme.textPrimary)

            Text("\u{203A}")
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.border)
                .padding(.leading, 8)
        }
        .padding(.vertical, 10)
        .background(isAlt ? Color.white.opacity(0.02) : Color.clear)
    }

    private var totalsSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
                .padding(.top, 16)

            totalRow("subtotal", amount: receipt.subtotal)
            totalRow("tax", amount: receipt.tax)

            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
                .padding(.top, 8)

            HStack {
                Text("total")
                    .font(GrainTheme.mono(20))
                    .foregroundColor(GrainTheme.textPrimary)
                Spacer()
                Text(receipt.total.formatted(.currency(code: "USD")))
                    .font(GrainTheme.mono(20))
                    .foregroundColor(GrainTheme.textPrimary)
            }
            .padding(.vertical, 12)
        }
    }

    private func totalRow(_ label: String, amount: Decimal) -> some View {
        HStack {
            Text(label)
                .font(GrainTheme.mono(14))
                .foregroundColor(GrainTheme.textSecondary)
            Spacer()
            Text(amount.formatted(.currency(code: "USD")))
                .font(GrainTheme.mono(14))
                .foregroundColor(GrainTheme.textSecondary)
        }
        .padding(.vertical, 6)
    }

    private var annotationSection: some View {
        Group {
            if let category = receipt.category {
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle()
                        .fill(GrainTheme.border)
                        .frame(height: 1)
                        .padding(.top, 16)

                    Text("\(category.lowercased())\(receipt.notes.map { " \u{00B7} \($0.lowercased())" } ?? "")")
                        .font(GrainTheme.mono(11))
                        .foregroundColor(GrainTheme.dateHeader)
                        .tracking(0.2)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
            }
        }
    }

    private var scanOverlay: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1).opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if let imageData = receipt.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 260, height: 360)
                } else {
                    Rectangle()
                        .fill(GrainTheme.surface)
                        .frame(width: 260, height: 360)
                        .overlay(
                            Rectangle()
                                .stroke(GrainTheme.border, lineWidth: 0.5)
                        )
                        .overlay(
                            Text("no scan available")
                                .font(GrainTheme.mono(11))
                                .foregroundColor(GrainTheme.textSecondary)
                        )
                }

                Button("close") {
                    showingScanOverlay = false
                }
                .font(GrainTheme.mono(13))
                .foregroundColor(.white.opacity(0.7))
                .tracking(0.5)
            }
        }
    }
}

struct EditReceiptView: View {
    let receipt: Receipt
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var merchantName: String
    @State private var merchantAddress: String
    @State private var category: String
    @State private var notes: String
    @State private var date: Date

    init(receipt: Receipt) {
        self.receipt = receipt
        self._merchantName = State(initialValue: receipt.merchantName)
        self._merchantAddress = State(initialValue: receipt.merchantAddress ?? "")
        self._category = State(initialValue: receipt.category ?? "")
        self._notes = State(initialValue: receipt.notes ?? "")
        self._date = State(initialValue: receipt.date)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Merchant Name", text: $merchantName)
                    TextField("Merchant Address", text: $merchantAddress)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Categorization") {
                    TextField("Category", text: $category)
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveChanges() }
                }
            }
        }
    }

    private func saveChanges() {
        receipt.merchantName = merchantName
        receipt.merchantAddress = merchantAddress.isEmpty ? nil : merchantAddress
        receipt.category = category.isEmpty ? nil : category
        receipt.notes = notes.isEmpty ? nil : notes
        receipt.date = date
        receipt.updatedAt = Date()

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving receipt: \(error)")
        }
    }
}

#Preview {
    let receipt = Receipt(
        date: Date(),
        merchantName: "Corner Market",
        merchantAddress: "2847 Mission St, San Francisco",
        total: 42.90,
        subtotal: 29.94,
        tax: 2.10,
        category: "Groceries",
        notes: "weekday grocery run"
    )

    return NavigationStack {
        ReceiptDetailView(receipt: receipt)
    }
    .modelContainer(for: [Receipt.self, ReceiptItem.self], inMemory: true)
}
