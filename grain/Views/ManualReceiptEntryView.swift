import SwiftUI
import SwiftData

/// Form for creating a new `Receipt` entirely by hand (no scan).
/// Mirrors `EditReceiptView` but inserts a brand-new receipt + items on save.
struct ManualReceiptEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var merchantName: String = ""
    @State private var merchantAddress: String = ""
    @State private var category: String = ""
    @State private var notes: String = ""
    @State private var date: Date = .now
    @State private var subtotal: Decimal = 0
    @State private var tax: Decimal = 0
    @State private var total: Decimal = 0
    @State private var drafts: [ItemDraft] = []
    @State private var saveError: String?

    private var canSave: Bool {
        !merchantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section("basic information") {
                    TextField("Merchant Name", text: $merchantName)
                    TextField("Merchant Address", text: $merchantAddress)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("items") {
                    ForEach($drafts) { $draft in
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Item name", text: $draft.name)
                            HStack {
                                TextField("Brand", text: $draft.brand)
                                TextField("Category", text: $draft.category)
                            }
                            .font(.footnote)
                            Stepper("Qty \(draft.quantity)", value: $draft.quantity, in: 1...99)
                            HStack {
                                Text("unit").foregroundStyle(.secondary)
                                TextField("0.00", value: $draft.unitPrice, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                Text("total").foregroundStyle(.secondary)
                                TextField("0.00", value: $draft.totalPrice, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                            .font(.footnote)
                        }
                    }
                    .onDelete { drafts.remove(atOffsets: $0) }

                    Button("add item") {
                        drafts.append(ItemDraft(id: UUID(), name: "", quantity: 1, unitPrice: 0, totalPrice: 0))
                    }
                }

                Section("totals") {
                    totalField("Subtotal", value: $subtotal)
                    totalField("Tax", value: $tax)
                    totalField("Total", value: $total)
                }

                Section("categorization") {
                    TextField("Category", text: $category)
                }

                Section("notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .tint(GrainTheme.accent)
            .fontDesign(.monospaced)
            .navigationTitle("new receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") { save() }
                        .disabled(!canSave)
                }
            }
            .alert("couldn't save receipt", isPresented: saveErrorBinding) {
                Button("ok", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "")
            }
        }
    }

    /// Drives the save-failure alert off the optional error message.
    private var saveErrorBinding: Binding<Bool> {
        Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })
    }

    private func totalField(_ label: String, value: Binding<Decimal>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0.00", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }

    private func save() {
        let trimmedName = merchantName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let receipt = Receipt(
            date: date,
            merchantName: trimmedName,
            merchantAddress: merchantAddress.isEmpty ? nil : merchantAddress,
            total: total,
            subtotal: subtotal,
            tax: tax,
            category: category.isEmpty ? nil : category,
            notes: notes.isEmpty ? nil : notes
        )
        receipt.extractionSource = "manual"
        modelContext.insert(receipt)

        for draft in drafts {
            let item = ReceiptItem(
                name: draft.name,
                brand: draft.brand.trimmingCharacters(in: .whitespaces).isEmpty ? nil : draft.brand.trimmingCharacters(in: .whitespaces),
                category: draft.category.trimmingCharacters(in: .whitespaces).isEmpty ? nil : draft.category.trimmingCharacters(in: .whitespaces),
                quantity: draft.quantity,
                unitPrice: draft.unitPrice,
                totalPrice: draft.totalPrice
            )
            item.receipt = receipt
            receipt.items.append(item)
            modelContext.insert(item)
        }

        // Populate the product index (Product / Brand / PricePoint) from the entered items.
        ProductIndexer.index(receipt, in: modelContext)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            // Keep the sheet open so the entered data isn't lost; surface the failure.
            saveError = error.localizedDescription
        }
    }
}

private struct ItemDraft: Identifiable {
    let id: UUID
    var name: String
    var quantity: Int
    var unitPrice: Decimal
    var totalPrice: Decimal
    var brand: String = ""
    var category: String = ""
}

#Preview {
    ManualReceiptEntryView()
        .modelContainer(for: [Receipt.self, ReceiptItem.self], inMemory: true)
}
