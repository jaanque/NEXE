import SwiftUI
import Supabase

struct SearchResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    @State private var searchGroups: [SearchStoreGroup] = []
    @State private var isLoading = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Search Bar
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Buscar huevos, leche...", text: $searchQuery)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await performSearch() }
                        }
                    
                    if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(Color(uiColor: .systemGray6))
                .clipShape(Capsule())
                
                Button {
                    // Acción carrito
                } label: {
                    Image(systemName: "cart")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            Divider()
            
            if isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else if searchGroups.isEmpty && !searchQuery.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("No hemos encontrado resultados")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
            } else {
                ScrollView {
                    VStack(spacing: 32) {
                        ForEach(searchGroups) { group in
                            VStack(alignment: .leading, spacing: 16) {
                                // Store Header
                                NavigationLink {
                                    StoreDetailView(store: group.store)
                                } label: {
                                    HStack(spacing: 12) {
                                        DemoImage(urlString: group.store.imageURL ?? "", cornerRadius: 8)
                                            .frame(width: 44, height: 44)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(group.store.name)
                                                .font(.headline)
                                                .foregroundStyle(.black)
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "bolt.fill")
                                                    .foregroundStyle(.green)
                                                Text("Recogida en \(group.store.nextOpeningTime ?? "15 min")")
                                                    .font(.caption)
                                                Text("•")
                                                Text("\(String(format: "%.1f", group.store.distanceInMeters / 1000.0)) km")
                                                    .font(.caption)
                                            }
                                            .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption.bold())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                                
                                // Product Scroll
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(group.products) { product in
                                            ProductSearchCard(product: product)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            
            Spacer()
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private func performSearch() async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isLoading = true
        do {
            // 1. Search products
            let products: [ProductItem] = try await SupabaseManager.shared.client
                .from("products")
                .select()
                .ilike("name", value: "%\(searchQuery)%")
                .execute()
                .value
            
            // 2. Group by storeId
            let grouped = Dictionary(grouping: products) { $0.storeId }
            
            // 3. Fetch stores for these IDs
            var groups: [SearchStoreGroup] = []
            for (storeId, storeProducts) in grouped {
                guard let sid = storeId else { continue }
                
                if let store: NearbyStoreItem = try? await SupabaseManager.shared.client
                    .from("stores")
                    .select()
                    .eq("id", value: sid)
                    .single()
                    .execute()
                    .value {
                    groups.append(SearchStoreGroup(store: store, products: storeProducts))
                }
            }
            
            await MainActor.run {
                self.searchGroups = groups
                self.isLoading = false
            }
        } catch {
            print("Error en la búsqueda: \(error)")
            await MainActor.run { self.isLoading = false }
        }
    }
}

struct SearchStoreGroup: Identifiable {
    var id: UUID { store.id }
    let store: NearbyStoreItem
    let products: [ProductItem]
}

struct ProductSearchCard: View {
    let product: ProductItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                DemoImage(urlString: product.imageURL ?? "", cornerRadius: 12)
                    .frame(width: 140, height: 140)
                
                Button {
                    // Agregar al carrito
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.green)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                
                Text(product.name)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 40, alignment: .top)
                
                HStack(spacing: 4) {
                    Image(systemName: "list.bullet.indent")
                        .font(.system(size: 10))
                    Text("Mucho stock")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.green)
                .padding(.top, 4)
            }
        }
        .frame(width: 140)
    }
}

#Preview {
    SearchResultsView()
}
