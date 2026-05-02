import SwiftUI
import Auth

struct NearbyStoreCardVerticalView: View {
    @Environment(AuthViewModel.self) var authViewModel
    let store: NearbyStoreItem

    var body: some View {
        NavigationLink(destination: StoreDetailView(store: store)) {
            VStack(alignment: .leading, spacing: 14) {
                // Imagen
                ZStack(alignment: .bottomTrailing) {
                    DemoImage(urlString: store.imageURL ?? "", cornerRadius: 24)
                        .frame(height: 200)
                        .grayscale(store.isOpen ? 0 : 1)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    
                    // Etiqueta de Estado (Cerrado)
                    if !store.isOpen, let nextTime = store.nextOpeningTime {
                        Text("Cerrado • Abre \(nextTime)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .padding(12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    // Fila 1: Título + Favorito
                    HStack(alignment: .center) {
                        Text(store.name)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Favorito (usamos Image + onTapGesture para evitar conflictos con NavigationLink)
                        Image(systemName: FavoritesManager.shared.isStoreFavorite(store.id) ? "heart.fill" : "heart")
                            .font(.system(size: 20))
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
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(Color.brandGranate)
                    }

                    // Fila 3: Categoría, Distancia y Valoración
                    HStack(spacing: 6) {
                        Text(store.categoryName ?? "Comercio")
                        Text("•")
                        Text(store.distance)
                        Text("•")
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(Color.black)
                            Text(String(format: "%.1f", store.rating))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.black)
                            Text("(\(store.reviewsCount))")
                                .foregroundStyle(Color.black.opacity(0.5))
                                .font(.system(size: 11))
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Color.black.opacity(0.6))
                }
                .padding(.horizontal, 4)
            }
            .padding(.bottom, 22)
        }
        .buttonStyle(.plain)
    }
}
