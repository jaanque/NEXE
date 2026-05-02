import SwiftUI
import Foundation
import Supabase

struct HomeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showAuthSheet = false
    @State private var animatedPoints: Int = 0
    @State private var isAppearing = false 
    @State private var isLoading = true
    @State private var deliveryOption: Int = 0 // 0: Recogida, 1: Domicilio
    @State private var categories: [HomeCategory] = []
    @State private var nearbyStores: [NearbyStoreItem] = []
    @State private var newStores: [NearbyStoreItem] = []
    @State private var selectedCategoryId: UUID? 
    @State private var isFilterLoading = false
    @State private var curatedStores: [NearbyStoreItem] = []
    @State private var homeRewards: [RewardItem] = []
    @State private var selectedReward: RewardItem?
    private let inspirations = InspirationItem.samples

    private let locationManager = LocationManager.shared    
    let onExploreTap: () -> Void

    enum SortOrder {
        case closest
        case farthest
        case bestRated
        case worstRated
    }
    
    @State private var sortOrder: SortOrder = .closest
    @State private var showOnlyOpen: Bool = false
    @State private var showOnlyPoints: Bool = false
    @State private var showOnlyOffers: Bool = false

    private var filteredStores: [NearbyStoreItem] {
        var stores = nearbyStores
        if let selectedId = selectedCategoryId {
            stores = stores.filter { $0.categoryId == selectedId }
        }
        
        // Filtro "Abierto Ahora"
        if showOnlyOpen {
            stores = stores.filter { $0.isOpen }
        }
        
        // Filtro "Acepta Puntos"
        if showOnlyPoints {
            stores = stores.filter { $0.givesPoints }
        }
        
        // Filtro "Ofertas"
        if showOnlyOffers {
            stores = stores.filter { $0.hasOffers }
        }
        
        // Ordenar según selección
        switch sortOrder {
        case .closest:
            return stores.sorted { $0.distanceInMeters < $1.distanceInMeters }
        case .farthest:
            return stores.sorted { $0.distanceInMeters > $1.distanceInMeters }
        case .bestRated:
            return stores.sorted { a, b in
                if a.rating != b.rating {
                    return a.rating > b.rating
                }
                return a.reviewsCount > b.reviewsCount
            }
        case .worstRated:
            return stores.sorted { a, b in
                if a.rating != b.rating {
                    return a.rating < b.rating
                }
                return a.reviewsCount < b.reviewsCount
            }
        }
    }

    private var isFilterActive: Bool {
        selectedCategoryId != nil || showOnlyOpen || showOnlyPoints || showOnlyOffers
    }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            if isLoading {
                HomeSkeletonView()
                    .transition(.opacity.animation(.easeOut(duration: 0.3)))
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        welcomeHeader
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        
                        if !categories.isEmpty {
                            VStack(spacing: 14) {
                                categoryScrollSection
                                HomeFilterChipsView(
                                    sortOrder: $sortOrder,
                                    showOnlyOpen: $showOnlyOpen,
                                    showOnlyPoints: $showOnlyPoints,
                                    showOnlyOffers: $showOnlyOffers
                                )
                                .padding(.bottom, 4)
                            }
                        }
                        
                        storesSection
                        
                        if !isFilterActive {
                            inspirationsSection
                                .padding(.top, 8)
                            
                            curatedSection
                                .padding(.top, 8)
                            
                            homeRewardsSection
                                .padding(.top, 24)
                            newStoresSection
                                .padding(.top, 16)
                        }
                    }
                    .padding(.bottom, 32)
                }
                .background(Color.brandBackground)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCategoryId)
                .animation(.easeInOut(duration: 0.3), value: isFilterLoading)
            }
        }
        .fullScreenCover(isPresented: $showSearch) {
            SearchResultsView()
        }
        .sheet(item: $selectedReward) { reward in
            RewardCheckoutView(reward: reward)
        }
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
                await fetchHomeRewards()
                await fetchNewStores()
                
                if isLoading {
                    withAnimation { isLoading = false; isAppearing = true }
                }
            }
        }
        .onChange(of: authViewModel.userProfile) { _, newProfile in
            if let points = newProfile?.points { animatePoints(to: points) }
            if let userId = authViewModel.currentUser?.id {
                Task { await FavoritesManager.shared.fetchFavorites(userId: userId) }
            }
        }
    }

    @State private var showSearch = false

    private var welcomeHeader: some View {
        HStack(alignment: .center) {
            Menu {
                Button {
                    deliveryOption = 0
                } label: {
                    HStack {
                        Text("Recogida")
                        if deliveryOption == 0 { Image(systemName: "checkmark") }
                    }
                }
                
                Button { } label: {
                    Text("A domicilio (Próximamente)")
                }
                .disabled(true)
            } label: {
                HStack(spacing: 4) {
                    Text(deliveryOption == 0 ? "Recogida" : "A domicilio")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.black)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // Buscar
                Button {
                    showSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)

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
                // Si el filtro de ofertas no está activo, ya podemos quitar el loading
                if !showOnlyOffers {
                    self.isFilterLoading = false
                }
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

    private func fetchHomeRewards() async {
        do {
            let fetched: [RewardItem] = try await SupabaseManager.shared.client
                .from("rewards")
                .select("id, title, points_required, image_url, stock, stores(name)")
                .limit(10)
                .execute()
                .value
            
            let userPoints = authViewModel.userProfile?.points ?? 0
            let sorted = fetched.sorted { a, b in
                let canAffordA = a.points <= userPoints
                let canAffordB = b.points <= userPoints
                
                if canAffordA != canAffordB {
                    return canAffordA // Los que puede pagar van primero
                }
                return a.points < b.points // Si ambos están en el mismo estado, ordenar por puntos
            }
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.homeRewards = sorted
                }
            }
        } catch {
            print("Error fetching home rewards: \(error)")
        }
    }

    private func animatePoints(to target: Int) {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            animatedPoints = target
        }
    }

    private var categoryScrollSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.id) { category in
                    let isSelected = selectedCategoryId == category.id
                    CategoryBlobView(category: category, isSelected: isSelected)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                if selectedCategoryId == category.id {
                                    selectedCategoryId = nil
                                } else {
                                    selectedCategoryId = category.id
                                }
                                
                            }
                            isFilterLoading = true
                            Task {
                                try? await Task.sleep(nanoseconds: 400_000_000)
                                await MainActor.run {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isFilterLoading = false
                                    }
                                }
                            }
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var storesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(isFilterActive ? "Resultados" : "Cerca de ti")
                .font(.title2.weight(.bold))
                .padding(.horizontal, 16)
            
            if isFilterLoading {
                if isFilterActive {
                    // Skeleton vertical
                    VStack(spacing: 28) {
                        ForEach(0..<3, id: \.self) { _ in
                            StoreSkeletonCard(isVertical: true)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 16)
                        }
                    }
                } else {
                    // Skeleton horizontal
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<3, id: \.self) { _ in
                                StoreSkeletonCard()
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            } else if filteredStores.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "storefront")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("No hay locales con estos criterios")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                if isFilterActive {
                    // Lista Vertical de Resultados
                    VStack(spacing: 24) {
                        ForEach(filteredStores) { store in
                            NearbyStoreCardVerticalView(store: store)
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    // Carrusel Horizontal de Descubrimiento
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(filteredStores) { store in 
                                NearbyStoreCardHorizontalView(store: store)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isFilterLoading)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFilterActive)
    }

    private var inspirationsSection: some View {
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

    private var homeRewardsSection: some View {
        Group {
            if !homeRewards.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Recompensas NEXE")
                            .font(.title2.weight(.bold))
                        Text("Canjea tus puntos por productos exclusivos")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(homeRewards) { reward in
                                HomeRewardCard(reward: reward)
                                    .onTapGesture {
                                        selectedReward = reward
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                }
            }
        }
    }
}
}

struct HomeRewardCard: View {
    @Environment(AuthViewModel.self) private var authViewModel
    let reward: RewardItem
    
    var isLocked: Bool {
        (authViewModel.userProfile?.points ?? 0) < reward.points
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: reward.imageURL ?? "")) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 240, height: 150)
                .grayscale(isLocked ? 1 : 0)
                .opacity(isLocked ? 0.6 : 1)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                
                Text("\(reward.points) pts")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isLocked ? Color.gray : Color.brandGreen)
                    .clipShape(Capsule())
                    .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(isLocked ? .secondary : .primary)
                HStack(spacing: 4) {
                    Image(systemName: "storefront").font(.caption)
                    Text(reward.storeName).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
