import SwiftUI
import Supabase

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ExploreView: View {
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var isAppearing = false
    
    @State private var searchHistory = ["Zapatos de cuero", "Sushi", "Hamburguesa gourmet", "Peluquería", "Flores"]
    private let trendingSearches = ["Café de especialidad", "Regalos artesanales", "Moda sostenible", "Comida vegana", "Tecnología"]
    
    var focusToken: Int = 0
    @State private var isLoading = true
    @State private var isScrolled = false
    @State private var isSearchExpanded = false
    @State private var categories: [HomeCategory] = []
    @State private var selectedCategoryId: UUID? = nil
    @State private var nearbyStores: [NearbyStoreItem] = []
    @State private var flashOffers: [ProductItem] = []
    @State private var curatedStores: [NearbyStoreItem] = []
    private let inspirations = InspirationItem.samples
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ExploreHeader fijo cuando está expandido por scroll
                if isSearchExpanded && isScrolled {
                    exploreHeader
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if isLoading && !isSearchFocused {
                    ExploreSkeletonView()
                        .transition(.opacity.animation(.easeOut(duration: 0.4)))
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // TRACKING DE SCROLL
                            GeometryReader { proxy in
                                let offset = proxy.frame(in: .named("exploreScroll")).minY
                                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: offset)
                            }
                            .frame(height: 0)
                            
                            // Buscador integrado en el scroll para evitar saltos
                            exploreHeader
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                                .opacity(isScrolled ? 0 : 1)
                                .animation(.spring(), value: isScrolled)
                            
                            VStack(alignment: .leading, spacing: 32) {
                                if !isSearchFocused {
                                    VStack(alignment: .leading, spacing: 32) {
                                        // 1. Clima
                                        WeatherWidgetView()
                                            .padding(.horizontal, 16)
                                            .padding(.top, 10)
                                        
                                        // 2. Categorías
                                        if !categories.isEmpty {
                                            VStack(alignment: .leading, spacing: 16) {
                                                Text("Categorías")
                                                    .font(.title2.weight(.bold))
                                                    .padding(.horizontal, 16)
                                                
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 24) {
                                                        ForEach(categories) { category in
                                                            let isSelected = selectedCategoryId == category.id
                                                            Button {
                                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                                    selectedCategoryId = isSelected ? nil : category.id
                                                                }
                                                                UISelectionFeedbackGenerator().selectionChanged()
                                                            } label: {
                                                                CategoryBlobView(category: category, isSelected: isSelected)
                                                            }
                                                            .buttonStyle(.plain)
                                                        }
                                                    }
                                                    .padding(.horizontal, 16)
                                                }
                                            }
                                        }

                                        // 4. Ofertas Flash
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                Text("Ofertas Flash")
                                                    .font(.title2.weight(.bold))
                                                Image(systemName: "bolt.fill").foregroundStyle(.orange)
                                                Spacer()
                                                Text("Ver todas").font(.subheadline.weight(.semibold)).foregroundStyle(Color.brandGreen)
                                            }
                                            .padding(.horizontal, 16)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 16) {
                                                    ForEach(flashOffers) { product in
                                                        NearbyCardView(product: product)
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                        
                                        // 4. Inspiración
                                        VStack(alignment: .leading, spacing: 20) {
                                            Text("Inspiración")
                                                .font(.title2.weight(.bold))
                                                .padding(.horizontal, 16)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 30) {
                                                    ForEach(inspirations) { item in
                                                        InspirationCardView(item: item)
                                                    }
                                                }
                                                .padding(.horizontal, 25)
                                            }
                                        }
                                        
                                        // 5. NEXE Curated
                                        VStack(alignment: .leading, spacing: 20) {
                                            VStack(spacing: 8) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "laurel.leading")
                                                        .foregroundStyle(Color.brandGreen)
                                                    Text("NEXE Curated")
                                                        .font(.title2.weight(.bold))
                                                    Image(systemName: "laurel.trailing")
                                                        .foregroundStyle(Color.brandGreen)
                                                }
                                                Text("Selección exclusiva de joyas locales")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.horizontal, 16)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 20) {
                                                    if curatedStores.isEmpty {
                                                        CuratedCardView(title: "Artesanía Pura", store: "Taller Madera", image: "https://images.unsplash.com/photo-1581428982868-e410dd047a90?q=80&w=800&auto=format&fit=crop")
                                                        CuratedCardView(title: "Café de Autor", store: "Origen Coffee", image: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=800&auto=format&fit=crop")
                                                    } else {
                                                        ForEach(curatedStores) { store in
                                                            CuratedCardView(
                                                                title: store.description ?? "Selección NEXE",
                                                                store: store.name,
                                                                image: store.imageURL ?? "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80"
                                                            )
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                        
                                        // 5. Recién llegados
                                        if !nearbyStores.isEmpty {
                                            VStack(alignment: .leading, spacing: 20) {
                                                Text("Recién llegado a NEXE")
                                                    .font(.title2.weight(.bold))
                                                    .padding(.horizontal, 16)
                                                
                                                LazyVStack(spacing: 24) {
                                                    ForEach(nearbyStores) { store in
                                                        NearbyStoreCardVerticalView(store: store)
                                                            .padding(.horizontal, 16)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                                } else {
                                    searchOverlayContent
                                }
                            }
                            .refreshable {
                                await fetchCategories()
                                await fetchNewStores()
                                await fetchProducts()
                                await fetchCuratedStores()
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                            }
                            .transition(.opacity.animation(.easeIn(duration: 0.4)))
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .coordinateSpace(name: "exploreScroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            let threshold: CGFloat = -60
            let isPastThreshold = offset < threshold
            if isScrolled != isPastThreshold {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isScrolled = isPastThreshold
                }
            }
        }
        .onAppear {
            isAppearing = true
            Task {
                await fetchCategories()
                await fetchNewStores()
                await fetchProducts()
                await fetchCuratedStores()
                withAnimation {
                    isLoading = false
                }
            }
            if focusToken > 0 { triggerFocus() }
        }
    }
    
    // MARK: - Helpers
    
    private var searchOverlayContent: some View {
        Group {
            if searchText.isEmpty {
                VStack(alignment: .leading, spacing: 32) {
                    // Historial
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Búsquedas recientes").font(.headline).padding(.horizontal, 16)
                        ForEach(searchHistory.prefix(5), id: \.self) { search in
                            HStack(spacing: 12) {
                                Image(systemName: "clock").foregroundStyle(.secondary)
                                Text(search).font(.body)
                                Spacer()
                                Image(systemName: "arrow.up.left").foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                            .onTapGesture { searchText = search; isSearchFocused = false }
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
                searchResultsPlaceholder
            }
        }
    }

    private func fetchCategories() async {
        do {
            let fetched: [HomeCategory] = try await SupabaseManager.shared.client.from("categories").select().order("sort_order", ascending: true).execute().value
            await MainActor.run { withAnimation(.spring()) { self.categories = fetched } }
        } catch { print("Error: \(error)") }
    }
    
    private func fetchNewStores() async {
        do {
            let fetched: [NearbyStoreItem] = try await SupabaseManager.shared.client
                .from("stores")
                .select()
                .eq("is_new", value: true)
                .order("created_at", ascending: false)
                .execute()
                .value
            await MainActor.run {
                withAnimation(.spring()) {
                    self.nearbyStores = fetched
                }
            }
        } catch {
            print("Error fetching new stores: \(error)")
        }
    }

    private func fetchProducts() async {
        do {
            let fetched: [ProductItem] = try await SupabaseManager.shared.client
                .from("products")
                .select()
                .eq("is_flash_offer", value: true)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.flashOffers = fetched
                }
            }
        } catch {
            print("Error fetching products: \(error)")
        }
    }
    
    private func fetchCuratedStores() async {
        do {
            let fetched: [NearbyStoreItem] = try await SupabaseManager.shared.client
                .from("stores")
                .select()
                .gte("rating", value: 4.5)
                .limit(5)
                .execute()
                .value
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.curatedStores = fetched
                }
            }
        } catch {
            print("Error fetching curated stores: \(error)")
        }
    }
    
    private func triggerFocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { isSearchFocused = true }
    }
    
    private var exploreHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.primary)
                TextField("Buscar en NEXE...", text: $searchText).focused($isSearchFocused).submitLabel(.search)
                if !searchText.isEmpty {
                    Button { searchText = ""; isSearchFocused = true } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                }
            }
            .padding(.horizontal, 14).frame(height: 44).background(Color.brandBackground).clipShape(Capsule()).overlay(Capsule().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
            
            if isSearchFocused || isSearchExpanded {
                Button("Cancelar") { 
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { 
                        isSearchFocused = false
                        searchText = "" 
                        if isScrolled { isSearchExpanded = false }
                    } 
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchFocused)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchExpanded)
    }
    
    private var searchResultsPlaceholder: some View {
        VStack(spacing: 20) {
            Text("Buscando '\(searchText)'...").foregroundStyle(.secondary).padding(.top, 40)
            ProgressView()
        }.frame(maxWidth: .infinity)
    }
}

// MARK: - Componente Categoría Líquida Sincronizado
struct CategoryBlobView: View {
    let category: HomeCategory
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                BlobShape(seed: category.id.hashValue)
                    .fill(isSelected ? category.color.opacity(0.18) : Color.clear)
                    .frame(width: 78, height: 78)
                    .rotationEffect(.degrees(Double(abs(category.id.hashValue) % 360)))
                
                Text(category.emoji)
                    .font(.system(size: 40))
                    .shadow(color: .black.opacity(isSelected ? 0 : 0.08), radius: 2, x: 0, y: 1)
            }
            .frame(height: 84)
            
            Text(category.name)
                .font(.caption2.weight(.medium))
                .foregroundStyle(isSelected ? category.color : .primary)
                .lineLimit(1)
        }
    }
}

// MARK: - Curated Components (Premium)
struct CuratedCardView: View {
    let title: String
    let store: String
    let image: String
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: image)) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.1)
            }
            .frame(width: 200, height: 260)
            .overlay(
                LinearGradient(colors: [.black.opacity(0.6), .clear, .clear], startPoint: .bottom, endPoint: .top)
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(store)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
