import SwiftUI
import Auth

struct NearbyStoreCardVerticalView: View {
    @Environment(AuthViewModel.self) private var authViewModel
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
                    
                    // Logo del Local (Esquina inferior izquierda)
                    if let logoURL = store.logoURL {
                        DemoImage(urlString: logoURL, cornerRadius: 12)
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4)
                            .padding(12)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                    
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
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(FavoritesManager.shared.isStoreFavorite(store.id) ? .red : .white)
                                    .shadow(color: .black.opacity(0.2), radius: 4)
                                    .padding(16)
                            }
                        }
                        Spacer()
                    }
                    
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
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center) {
                        Text(store.name)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Rating Badge (Alineado SOLO con el título)
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
                    }
                    .font(.system(size: 14))
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
                }
                .padding(.horizontal, 4)
            }
            .padding(.bottom, 22)
            .buttonStyle(.plain)
        }
    }
}
