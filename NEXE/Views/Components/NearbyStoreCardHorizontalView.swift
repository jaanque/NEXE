import SwiftUI

struct NearbyStoreCardHorizontalView: View {
    let store: NearbyStoreItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Imagen
            ZStack(alignment: .bottomLeading) {
                DemoImage(urlString: store.imageURL ?? "", cornerRadius: 24)
                    .frame(width: 260, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                if let logoURL = store.logoURL {
                    DemoImage(urlString: logoURL, cornerRadius: 12)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4)
                        .padding(10)
                }
            }
            
            // Metadatos
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center) {
                    Text(store.name)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Rating Badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.black)
                        Text(String(format: "%.1f", store.rating))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.black)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                
                HStack(spacing: 5) {
                    Text(store.categoryName ?? "Comercio")
                    Text("•")
                    Text(store.distance)
                }
                .font(.system(size: 13))
                .foregroundStyle(Color.black.opacity(0.6))
                
                if store.givesPoints {
                    HStack(spacing: 4) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 10))
                        Text("Reparte puntos")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(Color.brandGranate)
                }
            }
            .padding(.horizontal, 4)
            .frame(width: 260, alignment: .leading)
        }
    }
}
