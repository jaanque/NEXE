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

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                // ── Cabecera: Imagen Premium (Fija) ──
                ZStack(alignment: .topLeading) {
                    DemoImage(urlString: store.imageURL ?? "", cornerRadius: 0)
                        .frame(height: 240)
                        .grayscale(store.isOpen ? 0 : 1)
                        .clipped()
                    
                    // Gradiente superior para visibilidad de controles
                    LinearGradient(colors: [.black.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 100)
                    
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

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // ── Info del Local (Estilo Card) ──
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .center) {
                                Text(store.name)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.black)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                // Rating Badge (Estilo Card)
                                HStack(spacing: 5) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(Color.black)
                                    
                                    HStack(spacing: 2) {
                                        Text(String(format: "%.1f", store.rating))
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.black)
                                        Text("(\(store.reviewsCount))")
                                            .foregroundStyle(Color.black.opacity(0.5))
                                            .font(.system(size: 11))
                                    }
                                    .font(.system(size: 13, design: .rounded))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            
                            HStack(spacing: 6) {
                                Text(store.categoryName ?? "Comercio")
                                Text("•")
                                Text(store.distance)
                                
                                Spacer()
                                
                                // Botón Favorito (Movido aquí para mantener limpieza en el título)
                                Button {
                                    if let userId = authViewModel.currentUser?.id {
                                        Task {
                                            await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: store.id)
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                    }
                                } label: {
                                    Image(systemName: FavoritesManager.shared.isStoreFavorite(store.id) ? "heart.fill" : "heart")
                                        .font(.system(size: 20))
                                        .foregroundStyle(FavoritesManager.shared.isStoreFavorite(store.id) ? .red : .primary.opacity(0.8))
                                }
                            }
                            .font(.system(size: 15))
                            .foregroundStyle(Color.black.opacity(0.6))
                            
                            if store.givesPoints {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Reparte puntos NEXE")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(Color.brandGranate)
                                .padding(.top, 2)
                            }
                            
                            // Etiqueta de Estado
                            HStack {
                                if !store.isOpen, let nextTime = store.nextOpeningTime {
                                    Text("Cerrado • Abre \(nextTime)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.black.opacity(0.8))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                } else {
                                    HStack(spacing: 6) {
                                        Circle().fill(Color.green).frame(width: 8, height: 8)
                                        Text("Abierto ahora")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.green)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                Spacer()
                            }
                            .padding(.top, 6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 28)

                        Divider().padding(.horizontal, 20).opacity(0.6)

                        // ── Lista de Productos (Premium Cards) ──
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Productos")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .padding(.horizontal, 20)
                                .padding(.bottom, 4)

                            if isLoading {
                                StoreDetailSkeletonView()
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
                                ForEach(products) { product in
                                    HStack(spacing: 16) {
                                        // Imagen del Producto
                                        DemoImage(urlString: product.imageURL ?? "", cornerRadius: 12)
                                            .frame(width: 90, height: 90)
                                            .background(Color.primary.opacity(0.04))
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(product.name)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(.primary)
                                                .lineLimit(2)
                                            
                                            Text(product.price.formatted(.currency(code: "EUR")))
                                                .font(.system(size: 15, weight: .black, design: .rounded))
                                                .foregroundStyle(.primary)
                                            
                                            Spacer(minLength: 0)
                                        }
                                        
                                        Spacer()

                                        // ── Selector de Cantidad Intuitivo ──
                                        Group {
                                            if (quantities[product.id] ?? 0) > 0 {
                                                HStack(spacing: 14) {
                                                    Button {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                            quantities[product.id, default: 0] -= 1
                                                        }
                                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    } label: {
                                                        Image(systemName: "minus")
                                                            .font(.system(size: 12, weight: .bold))
                                                            .foregroundStyle(.primary)
                                                            .frame(width: 32, height: 32)
                                                            .background(Color.primary.opacity(0.06))
                                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                                    }
                                                    .transition(.scale.combined(with: .opacity))

                                                    Text("\(quantities[product.id, default: 0])")
                                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                                        .monospacedDigit()
                                                        .contentTransition(.numericText())

                                                    Button {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                            quantities[product.id, default: 0] += 1
                                                        }
                                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                    } label: {
                                                        Image(systemName: "plus")
                                                            .font(.system(size: 12, weight: .bold))
                                                            .foregroundStyle(.white)
                                                            .frame(width: 32, height: 32)
                                                            .background(Color.brandGranate)
                                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                                    }
                                                }
                                            } else {
                                                Button {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        quantities[product.id, default: 0] = 1
                                                    }
                                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                } label: {
                                                    HStack(spacing: 4) {
                                                        Text("Añadir")
                                                        Image(systemName: "plus")
                                                    }
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundStyle(Color.brandGranate)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(Color.brandGranate.opacity(0.1))
                                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                                }
                                                .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(.bottom, 120)
                    }
                }
            }

            // ── Bottom CTA Button ──
            let totalQuantity = quantities.values.reduce(0, +)
            let totalPrice = products.reduce(0.0) { sum, product in
                sum + (Double(quantities[product.id] ?? 0) * product.price)
            }

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
                                .clipShape(Capsule())
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        let buttonText: String = {
                            if !store.isOpen {
                                return "Cerrado actualmente"
                            }
                            return totalQuantity > 0 ? "Añadir al carrito" : "Empezar pedido"
                        }()
                        
                        Text(buttonText)
                            .font(.headline)
                        
                        Spacer()
                        
                        if totalPrice > 0 {
                            Text(totalPrice.formatted(.currency(code: "EUR")))
                                .font(.headline)
                                .monospacedDigit()
                                .contentTransition(.numericText())
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(store.isOpen ? Color.brandGranate : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!store.isOpen)
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .background(
                LinearGradient(colors: [.white.opacity(0), .white], startPoint: .top, endPoint: .bottom)
                    .padding(.top, -20)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: totalQuantity)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .task {
            await fetchProducts()
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
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}
