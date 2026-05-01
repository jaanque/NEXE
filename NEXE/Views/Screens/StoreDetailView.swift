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
                // ── Cabecera: Imagen Simple ──
                AsyncImage(url: URL(string: store.imageURL ?? "")) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(height: 200)
                .clipped()
                .overlay(alignment: .topLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.top, 50)
                    .padding(.leading, 16)
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // ── Info del Local ──
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(store.name)
                                    .font(.title.weight(.bold))
                                Spacer()
                                Button {
                                    if let userId = authViewModel.currentUser?.id {
                                        Task {
                                            await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: store.id)
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                } label: {
                                    Image(systemName: FavoritesManager.shared.isStoreFavorite(store.id) ? "heart.fill" : "heart")
                                        .foregroundStyle(FavoritesManager.shared.isStoreFavorite(store.id) ? .red : .primary)
                                }
                            }

                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill").foregroundStyle(.orange).font(.caption)
                                    Text(String(format: "%.1f", store.rating)).font(.subheadline).bold()
                                }
                                Text(store.distance).font(.subheadline).foregroundStyle(.secondary)
                                Text(store.isOpen ? "Abierto" : "Cerrado")
                                    .font(.subheadline)
                                    .foregroundStyle(store.isOpen ? .green : .red)
                            }
                            
                            if let desc = store.description {
                                Text(desc)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                        Divider().padding(.horizontal, 20)

                        // ── Lista de Productos Simple ──
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Productos")
                                .font(.headline)
                                .padding(.horizontal, 20)

                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 20)
                            } else if products.isEmpty {
                                Text("No hay productos")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)
                            } else {
                                ForEach(products) { product in
                                    HStack(spacing: 12) {
                                        AsyncImage(url: URL(string: product.imageURL ?? "")) { img in
                                            img.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.gray.opacity(0.1)
                                        }
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(product.name)
                                                .font(.subheadline.weight(.medium))
                                            Text(product.price.formatted(.currency(code: "EUR")))
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.primary)
                                        }
                                        Spacer()

                                        // ── Selector de Cantidad ──
                                        HStack(spacing: 12) {
                                            if (quantities[product.id] ?? 0) > 0 {
                                                Button {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        quantities[product.id, default: 0] -= 1
                                                    }
                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                } label: {
                                                    Image(systemName: "minus.circle.fill")
                                                        .font(.title3)
                                                        .foregroundStyle(Color.brandGranate.opacity(0.6))
                                                }
                                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))

                                                Text("\(quantities[product.id, default: 0])")
                                                    .font(.subheadline.weight(.bold))
                                                    .monospacedDigit()
                                                    .contentTransition(.numericText())
                                                    .frame(minWidth: 20)
                                            }

                                            Button {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    quantities[product.id, default: 0] += 1
                                                }
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            } label: {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title3)
                                                    .foregroundStyle(Color.brandGranate)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    
                                    if product.id != products.last?.id {
                                        Divider().padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100) // Espacio para el botón CTA
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
                    .clipShape(RoundedRectangle(cornerRadius: 16))
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
            isLoading = false
        }
    }
}
