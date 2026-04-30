import SwiftUI
import Auth

struct NearbyStoreCardVerticalView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    let store: NearbyStoreItem

    var body: some View {
        NavigationLink(destination: StoreDetailView(store: store)) {
            VStack(alignment: .leading, spacing: 12) {
                // Imagen panorámica
                ZStack(alignment: .bottomLeading) {
                    DemoImage(urlString: store.imageURL ?? "", cornerRadius: 20)
                        .frame(height: 180)
                        .grayscale(store.isOpen ? 0 : 1) // Gris si está cerrado
                        .overlay(
                            Group {
                                if !store.isOpen {
                                    Color.black.opacity(0.2) // Oscurecer un poco para legibilidad
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    // Aviso de apertura (Esquina inferior derecha)
                    if !store.isOpen, let nextTime = store.nextOpeningTime {
                        Text("Abre a las \(nextTime)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.brandGranate)
                            .clipShape(CustomCorner(corners: [.topLeft], radius: 12))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                    
                    // Logo circular pequeño overlay (Esquina inferior izquierda)
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.15), radius: 4)
                        
                        if let logo = store.logoURL {
                            DemoImage(urlString: logo, cornerRadius: 25)
                                .clipShape(Circle())
                                .padding(2)
                        } else {
                            Image(systemName: "storefront.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.brandGreen.opacity(0.3))
                        }
                    }
                    .frame(width: 44, height: 44)
                    .padding(12) // Espaciado desde los bordes de la esquina
                    
                    // Botón Favoritos (Esquina superior derecha)
                    VStack {
                        HStack {
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
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(FavoritesManager.shared.isStoreFavorite(store.id) ? .red : .white)
                                    .padding(8)
                                    .background(.black.opacity(0.3))
                                    .clipShape(Circle())
                                    .padding(10)
                            }
                        }
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(store.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 4) {
                        // Rating y Estrella
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.primary)
                            
                            Text(String(format: "%.1f", store.rating))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.primary)
                            
                            Text("(\(store.reviewsCount))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text("\(store.distance)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if store.givesPoints {
                        HStack(spacing: 4) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 14))
                            Text("Reparte puntos NEXE")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color.brandGreen)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(.bottom, 16)
        }
        .buttonStyle(.plain)
    }
}
