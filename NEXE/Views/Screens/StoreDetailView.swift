import SwiftUI
import Auth
import Supabase


struct StoreDetailView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    let store: NearbyStoreItem
    @Environment(\.dismiss) private var dismiss
    @State private var products: [ProductItem] = []
    @State private var isLoading = true
    @State private var scrollOffset: CGFloat = 0
    
    private let headerHeight: CGFloat = 280
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // HEADER IMAGE (PARALLAX)
                    headerImage
                    
                    // CONTENIDO PRINCIPAL (TARJETA)
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // CABECERA DE INFO: Logo, Título, Acciones
                        HStack(alignment: .center, spacing: 16) {
                            // Logo circular premium (Integrado sin solapamiento con imagen)
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                
                                if let logo = store.logoURL {
                                    DemoImage(urlString: logo, cornerRadius: 35)
                                        .clipShape(Circle())
                                        .padding(4)
                                } else {
                                    Image(systemName: "storefront.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color.brandGreen.opacity(0.4))
                                }
                            }
                            .frame(width: 70, height: 70)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.name)
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                
                                if store.givesPoints {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.circle.fill")
                                        Text("Reparte puntos NEXE")
                                    }
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color.brandGreen)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.brandGreen.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                            }
                            
                            Spacer()
                            
                            // Botón compartir
                            ShareLink(item: URL(string: "https://nexe.app/store/\(store.id)")!) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(.primary)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        
                        // DETALLES ADICIONALES (Rating, Distancia, Tiempo)
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill").foregroundStyle(.orange)
                                Text(String(format: "%.1f", store.rating)).fontWeight(.bold)
                                Text("(\(store.reviewsCount))").foregroundStyle(.secondary)
                            }
                            
                            Text("•").foregroundStyle(.secondary.opacity(0.3))
                            
                            Label(store.distance, systemImage: "mappin.and.ellipse")
                                .foregroundStyle(.secondary)
                            
                            Text("•").foregroundStyle(.secondary.opacity(0.3))
                            
                            Label("15-25 min", systemImage: "clock")
                                .foregroundStyle(.secondary)
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        // DESCRIPCIÓN
                        if let description = store.description {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                                .padding(.horizontal, 24)
                                .padding(.top, 20)
                        }
                        
                        Divider().padding(.horizontal, 24).padding(.top, 24)
                        
                        // SECCIÓN DE PRODUCTOS
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text("Nuestra Selección")
                                    .font(.title2.weight(.bold))
                                Spacer()
                                Text("\(products.count) artículos").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                            }
                            
                            if isLoading {
                                productsSkeleton
                            } else if products.isEmpty {
                                emptyState
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
                                    ForEach(products) { product in
                                        StoreProductCardView(product: product)
                                            .onTapGesture {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .padding(.bottom, 40)
                    }
                    .background(Color.brandBackground)
                    .clipShape(RoundedCorner(radius: 36, corners: [.topLeft, .topRight]))
                    .offset(y: -36)
                }
            }
            
            // BOTONES FLOTANTES (ATRÁS Y FAVORITO)
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                    
                    Spacer()
                    
                    Button {
                        if let userId = authViewModel.currentUser?.id {
                            Task {
                                await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: store.id)
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                    } label: {
                        Image(systemName: FavoritesManager.shared.isStoreFavorite(store.id) ? "heart.fill" : "heart")
                            .font(.body.weight(.bold))
                            .foregroundStyle(FavoritesManager.shared.isStoreFavorite(store.id) ? .red : .primary)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .task {
            await fetchStoreProducts()
        }
    }
    
    private var headerImage: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            DemoImage(urlString: store.imageURL ?? "", cornerRadius: 0)
                .frame(width: geo.size.width, height: geo.size.height + (minY > 0 ? minY : 0))
                .clipped()
                .offset(y: minY > 0 ? -minY : 0)
        }
        .frame(height: headerHeight)
    }
    
    private var productsSkeleton: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
            ForEach(0..<4, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 18).fill(.gray.opacity(0.1)).aspectRatio(1, contentMode: .fit)
                    RoundedRectangle(cornerRadius: 6).fill(.gray.opacity(0.1)).frame(height: 16)
                    RoundedRectangle(cornerRadius: 6).fill(.gray.opacity(0.1)).frame(width: 60, height: 16)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart.badge.minus")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("No hay productos disponibles")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func fetchStoreProducts() async {
        do {
            let fetched: [ProductItem] = try await SupabaseManager.shared.client
                .from("products")
                .select()
                .eq("store_id", value: store.id)
                .execute()
                .value
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.products = fetched
                    self.isLoading = false
                }
            }
        } catch {
            print("Error fetching store products: \(error)")
            isLoading = false
        }
    }
}

// Helper para redondear solo esquinas superiores
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
