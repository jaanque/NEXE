import SwiftUI
import Supabase

// MARK: - Blob Shape (Gota Suave y Redondeada)
struct BlobShape: Shape {
    let seed: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)
        
        let points = 8
        var vertices: [CGPoint] = []
        
        for i in 0..<points {
            let angle = Double(i) * (2.0 * .pi / Double(points))
            let randomValue = Double((abs((seed + i * 53).hashValue) % 100)) / 100.0
            let radius = (width / 2) * (0.8 + (randomValue * 0.2)) 
            
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            vertices.append(CGPoint(x: x, y: y))
        }
        
        path.move(to: CGPoint(x: (vertices[points-1].x + vertices[0].x) / 2, 
                             y: (vertices[points-1].y + vertices[0].y) / 2))
        
        for i in 0..<points {
            let current = vertices[i]
            let next = vertices[(i + 1) % points]
            let mid = CGPoint(x: (current.x + next.x) / 2, y: (current.y + next.y) / 2)
            path.addQuadCurve(to: mid, control: current)
        }
        
        path.closeSubpath()
        return path
    }
}

struct HomeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showAuthSheet = false
    @State private var animatedPoints: Int = 0
    @State private var isAppearing = false 
    @State private var isLoading = true
    @State private var categories: [HomeCategory] = []
    @State private var nearbyStores: [NearbyStoreItem] = []
    @State private var flashOffers: [ProductItem] = []
    @State private var rewardPointsProducts: [ProductItem] = []
    @State private var forYouProducts: [ProductItem] = []
    @State private var selectedCategoryId: UUID? 
    
    let onExploreTap: () -> Void

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // TÍTULO DE SECCIÓN UNIFICADO
                HStack {
                    Text("Inicio")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 12)
                
                addressHeader
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .background(Color.brandBackground)
                    .offset(y: isAppearing ? 0 : -10)
                    .opacity(isAppearing ? 1 : 0)
                    .zIndex(1)

                if isLoading {
                    HomeSkeletonView()
                        .transition(.opacity.animation(.easeOut(duration: 0.4)))
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) { // Espaciado unificado
                            HomeFilterChipsView()
                                .entranceAnimation(delay: 0.05, isAppearing: isAppearing)
                            
                            if !categories.isEmpty {
                                categoryScrollSection
                                    .entranceAnimation(delay: 0.1, isAppearing: isAppearing)
                            }
                            
                            Group {
                                flashOffersSection
                                rewardPointsSection
                                forYouSection
                                nearbyVerticalSection
                            }
                            .entranceAnimation(delay: 0.15, isAppearing: isAppearing)
                        }
                        .padding(.bottom, 28)
                    }
                    .refreshable {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        await fetchCategories()
                        await fetchStores()
                        await fetchProducts()
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        let successGenerator = UINotificationFeedbackGenerator()
                        successGenerator.notificationOccurred(.success)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .background(Color.brandBackground)
                    .transition(.opacity.animation(.easeIn(duration: 0.4)))
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                isAppearing = true
            }
            animatePoints(to: authViewModel.userProfile?.points ?? 0)
            
            Task {
                if let userId = authViewModel.currentUser?.id {
                    await FavoritesManager.shared.fetchFavorites(userId: userId)
                }
                await fetchCategories()
                await fetchStores()
                await fetchProducts()
                
                withAnimation {
                    isLoading = false
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
        do {
            let fetchedStores: [NearbyStoreItem] = try await SupabaseManager.shared.client
                .from("stores")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.nearbyStores = fetchedStores
                }
            }
        } catch {
            print("Error fetching stores: \(error)")
        }
    }
    
    private func fetchProducts() async {
        do {
            let allProducts: [ProductItem] = try await SupabaseManager.shared.client
                .from("products")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.flashOffers = allProducts.filter { $0.isFlashOffer }
                    self.rewardPointsProducts = allProducts.filter { $0.rewardPoints > 0 }
                    self.forYouProducts = allProducts.filter { $0.isForYou }
                }
            }
        } catch {
            print("Error fetching products: \(error)")
        }
    }

    private func animatePoints(to target: Int) {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            animatedPoints = target
        }
    }

    // MARK: - Sections

    private var categoryScrollSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 24) {
                ForEach(categories) { category in
                    let isSelected = selectedCategoryId == category.id
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            if selectedCategoryId == category.id {
                                selectedCategoryId = nil 
                            } else {
                                selectedCategoryId = category.id
                            }
                        }
                        UISelectionFeedbackGenerator().selectionChanged()
                    } label: {
                        VStack(spacing: 6) { 
                            ZStack {
                                // Gota proporcional al nuevo tamaño (78x78)
                                BlobShape(seed: category.name.hashValue)
                                    .fill(isSelected ? category.color.opacity(0.18) : Color.clear)
                                    .frame(width: 78, height: 78)
                                    .rotationEffect(.degrees(Double(abs(category.name.hashValue) % 360)))
                                
                                Text(category.emoji)
                                    .font(.system(size: 44)) // Más grandes como pediste
                                    .shadow(color: .black.opacity(isSelected ? 0 : 0.08), radius: 2, x: 0, y: 1)
                            }
                            .frame(height: 84) // Altura para que el diseño respire

                            Text(category.name)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(isSelected ? getLegibleColor(for: category.color) : .primary)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                    .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                        content
                            .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                            .opacity(phase.isIdentity ? 1.0 : 0.8)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }
    
    private func getLegibleColor(for color: Color) -> Color {
        if color == .yellow || color.description.contains("FFD700") {
            return Color(red: 0.7, green: 0.5, blue: 0.0)
        }
        return color
    }

    private var flashOffersSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Ofertas Flash").font(.title2.weight(.bold))
                Spacer()
                Text("Terminan pronto").font(.caption.weight(.bold)).foregroundStyle(.red).padding(.horizontal, 8).padding(.vertical, 4).background(.red.opacity(0.1)).clipShape(Capsule())
            }.padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(flashOffers) { product in NearbyCardView(product: product) }
                }.scrollTargetLayout()
            }.contentMargins(.horizontal, 16, for: .scrollContent).scrollTargetBehavior(.viewAligned)
        }
    }
    
    private var rewardPointsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recompensas con puntos").font(.title2.weight(.bold)).padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(rewardPointsProducts) { product in NearbyCardView(product: product) }
                }.scrollTargetLayout()
            }.contentMargins(.horizontal, 16, for: .scrollContent).scrollTargetBehavior(.viewAligned)
        }
    }
    
    private var forYouSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Productos para ti").font(.title2.weight(.bold)).padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(forYouProducts) { product in NearbyCardView(product: product) }
                }.scrollTargetLayout()
            }.contentMargins(.horizontal, 16, for: .scrollContent).scrollTargetBehavior(.viewAligned)
        }
    }
    
    private var nearbyVerticalSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cerca de ti").font(.title2.weight(.bold)).padding(.horizontal, 16)
            LazyVStack(spacing: 24) {
                ForEach(nearbyStores) { store in NearbyStoreCardVerticalView(store: store).padding(.horizontal, 16) }
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
}

extension View {
    func entranceAnimation(delay: Double, isAppearing: Bool) -> some View {
        self
            .offset(y: isAppearing ? 0 : 10)
            .opacity(isAppearing ? 1 : 0)
            .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(delay), value: isAppearing)
    }
}
