import SwiftUI
import SwiftData

struct ReceiptListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Receipt.date, order: .reverse) private var receipts: [Receipt]
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    private var filteredReceipts: [Receipt] {
        var filtered = receipts
        
        if !searchText.isEmpty {
            filtered = filtered.filter { receipt in
                receipt.merchantName.localizedCaseInsensitiveContains(searchText) ||
                receipt.items.contains { item in
                    item.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        if selectedCategory != "All" {
            filtered = filtered.filter { receipt in
                receipt.category == selectedCategory
            }
        }
        
        return filtered
    }
    
    private var categories: [String] {
        let allCategories = Set(receipts.compactMap { $0.category })
        return ["All"] + Array(allCategories).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                searchAndFilter
                
                if filteredReceipts.isEmpty {
                    emptyState
                } else {
                    receiptsList
                }
            }
            .navigationTitle("Receipts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Receipt") {
                        // TODO: Add manual receipt entry
                    }
                }
            }
        }
        .searchable(text: $searchText)
    }
    
    private var searchAndFilter: some View {
        VStack {
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
    
    private var receiptsList: some View {
        List {
            ForEach(filteredReceipts) { receipt in
                NavigationLink(destination: ReceiptDetailView(receipt: receipt)) {
                    ReceiptRowView(receipt: receipt)
                }
            }
            .onDelete(perform: deleteReceipts)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "receipt")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Receipts")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Start by scanning your first receipt using the camera tab")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func deleteReceipts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredReceipts[index])
            }
        }
    }
}

struct ReceiptRowView: View {
    let receipt: Receipt
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(receipt.merchantName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(receipt.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if receipt.items.count > 0 {
                    Text("\(receipt.items.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(receipt.total.formatted(.currency(code: "USD")))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let category = receipt.category {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ReceiptListView()
        .modelContainer(for: [Receipt.self, ReceiptItem.self], inMemory: true)
}