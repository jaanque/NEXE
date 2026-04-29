import SwiftUI
import Supabase
import MapKit

struct StoreDetailView: View {
    let store: NearbyStoreItem
    @Environment(\.dismiss) private var dismiss
    @State private var products: [ProductItem] = []
    @State private var isLoading = true
    @State private var scrollOffset: CGFloat = 0
    
    // Estado para el mapa nativo
    @State private var region: MKCoordinateRegion
    
    init(store: NearbyStoreItem) {
        self.store = store
        // Coordenadas de ejemplo (Lleida) o reales si las hubiera
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.6176, longitude: 0.6200),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    private let headerHeight: CGFloat = 280
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header con Parallax nativo mediante GeometryReader
                    headerImage
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // INFO PRINCIPAL
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(store.name)
                                    .font(.system(.title, design: .rounded, weight: .bold))
                                Spacer()
                                
                                // Botón de compartir nativo (ShareLink)
                                ShareLink(item: URL(string: "https://nexe.app/store/\(store.id)")!) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(Color.brandGreen)
                                        .padding(10)
                                        .background(Color.brandGreen.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                            
                            HStack(spacing: 16) {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill").foregroundStyle(.orange)
                                    Text(String(format: "%.1f", store.rating)).fontWeight(.bold)
                                    Text("(\(store.reviewsCount))").foregroundStyle(.secondary)
                                }
                                
                                Text("•").foregroundStyle(.tertiary)
                                
                                Label(store.distance, systemImage: "mappin.and.ellipse")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                        }
                        .padding(.top, 24)
                        
                        if let description = store.description {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                        
                        // SECCIÓN DE MAPA NATIVO
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ubicación")
                                .font(.headline)
                            
                            Map(coordinateRegion: $region, interactionModes: [], annotationItems: [store]) { item in
                                MapMarker(coordinate: CLLocationCoordinate2D(latitude: 41.6176, longitude: 0.6200), tint: Color.brandGreen)
                            }
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        Divider().padding(.vertical, 8)
                        
                        // PRODUCTOS
                        VStack(alignment: .leading, spacing: 20) {
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
                    }
                    .padding(.horizontal, 24)
                    .background(Color.brandBackground)
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .offset(y: -32)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Image(systemName: "heart")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
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

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
