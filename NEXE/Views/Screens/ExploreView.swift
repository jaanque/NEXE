import SwiftUI
import Foundation
import Supabase

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ExploreView: View {
    @Binding var selectedTab: AppTab
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var searchHistory: [SearchHistoryItem] = []
    private let trendingSearches = ["Café de especialidad", "Regalos artesanales", "Moda sostenible", "Comida vegana", "Tecnología"]
    
    @State private var searchedStores: [NearbyStoreItem] = []
    @State private var searchedProducts: [ProductItem] = []
    @State private var isSearching = false
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                exploreHeader
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                searchOverlayContent
                    .transition(.opacity)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await fetchSearchHistory()
            }
            triggerFocus()
        }
        .onChange(of: searchText) { _, newValue in
            if newValue.count >= 2 {
                Task { await performSearch(query: newValue) }
            } else if newValue.isEmpty {
                searchedStores = []
                searchedProducts = []
            }
        }
    }
    
    // MARK: - Helpers
    
    private var searchOverlayContent: some View {
        Group {
            if searchText.isEmpty {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Búsquedas recientes").font(.headline).padding(.horizontal, 16)
                        if searchHistory.isEmpty {
                            Text("No tienes búsquedas recientes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                        } else {
                            ForEach(searchHistory) { item in
                                HStack(spacing: 12) {
                                    Image(systemName: "clock").foregroundStyle(.secondary)
                                    Text(item.query).font(.body)
                                    Spacer()
                                    Image(systemName: "arrow.up.left").foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 16)
                                .contentShape(Rectangle())
                                .onTapGesture { 
                                    searchText = item.query
                                    isSearchFocused = false 
                                    Task { await saveSearch(query: item.query) }
                                }
                            }
                        }
                    }
                    
                    // Tendencias
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Lo más buscado").font(.headline)
                            Image(systemName: "flame.fill").foregroundStyle(.orange)
                        }.padding(.horizontal, 16)
                        
                        ForEach(Array(trendingSearches.enumerated()), id: \.element) { index, trend in
                            HStack(spacing: 16) {
                                Text("\(index + 1)").font(.subheadline.weight(.bold)).foregroundStyle(index < 3 ? Color.brandGreen : .secondary).frame(width: 24)
                                Text(trend).font(.body)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                            .onTapGesture { searchText = trend; isSearchFocused = false }
                        }
                    }
                }
            } else {
                searchResultsList
            }
        }
    }

    
    
    private func fetchSearchHistory() async {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        do {
            let fetched: [SearchHistoryItem] = try await SupabaseManager.shared.client
                .from("search_history")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(5)
                .execute()
                .value
            
            await MainActor.run {
                withAnimation {
                    self.searchHistory = fetched
                }
            }
        } catch {
            print("Error fetching search history: \(error)")
        }
    }
    
    private func performSearch(query: String) async {
        guard query.count >= 2 else { return }
        
        await MainActor.run { isSearching = true }
        
        do {
            // Buscar locales
            let stores: [NearbyStoreItem] = try await SupabaseManager.shared.client
                .from("stores")
                .select()
                .ilike("name", pattern: "%\(query)%")
                .limit(10)
                .execute()
                .value
            
            // Buscar productos
            let products: [ProductItem] = try await SupabaseManager.shared.client
                .from("products")
                .select()
                .ilike("name", pattern: "%\(query)%")
                .limit(10)
                .execute()
                .value
            
            await MainActor.run {
                withAnimation {
                    self.searchedStores = stores
                    self.searchedProducts = products
                    self.isSearching = false
                }
            }
        } catch {
            print("Error en búsqueda: \(error)")
            await MainActor.run { isSearching = false }
        }
    }
    
    private func saveSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let userId = authViewModel.currentUser?.id else { return }
        
        // Evitar duplicados recientes (opcional pero recomendado)
        if searchHistory.first?.query == query { return }
        
        do {
            try await SupabaseManager.shared.client
                .from("search_history")
                .insert(["user_id": userId.uuidString, "query": query])
                .execute()
            
            // Recargar historial para ver el cambio
            await fetchSearchHistory()
        } catch {
            print("Error saving search: \(error)")
        }
    }
    
    private func triggerFocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { isSearchFocused = true }
    }


    private var exploreHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.primary)
                TextField("Buscar en NEXE...", text: $searchText)
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await saveSearch(query: searchText) }
                    }
                if !searchText.isEmpty {
                    Button { searchText = ""; isSearchFocused = true } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color.brandBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.secondary.opacity(0.3), lineWidth: 1))

            Button("Cancelar") {
                selectedTab = .home
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchFocused)
    }

    private var searchResultsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if isSearching && searchedStores.isEmpty && searchedProducts.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                            .padding(.top, 40)
                        Text("Buscando locales y productos...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                } else if searchedStores.isEmpty && searchedProducts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(.quaternary)
                            .padding(.top, 60)
                        Text("No hemos encontrado resultados")
                            .font(.headline)
                        Text("Prueba con otros términos de búsqueda")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    // Sección de Locales
                    if !searchedStores.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tiendas")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            ForEach(searchedStores, id: \.id) { store in
                                StoreSearchResultRow(store: store)
                            }
                        }
                    }
                    
                    // Sección de Productos
                    if !searchedProducts.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Productos")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            ForEach(searchedProducts, id: \.id) { product in
                                ProductSearchResultRow(product: product)
                            }
                        }
                    }
                }
            }
            .padding(.top, 10)
        }
    }
}

// MARK: - Subviews de Búsqueda
struct StoreSearchResultRow: View {
    let store: NearbyStoreItem
    var body: some View {
        NavigationLink(destination: StoreDetailView(store: store)) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: store.imageURL ?? "")) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.name).font(.subheadline).fontWeight(.bold).foregroundStyle(.primary)
                    Text(store.description ?? "").font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}

struct ProductSearchResultRow: View {
    let product: ProductItem
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.imageURL ?? "")) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.1)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name).font(.subheadline).fontWeight(.bold).foregroundStyle(.primary)
                Text(product.price.formatted(.currency(code: "EUR"))).font(.caption).foregroundStyle(Color.brandGreen).fontWeight(.semibold)
            }
            Spacer()
            Image(systemName: "plus.circle.fill").font(.title3).foregroundStyle(Color.brandGreen)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Componente Categoría Líquida Sincronizado


// MARK: - Curated Components (Premium)

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
