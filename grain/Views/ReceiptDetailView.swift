import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var editedReceipt: Receipt?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                receiptHeader
                
                if !receipt.items.isEmpty {
                    itemsSection
                }
                
                financialSummary
                
                if let notes = receipt.notes, !notes.isEmpty {
                    notesSection
                }
                
                if let ocrText = receipt.ocrText, !ocrText.isEmpty {
                    ocrSection
                }
            }
            .padding()
        }
        .navigationTitle("Receipt Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditReceiptView(receipt: receipt)
        }
    }
    
    private var receiptHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(receipt.merchantName)
                .font(.title2)
                .fontWeight(.bold)
            
            if let address = receipt.merchantAddress {
                Text(address)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(receipt.date.formatted(date: .complete, time: .omitted))
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let category = receipt.category {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.headline)
            
            ForEach(receipt.items, id: \.id) { item in
                ItemRowView(item: item)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var financialSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Financial Summary")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Subtotal")
                    Spacer()
                    Text(receipt.subtotal.formatted(.currency(code: "USD")))
                }
                
                HStack {
                    Text("Tax")
                    Spacer()
                    Text(receipt.tax.formatted(.currency(code: "USD")))
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text(receipt.total.formatted(.currency(code: "USD")))
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            Text(receipt.notes ?? "")
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var ocrSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OCR Text")
                .font(.headline)
            
            Text(receipt.ocrText ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ItemRowView: View {
    let item: ReceiptItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                    .lineLimit(2)
                
                if let brand = item.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let category = item.category {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.totalPrice.formatted(.currency(code: "USD")))
                    .font(.body)
                    .fontWeight(.medium)
                
                if item.quantity > 1 {
                    Text("\(item.quantity) × \(item.unitPrice.formatted(.currency(code: "USD")))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
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
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
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
        merchantName: "Target",
        merchantAddress: "123 Main St",
        total: 45.67,
        subtotal: 42.34,
        tax: 3.33,
        category: "Groceries",
        notes: "Weekly shopping trip"
    )
    
    return ReceiptDetailView(receipt: receipt)
        .modelContainer(for: [Receipt.self, ReceiptItem.self], inMemory: true)
}