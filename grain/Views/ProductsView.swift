import SwiftUI
import SwiftData

struct ProductsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Product]
    @Query private var brands: [Brand]
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("View", selection: $selectedTab) {
                    Text("Products").tag(0)
                    Text("Brands").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedTab == 0 {
                    ProductListView(products: filteredProducts, searchText: $searchText)
                } else {
                    BrandListView(brands: filteredBrands, searchText: $searchText)
                }
            }
            .navigationTitle("Products & Brands")
            .searchable(text: $searchText)
        }
    }
    
    private var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        }
        
        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText) ||
            product.brand?.localizedCaseInsensitiveContains(searchText) ?? false ||
            product.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var filteredBrands: [Brand] {
        if searchText.isEmpty {
            return brands
        }
        
        return brands.filter { brand in
            brand.name.localizedCaseInsensitiveContains(searchText) ||
            brand.category?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
}

struct ProductListView: View {
    let products: [Product]
    @Binding var searchText: String
    
    var body: some View {
        if products.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "tag")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("No Products")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Products will appear here as you scan receipts")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(products) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductRowView(product: product)
                }
            }
        }
    }
}

struct BrandListView: View {
    let brands: [Brand]
    @Binding var searchText: String
    
    var body: some View {
        if brands.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "building.2")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("No Brands")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Brands will appear here as you scan receipts")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(brands) { brand in
                NavigationLink(destination: BrandDetailView(brand: brand)) {
                    BrandRowView(brand: brand)
                }
            }
        }
    }
}

struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                if let brand = product.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(product.category)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let avgPrice = product.averagePrice {
                    Text(avgPrice.formatted(.currency(code: "USD")))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("avg price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(product.priceHistory.count) purchases")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct BrandRowView: View {
    let brand: Brand
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(brand.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if let category = brand.category {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
                
                Text("\(brand.products.count) products")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(brand.totalSpent.formatted(.currency(code: "USD")))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(brand.transactionCount) transactions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                productHeader
                
                if !product.priceHistory.isEmpty {
                    priceHistorySection
                }
                
                if let description = product.description {
                    descriptionSection(description)
                }
            }
            .padding()
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var productHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let brand = product.brand {
                Text(brand)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(product.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                
                if let subcategory = product.subcategory {
                    Text(subcategory)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                }
            }
            
            if let avgPrice = product.averagePrice {
                Text("Average Price: \(avgPrice.formatted(.currency(code: "USD")))")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var priceHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price History")
                .font(.headline)
            
            ForEach(product.priceHistory.sorted(by: { $0.date > $1.date }), id: \.id) { pricePoint in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pricePoint.merchantName)
                            .font(.body)
                        Text(pricePoint.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(pricePoint.price.formatted(.currency(code: "USD")))
                        .font(.body)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
            
            Text(description)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct BrandDetailView: View {
    let brand: Brand
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                brandHeader
                
                if !brand.products.isEmpty {
                    productsSection
                }
            }
            .padding()
        }
        .navigationTitle(brand.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var brandHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let category = brand.category {
                Text(category)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Total Spent:")
                    Spacer()
                    Text(brand.totalSpent.formatted(.currency(code: "USD")))
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Transactions:")
                    Spacer()
                    Text("\(brand.transactionCount)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Average per Transaction:")
                    Spacer()
                    Text(brand.averageTransactionAmount.formatted(.currency(code: "USD")))
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Products")
                .font(.headline)
            
            ForEach(brand.products, id: \.id) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductRowView(product: product)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Data") {
                    NavigationLink("Export Data") {
                        Text("Export functionality coming soon")
                    }
                    
                    NavigationLink("Import Bank Transactions") {
                        Text("Bank import functionality coming soon")
                    }
                }
                
                Section("Tax") {
                    NavigationLink("Tax Categories") {
                        Text("Tax category settings coming soon")
                    }
                    
                    NavigationLink("Deduction Rules") {
                        Text("Deduction rules coming soon")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ProductsView()
        .modelContainer(for: [Product.self, Brand.self], inMemory: true)
}