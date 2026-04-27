import SwiftUI

struct NearbyStoreCardVerticalView: View {
    let store: NearbyStoreItem
    @State private var isFavorite = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Imagen panorámica
            ZStack(alignment: .topTrailing) {
                DemoImage(urlString: store.imageURL ?? "", cornerRadius: 20)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                Button {
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isFavorite ? .red : .white)
                        .padding(8)
                        .background(.black.opacity(0.3))
                        .clipShape(Circle())
                        .padding(10)
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
                
                HStack(spacing: 4) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 14))
                    Text("Reparte puntos NEXE")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.brandGreen)
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 16)
    }
}
