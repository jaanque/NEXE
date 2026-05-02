import SwiftUI
import Auth
import Supabase

struct StoreDetailView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    let store: NearbyStoreItem

    @State private var products: [ProductItem] = []
    @State private var isLoading = true
    @State private var quantities: [UUID: Int] = [:]
    @State private var selectedProduct: ProductItem? = nil
    @State private var searchText = ""

    private var filteredProducts: [ProductItem] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Fondo blanco para toda la pantalla
            Color.white.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Header Section ──
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            // Botón Volver
                            Button { dismiss() } label: {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Circle())
                            }
                            
                            // Logo y Nombre
                            HStack(spacing: 12) {
                                    if let logoURL = store.logoURL {
                                        Color.white.opacity(0.1)
                                            .frame(width: 44, height: 44)
                                            .cornerRadius(4)
                                            .overlay(
                                                DemoImage(urlString: logoURL, cornerRadius: 4)
                                            )
                                            .clipped()
                                    }
                                
                                Text(store.name)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            // Botón Favorito
                            Button {
                                if let userId = authViewModel.currentUser?.id {
                                    Task {
                                        await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: store.id)
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                }
                            } label: {
                                Image(systemName: FavoritesManager.shared.isStoreFavorite(store.id) ? "heart.fill" : "heart")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.top, 50)
                        
                        // Barra de Búsqueda Premium
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white.opacity(0.7))
                            
                            TextField("", text: $searchText, prompt: Text("Buscar productos...").foregroundColor(.white.opacity(0.5)))
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                                .autocorrectionDisabled()
                            
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        
                        // Metadata Scrollable Row (Discreet)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // Rating
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 8))
                                        .foregroundStyle(.white)
                                    Text(String(format: "%.1f", store.rating))
                                        .font(.system(size: 11, weight: .bold))
                                    Text("(\(store.reviewsCount))")
                                        .font(.system(size: 10))
                                        .opacity(0.7)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Capsule())
                                
                                // Distance
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 8))
                                    Text(store.distance)
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Capsule())
                                
                                // Category (if exists)
                                if let cat = store.categoryName {
                                    Text(cat)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                                
                                // Status Badge (Open/Closed)
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(store.isOpen ? Color.green : Color.red)
                                        .frame(width: 5, height: 5)
                                    Text(store.isOpen ? "Abierto" : "Cerrado")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Capsule())

                                // Points Badge (Minimalist)
                                if store.givesPoints {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.circle.fill")
                                            .font(.system(size: 10))
                                        Text("Puntos")
                                            .font(.system(size: 11, weight: .bold))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .background(Color(hex: store.brandColorHex ?? "#006CEB"))
                    .ignoresSafeArea(edges: .top)
                    
                    Divider()
                    
                    // ── Sección de Productos ──
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Productos disponibles")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .padding(.horizontal, 24)
                        
                        if isLoading {
                            StoreDetailSkeletonView()
                                .padding(.top, 20)
                        } else if products.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "cart.badge.questionmark")
                                    .font(.largeTitle)
                                    .foregroundStyle(.tertiary)
                                Text("No hay productos disponibles")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredProducts) { product in
                                    productRow(product)
                                }
                                
                                if filteredProducts.isEmpty && !searchText.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.largeTitle)
                                            .foregroundStyle(.tertiary)
                                        Text("No se encontraron productos")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .background(Color.white)
            .ignoresSafeArea(edges: .top)

            // ── Bottom CTA ──
            checkoutBar
        }
        .navigationBarHidden(true)
        .task {
            await fetchProducts()
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(
                product: product,
                quantity: Binding(
                    get: { self.quantities[product.id, default: 0] },
                    set: { self.quantities[product.id] = $0 }
                )
            )
        }
    }

    // MARK: - Components
    
    @ViewBuilder
    private var checkoutBar: some View {
        let totalQuantity = quantities.values.reduce(0, +)
        let totalPrice = products.reduce(0.0) { sum, product in
            sum + (Double(quantities[product.id] ?? 0) * product.price)
        }

        if totalQuantity > 0 || !store.isOpen {
            VStack {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    HStack {
                        if totalQuantity > 0 {
                            Text("\(totalQuantity)")
                                .font(.subheadline.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.white.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        
                        Text(store.isOpen ? "Ver mi pedido" : "Local cerrado")
                            .font(.headline)
                        
                        Spacer()
                        
                        if totalPrice > 0 {
                            Text(totalPrice.formatted(.currency(code: "EUR")))
                                .font(.headline)
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(store.isOpen ? Color.brandGranate : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.brandGranate.opacity(0.2), radius: 10, y: 5)
                }
                .disabled(!store.isOpen)
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .background(
                LinearGradient(colors: [.white.opacity(0), .white], startPoint: .top, endPoint: .bottom)
                    .padding(.top, -20)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private func productRow(_ product: ProductItem) -> some View {
        HStack(spacing: 16) {
            DemoImage(urlString: product.imageURL ?? "", cornerRadius: 12)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                Text(product.price.formatted(.currency(code: "EUR")))
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // Selector de cantidad
            if let qty = quantities[product.id], qty > 0 {
                HStack(spacing: 12) {
                    Button { quantities[product.id, default: 0] -= 1 } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 10, weight: .bold))
                            .frame(width: 28, height: 28)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    
                    Text("\(qty)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    
                    Button { quantities[product.id, default: 0] += 1 } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.brandGranate)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .foregroundStyle(.primary)
            } else {
                Button {
                    withAnimation { quantities[product.id, default: 0] = 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.brandGranate)
                        .frame(width: 36, height: 36)
                        .background(Color.brandGranate.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture {
            selectedProduct = product
        }
    }

    private func fetchProducts() async {
        do {
            let fetched: [ProductItem] = try await SupabaseManager.shared.client
                .from("products")
                .select()
                .eq("store_id", value: store.id)
                .execute()
                .value
            await MainActor.run {
                self.products = fetched
                self.isLoading = false
            }
        } catch {
            print("Error: \(error)")
            await MainActor.run { isLoading = false }
        }
    }
}

// MARK: - Shapes

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Product Detail View

struct ProductDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let product: ProductItem
    @Binding var quantity: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Cabecera: Imagen de Producto ──
                    ZStack(alignment: .topLeading) {
                        DemoImage(urlString: product.imageURL ?? "", cornerRadius: 0)
                            .frame(height: 380)
                            .clipped()
                        
                        // Gradiente inferior para suavizar transición
                        LinearGradient(colors: [.clear, .white.opacity(0.8), .white], startPoint: .top, endPoint: .bottom)
                            .frame(height: 100)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        
                        // Botón Volver
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(.top, 60)
                        .padding(.leading, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Info Principal
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                Text(product.name)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.black)
                                
                                Spacer()
                                
                                if product.isFlashOffer {
                                    Text("OFERTA")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.orange)
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                            }
                            
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(product.price.formatted(.currency(code: "EUR")))
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.black)
                                
                                if let original = product.originalPrice {
                                    Text(original.formatted(.currency(code: "EUR")))
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondary)
                                        .strikethrough()
                                }
                                
                                Spacer()
                                
                                // Badge de Puntos
                                if product.rewardPoints > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.circle.fill")
                                        Text("+\(product.rewardPoints) pts")
                                    }
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.brandGranate)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.brandGranate.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }
                        
                        Divider().opacity(0.5)
                        
                        // Descripción
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Descripción")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            
                            Text("Este es un producto seleccionado de NEXE. Disfruta de la mejor calidad y frescura directamente desde nuestros comercios locales asociados. Cada compra apoya el crecimiento de tu ciudad.")
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                        
                        // Selector de Cantidad Grande
                        VStack(spacing: 16) {
                            Text("¿Cuántos quieres?")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            
                            HStack(spacing: 40) {
                                Button {
                                    if quantity > 0 {
                                        quantity -= 1
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.title2.bold())
                                        .foregroundStyle(quantity > 0 ? Color.black : Color.gray.opacity(0.3))
                                        .frame(width: 56, height: 56)
                                        .background(Color.black.opacity(0.05))
                                        .clipShape(Circle())
                                }
                                .disabled(quantity == 0)
                                
                                Text("\(quantity)")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .monospacedDigit()
                                    .contentTransition(.numericText())
                                
                                Button {
                                    quantity += 1
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title2.bold())
                                        .foregroundStyle(.white)
                                        .frame(width: 56, height: 56)
                                        .background(Color.brandGranate)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.black.opacity(0.02))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                    .padding(24)
                    .padding(.bottom, 120)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Botón de Acción Principal
            VStack {
                Button {
                    if quantity == 0 { quantity = 1 }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    dismiss()
                } label: {
                    Text(quantity > 0 ? "Actualizar carrito" : "Añadir al carrito")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.brandGranate)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.brandGranate.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            .background(
                LinearGradient(colors: [.white.opacity(0), .white], startPoint: .top, endPoint: .bottom)
                    .padding(.top, -20)
            )
        }
        .navigationBarHidden(true)
    }
}
