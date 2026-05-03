import SwiftUI
import Foundation
import Supabase

struct HomeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showAuthSheet = false
    @State private var animatedPoints: Int = 0
    @State private var isAppearing = false 
    @State private var isLoading = true
    @State private var categories: [HomeCategory] = []
    @State private var nearbyStores: [NearbyStoreItem] = []
    @State private var newStores: [NearbyStoreItem] = []
    @State private var isFilterLoading = false
    @State private var curatedStores: [NearbyStoreItem] = []
    @State private var featuredStore: NearbyStoreItem?
    @State private var featuredProducts: [ProductItem] = []
    @State private var deliveryType: String = "Recogida en tienda"

    @State private var categoriesAreSticky: Bool = false
    @State private var isRefreshing: Bool = false
    @State private var navigateToAllNearby: Bool = false

    private let locationManager = LocationManager.shared    
    let onExploreTap: () -> Void

    /// Scroll threshold at which the categories transition to sticky pills
    private let stickyThreshold: CGFloat = 20
    /// Height of the in-flow category area (must match the frame)
    private let categoryAreaHeight: CGFloat = 108



    var body: some View {
        Group {
            if isLoading {
                HomeSkeletonView()
                    .transition(.opacity.animation(.easeOut(duration: 0.3)))
            } else {
                VStack(spacing: 0) {
                    // ── Fixed Header ──
                    VStack(spacing: 0) {
                        welcomeHeader
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                        
                        // Sticky compact pills — slide in when categories scroll past header
                        if categoriesAreSticky {
                            stickyPillCategories
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .background(Color.brandBackground)
                    .zIndex(1)
                    .animation(.spring(response: 0.28, dampingFraction: 0.88), value: categoriesAreSticky)
                    
                    // ── Scrollable Content ──
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // ── Pull-to-Refresh Indicator ──
                            GeometryReader { geo in
                                let pullOffset = geo.frame(in: .global).minY
                                HStack {
                                    Spacer()
                                    if isRefreshing {
                                        ProgressView()
                                            .tint(.secondary)
                                    }
                                    Spacer()
                                }
                                .onChange(of: pullOffset) { _, newValue in
                                    if newValue > 200 && !isRefreshing {
                                        triggerRefresh()
                                    }
                                }
                            }
                            .frame(height: isRefreshing ? 40 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isRefreshing)
                            
                            VStack(spacing: 24) {
                                // ── Category Area ──
                                ZStack {
                                    inFlowCategories
                                        .opacity(categoriesAreSticky ? 0 : 1)
                                }
                                .frame(height: categoryAreaHeight)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onChange(of: geo.frame(in: .global).minY) { _, newMinY in
                                                let shouldBeSticky = newMinY < stickyThreshold + 60
                                                if shouldBeSticky != categoriesAreSticky {
                                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                                                        categoriesAreSticky = shouldBeSticky
                                                    }
                                                }
                                            }
                                    }
                                )
                                
                                storesSection
                                
                                // ── Discovery Sections ──
                                if let store = featuredStore, !featuredProducts.isEmpty {
                                    FeaturedStoreSectionView(
                                        store: store,
                                        products: featuredProducts,
                                        categoryEmoji: categories.first(where: { $0.id == store.categoryId })?.emoji
                                    )
                                    .padding(.top, 16)
                                }
                                
                                curatedSection
                                    .padding(.top, 8)
                                

                                newStoresSection
                                    .padding(.top, 16)
                            }
                            .padding(.bottom, 32)
                        }
                    }
                }
                .background(Color.brandBackground)
            }
        }
        .background(Color.brandBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                if isLoading {
                    locationManager.requestPermission()
                    locationManager.startUpdatingLocation()
                    if let userId = authViewModel.currentUser?.id {
                        await FavoritesManager.shared.fetchFavorites(userId: userId)
                    }
                    if categories.isEmpty { await fetchCategories() }
                    await fetchStores()
                }
                
                // Estos los refrescamos siempre o al menos aseguramos que corran
                await fetchCuratedStores()

                await fetchNewStores()
                await fetchFeaturedData()
                
                if isLoading {
                    withAnimation { isLoading = false; isAppearing = true }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToAllNearby) {
            NearbyStoresFullView(stores: nearbyStores)
        }
        .onChange(of: authViewModel.userProfile) { _, newProfile in
            if let points = newProfile?.points { animatePoints(to: points) }
            if let userId = authViewModel.currentUser?.id {
                Task { await FavoritesManager.shared.fetchFavorites(userId: userId) }
            }
        }
    }


    private var welcomeHeader: some View {
        HStack(alignment: .center) {
            Menu {
                Button("Recogida en tienda") {
                    deliveryType = "Recogida en tienda"
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                Button("Llevar a casa") { }
                    .disabled(true)
            } label: {
                HStack(spacing: 4) {
                    Text(deliveryType)
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.black)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            HStack(spacing: 16) {
                // Notificaciones
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                
                Button { } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.yellow)
                        Text("\(animatedPoints)")
                            .font(.system(size: 15, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.black)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }

    private func fetchCategories() async {
        do {
            let fetchedCategories: [HomeCategory] = try await SupabaseManager.shared.client
                .from("categories")
                .select()
                .order("sort_order", ascending: true)
                .execute()
                .value
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.categories = fetchedCategories
                }
            }
        } catch {
            print("Error cargando categorías: \(error)")
        }
    }
    
    private func fetchStores() async {
        await MainActor.run {
            isFilterLoading = true
        }

        do {
            // 1. Cargar y mostrar locales inmediatamente
            let fetchedStores: [NearbyStoreItem] = try await SupabaseManager.shared.client
                .from("stores")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                self.nearbyStores = fetchedStores.map { store in
                    var updated = store
                    if let catId = store.categoryId {
                        updated.categoryName = self.categories.first(where: { $0.id == catId })?.name
                    }
                    return updated
                }
                // Ya podemos quitar el loading
                self.isFilterLoading = false
            }

            // 2. Cargar datos de productos para verificar ofertas de forma asíncrona
            do {
                let productsWithPrices: [ProductItem] = try await SupabaseManager.shared.client
                    .from("products")
                    .select()
                    .execute()
                    .value
                
                let offerStoreIds = Set(productsWithPrices.filter { product in
                    let hasDiscount = (product.originalPrice ?? 0) > product.price
                    return hasDiscount || product.isFlashOffer
                }.compactMap { $0.storeId })

                await MainActor.run {
                    self.nearbyStores = fetchedStores.map { store in
                        var updated = store
                        updated.hasOffers = offerStoreIds.contains(store.id)
                        // Preservar nombre de categoría
                        if let catId = store.categoryId {
                            updated.categoryName = self.categories.first(where: { $0.id == catId })?.name
                        }
                        return updated
                    }
                    self.isFilterLoading = false
                }
            } catch {
                print("Aviso: No se pudieron cargar las ofertas: \(error)")
                await MainActor.run { self.isFilterLoading = false }
            }
        } catch {
            print("Error crítico cargando locales: \(error)")
            await MainActor.run { self.isFilterLoading = false }
        }
    }

    private func fetchFeaturedData() async {
        do {
            // Traemos una muestra de locales para elegir uno con productos
            let allStores: [NearbyStoreItem] = try await SupabaseManager.shared.client
                .from("stores")
                .select()
                .limit(20)
                .execute()
                .value
            
            for store in allStores.shuffled() {
                let products: [ProductItem] = try await SupabaseManager.shared.client
                    .from("products")
                    .select()
                    .eq("store_id", value: store.id)
                    .not("original_price", operator: .is, value: "null") // Solo productos con descuento
                    .limit(6)
                    .execute()
                    .value
                
                // Filtrar también en Swift para asegurar que original > actual (por si acaso)
                let discountedProducts = products.filter { p in
                    if let original = p.originalPrice {
                        return original > p.price
                    }
                    return false
                }
                
                if !discountedProducts.isEmpty {
                    await MainActor.run {
                        self.featuredStore = store
                        self.featuredProducts = discountedProducts
                    }
                    return
                }
            }
        } catch {
            print("Error fetching featured data: \(error)")
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
                    self.newStores = fetched
                }
            }
        } catch {
            print("Error fetching new stores: \(error)")
        }
    }
    


    private func triggerRefresh() {
        guard !isRefreshing else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation { isRefreshing = true }
        
        Task {
            async let cats: () = fetchCategories()
            async let stores: () = fetchStores()
            async let curated: () = fetchCuratedStores()
            async let newS: () = fetchNewStores()
            async let featured: () = fetchFeaturedData()
            _ = await (cats, stores, curated, newS, featured)
            
            // Minimum display time so the user sees the spinner
            try? await Task.sleep(for: .milliseconds(600))
            await MainActor.run {
                withAnimation { isRefreshing = false }
            }
        }
    }

    private func animatePoints(to target: Int) {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            animatedPoints = target
        }
    }

    // ── In-Flow Categories (Large vertical icons) ──
    private var inFlowCategories: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryResultsView(category: category)) {
                        VStack(spacing: 8) {
                            Text(category.emoji)
                                .font(.system(size: 34))
                            
                            Text(category.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.secondary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .frame(minWidth: 74)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .frame(height: 100)
    }
    
    // ── Sticky Pill Categories (Compact, dropdown-style) ──
    private var stickyPillCategories: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryResultsView(category: category)) {
                        HStack(spacing: 6) {
                            Text(category.emoji)
                                .font(.system(size: 15))
                            Text(category.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.black)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.black.opacity(0.04))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .frame(height: 48)
        .padding(.bottom, 4)
    }

    private var storesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .lastTextBaseline) {
                Text("Cerca de ti")
                    .font(.title2.weight(.bold))
                Spacer()
                NavigationLink(destination: NearbyStoresFullView(stores: nearbyStores)) {
                    Text("Ver más")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.brandBlue)
                }
            }
            .padding(.horizontal, 16)
            
            if nearbyStores.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "storefront")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("No hay locales cercanos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(nearbyStores.prefix(10)) { store in 
                            NearbyStoreCardHorizontalView(store: store)
                        }
                        
                        if nearbyStores.count >= 10 {
                            Button {
                                navigateToAllNearby = true
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color.brandBlue)
                                    
                                    Text("Ver más")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Color.brandBlue)
                                }
                                .frame(width: 140, height: 245)
                                .background(Color.brandBlue.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                }
            }
        }
    }

    private var curatedSection: some View {
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
    }

    private var newStoresSection: some View {
        Group {
            if !newStores.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Recién llegado a NEXE")
                        .font(.title2.weight(.bold))
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 24) {
                        ForEach(newStores) { store in
                            NearbyStoreCardVerticalView(store: store)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

}

