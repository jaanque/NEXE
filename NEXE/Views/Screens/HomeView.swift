import SwiftUI
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
    @State private var storeFetchTask: Task<Void, Never>?
    
    let onExploreTap: () -> Void

    private var filteredStores: [NearbyStoreItem] {
        if let selectedId = selectedCategoryId {
            return nearbyStores.filter { $0.categoryId == selectedId }
        }
        return nearbyStores
    }


    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            if isLoading {
                HomeSkeletonView()
                    .transition(.opacity.animation(.easeOut(duration: 0.4)))
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        addressHeader
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        
                        HomeFilterChipsView()
                            .zIndex(0)
                        
                        if !categories.isEmpty {
                            categoryScrollSection
                                .zIndex(1)
                        }
                        
                        nearbyVerticalSection
                            .zIndex(0)
                    }
                    .padding(.bottom, 32)
                }
                .refreshable {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    await fetchCategories()
                    await fetchStores()
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    let successGenerator = UINotificationFeedbackGenerator()
                    successGenerator.notificationOccurred(.success)
                }
                .scrollBounceBehavior(.basedOnSize)
                .background(Color.brandBackground)
                .transition(.opacity.animation(.easeIn(duration: 0.4)))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCategoryId)
                .animation(.easeInOut(duration: 0.3), value: isFilterLoading)
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if isLoading {
                Task {
                    if let userId = authViewModel.currentUser?.id {
                        await FavoritesManager.shared.fetchFavorites(userId: userId)
                    }
                    if categories.isEmpty {
                        await fetchCategories()
                    }
                    await fetchStores()
                    
                    withAnimation {
                        isLoading = false
                        isAppearing = true
                    }
                }
            }
        }

        .onChange(of: authViewModel.userProfile) { _, newProfile in
            if let points = newProfile?.points {
                animatePoints(to: points)
            }
            if let userId = authViewModel.currentUser?.id {
                Task {
                    await FavoritesManager.shared.fetchFavorites(userId: userId)
                }
            }
        }
    }

    private var addressHeader: some View {
        HStack(spacing: 12) {
            Button(action: onExploreTap) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.primary)
                    Text("Buscar en NEXE...").font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                }.padding(.horizontal, 14).frame(height: 44).background(Color.brandBackground).clipShape(Capsule()).overlay(Capsule().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
            }.buttonStyle(.plain)
            Button { } label: {
                HStack(spacing: 4) {
                    Image(systemName: "star.circle.fill").foregroundStyle(.yellow)
                    Text("\(animatedPoints)").font(.subheadline.weight(.semibold).monospacedDigit()).foregroundStyle(.primary).contentTransition(.numericText())
                }.padding(.horizontal, 10).frame(height: 44).background(Color.brandBackground).clipShape(Capsule()).overlay(Capsule().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
            }.buttonStyle(.plain)
        }
    }

    // MARK: - Supabase Logic
    
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
            let fetchedStores: [NearbyStoreItem] = try await SupabaseManager.shared.client
                .from("stores")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            await MainActor.run {
                self.nearbyStores = fetchedStores
                self.isFilterLoading = false
            }
        } catch {
            print("Error fetching stores: \(error)")
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
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8) // Un poco de aire vertical para hit-testing
        }
        .background(Color.brandBackground) // Asegura que el área del scroll sea sólida para toques
    }
    
    private func getLegibleColor(for color: Color) -> Color {
        if color == .yellow || color.description.contains("FFD700") {
            return Color(red: 0.7, green: 0.5, blue: 0.0)
        }
        return color
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
        .animation(.easeInOut(duration: 0.3), value: isFilterLoading)
        .transition(.opacity)
    }
}



