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
                            .background(Color.black.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .padding(8)
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
                        
                        Spacer()
                        
                        // Favorito (Image + onTapGesture para evitar conflictos con NavigationLink)
                        Image(systemName: FavoritesManager.shared.isStoreFavorite(store.id) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundStyle(FavoritesManager.shared.isStoreFavorite(store.id) ? .red : .primary.opacity(0.3))
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
                    
                    // Fila 2: Reparte Puntos
                    if store.givesPoints {
                        HStack(spacing: 4) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 13))
                            Text("Reparte puntos NEXE")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(Color.brandGranate)
                    }

                    // Fila 3: Categoría, Distancia y Valoración
                    HStack(spacing: 5) {
                        Text(store.categoryName ?? "Comercio")
                        Text("•")
                        Text(store.distance)
                        Text("•")
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Color.black)
                        Text(String(format: "%.1f", store.rating))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.black)
                        Text("(\(store.reviewsCount))")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.black.opacity(0.4))
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.5))
                }
                .padding(.horizontal, 4)
                .frame(width: 240, height: 75, alignment: .topLeading)
            }
        }
        .buttonStyle(.plain)
    }
}
