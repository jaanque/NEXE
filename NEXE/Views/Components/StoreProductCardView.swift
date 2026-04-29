import SwiftUI
import Auth

struct StoreProductCardView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    let product: ProductItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Imagen cuadrada flexible
            ZStack(alignment: .topTrailing) {
                DemoImage(urlString: product.imageURL ?? "", cornerRadius: 18)
                    .aspectRatio(1, contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                Button {
                    if let userId = authViewModel.currentUser?.id, let storeId = product.storeId {
                        Task {
                            await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: storeId, productId: product.id)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                } label: {
                    Image(systemName: FavoritesManager.shared.isProductFavorite(product.id) ? "heart.fill" : "heart")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(FavoritesManager.shared.isProductFavorite(product.id) ? .red : .white)
                        .padding(8)
                        .background(.black.opacity(0.3))
                        .clipShape(Circle())
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(String(format: "%.2f€", product.price))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(product.originalPrice != nil ? .red : .primary)
                
                if product.rewardPoints > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                        Text("\(product.rewardPoints) pts")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(Color.brandGreen)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 10)
    }
}
