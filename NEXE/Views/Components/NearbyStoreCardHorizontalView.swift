import SwiftUI

struct NearbyStoreCardHorizontalView: View {
    let store: NearbyStoreItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                // Imagen Principal (Más amplia)
                DemoImage(urlString: store.imageURL ?? "", cornerRadius: 24)
                    .frame(width: 220, height: 300)
                    .overlay(
                        LinearGradient(
                            colors: [.black.opacity(0.3), .clear],
                            startPoint: .bottom,
                            endPoint: .center
                        )
                    )
                
                // Logo circular pequeño en la esquina (Opcional, pero da toque premium)
                if let logo = store.logoURL {
                    DemoImage(urlString: logo, cornerRadius: 12)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .shadow(radius: 4)
                        .padding(12)
                }
            }
            .frame(width: 220, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Metadatos Debajo
            VStack(alignment: .leading, spacing: 4) {
                Text(store.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    // Rating
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                        
                        Text(String(format: "%.1f", store.rating))
                            .font(.caption.weight(.bold))
                        
                        Text("(\(store.reviewsCount))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("•")
                        .foregroundStyle(.secondary.opacity(0.5))
                    
                    Text(store.distance)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if store.givesPoints {
                    HStack(spacing: 4) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 12))
                        Text("Reparte puntos NEXE")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Color.brandGreen)
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 4)
            .frame(width: 220, alignment: .leading)
        }
    }
}
