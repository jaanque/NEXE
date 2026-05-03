import SwiftUI
import Auth

struct NearbyStoreCardHorizontalView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    let store: NearbyStoreItem
    
    var body: some View {
        NavigationLink(destination: StoreDetailView(store: store)) {
            VStack(alignment: .leading, spacing: 10) {
                // Imagen
                ZStack(alignment: .bottomTrailing) {
                    DemoImage(urlString: store.imageURL ?? "", cornerRadius: 24)
                        .frame(width: 240, height: 140)
                        .grayscale(store.isOpen ? 0 : 1)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    
                    // Etiqueta de Estado (Cerrado)
                    if !store.isOpen, let nextTime = store.nextOpeningTime {
                        Text("Cerrado • Abre \(nextTime)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .background(Color.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                            )
                            .padding(8)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    // Logo del Local
                    if let logoURL = store.logoURL {
                        DemoImage(urlString: logoURL, cornerRadius: 12)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(12)
                    }
                }
                .overlay(alignment: .topLeading) {
                    // Píldora de Puntos
                    if store.givesPoints {
                        HStack(spacing: 4) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 10))
                            Text("Puntos")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.brandGranate)
                        .clipShape(Capsule())
                        .padding(12)
                    }
                }
                
                // Metadatos
                VStack(alignment: .leading, spacing: 4) {
                    // Fila 1: Título + Favorito
                    HStack(alignment: .center) {
                        Text(store.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer()
                        
                        // Favorito (Image + onTapGesture para evitar conflictos con NavigationLink)
                        Image(systemName: FavoritesManager.shared.isStoreFavorite(store.id) ? "heart.fill" : "heart")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(FavoritesManager.shared.isStoreFavorite(store.id) ? .red : .primary.opacity(0.3))
                            .symbolEffect(.bounce, value: FavoritesManager.shared.isStoreFavorite(store.id))
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let userId = authViewModel.currentUser?.id {
                                    Task {
                                        await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: store.id)
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                }
                            }
                    }
                    
                    // Metadata Distribuida
                    VStack(alignment: .leading, spacing: 4) {
                        // Línea 1: Logística (Categoría, Precio, Distancia)
                        HStack(spacing: 5) {
                            Text(store.categoryName ?? "Comercio")
                            if let price = store.priceLevel {
                                Text("•")
                                Text(price).foregroundStyle(Color.black)
                            }
                            Text("•")
                            Text(store.distance)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.4))
                        
                        // Línea 2: Reputación
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.black)
                            Text(String(format: "%.1f", store.rating))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.black)
                            Text("(\(store.reviewsCount))")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.black.opacity(0.4))
                        }
                    }
                }
                .padding(.horizontal, 4)
                .frame(width: 240, height: 95, alignment: .topLeading)
            }
        }
        .buttonStyle(.plain)
    }
}
