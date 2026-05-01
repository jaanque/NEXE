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
    @State private var selectedCategoryId: UUID? 
    @State private var isFilterLoading = false

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

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            if isLoading {
                // Carga inicial (primera vez)
                HomeSkeletonView()
                    .transition(.opacity.animation(.easeOut(duration: 0.3)))
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        welcomeHeader
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        
                        if !categories.isEmpty {
                            VStack(spacing: 4) {
                                categoryScrollSection
                                HomeFilterChipsView(
                                    sortOrder: $sortOrder,
                                    showOnlyOpen: $showOnlyOpen,
                                    showOnlyPoints: $showOnlyPoints,
                                    showOnlyOffers: $showOnlyOffers
                                )
                            }
                            .padding(.top, 8)
                            .background(Color.brandBackground)
                            .zIndex(1)
                        }
                        
                        nearbyVerticalSection
                            .zIndex(0)
                    }
                    .padding(.bottom, 32)
                }
                .background(Color.brandBackground)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCategoryId)
                .animation(.easeInOut(duration: 0.3), value: isFilterLoading)
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if isLoading {
                Task {
                    locationManager.requestPermission()
                    locationManager.startUpdatingLocation()
                    if let userId = authViewModel.currentUser?.id {
                        await FavoritesManager.shared.fetchFavorites(userId: userId)
                    }
                    if categories.isEmpty { await fetchCategories() }
                    await fetchStores()
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

    private var welcomeHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola, \(authViewModel.currentUser?.email?.components(separatedBy: "@").first?.capitalized ?? "Usuario")")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text("¿Qué te apetece hoy?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onExploreTap) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.brandBackground)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
                
                Button { } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "star.circle.fill")
                            .foregroundStyle(.yellow)
                        Text("\(animatedPoints)")
                            .font(.system(size: 16, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color.brandBackground)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
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
                self.nearbyStores = fetchedStores
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

    private func animatePoints(to target: Int) {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            animatedPoints = target
        }
    }

    private var categoryScrollSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
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
            .padding(.top, 8)
            .padding(.bottom, 8) // Mantengo 8pt de padding inferior bajo el texto
        }
        .background(Color.brandBackground)
    }

    private var nearbyVerticalSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(selectedCategoryId == nil ? "Cerca de ti" : "Resultados")
                .font(.title2.weight(.bold))
                .padding(.horizontal, 16)
            
            if isFilterLoading {
                VStack(spacing: 28) {
                    ForEach(0..<3, id: \.self) { _ in
                        StoreSkeletonCard()
                            .padding(.horizontal, 16)
                    }
                }
            } else if filteredStores.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "storefront")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("No hay locales en esta categoría")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 24) {
                    ForEach(filteredStores) { store in 
                        NearbyStoreCardVerticalView(store: store)
                            .padding(.horizontal, 16) 
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isFilterLoading)
        .transition(.opacity)
    }
}
