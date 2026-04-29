import SwiftUI
import Auth

struct FavoritesView: View {
    @Binding var selectedTab: AppTab
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var favorites: [FavoriteItem] = []
    @State private var isLoading = true
    
    // Agrupación por día
    private var groupedFavorites: [(Date, [FavoriteItem])] {
        let groups = Dictionary(grouping: favorites) { item in
            Calendar.current.startOfDay(for: item.created_at)
        }
        return groups.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else if favorites.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 44) {
                            ForEach(groupedFavorites, id: \.0) { date, items in
                                VStack(alignment: .leading, spacing: 20) {
                                    Text(formatDate(date))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.secondary.opacity(0.4))
                                        .padding(.horizontal, 24)
                                    
                                    ForEach(items) { favorite in
                                        favoriteCard(for: favorite)
                                            .padding(.horizontal, 24)
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                    .refreshable {
                        await loadFavorites()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadFavorites()
            FavoritesManager.shared.resetNewCount()
        }
    }
    
    @ViewBuilder
    private func favoriteCard(for favorite: FavoriteItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // IMAGEN (Aprovechando la amplitud)
            ZStack(alignment: .topTrailing) {
                let imgURL = favorite.product?.imageURL ?? favorite.store?.imageURL ?? ""
                DemoImage(urlString: imgURL, cornerRadius: 24)
                    .frame(height: 200) // Mayor altura para acompañar el ancho
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                // Botón Corazón Premium
                Button {
                    if let userId = authViewModel.currentUser?.id {
                        Task {
                            if let product = favorite.product {
                                await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: favorite.store_id, productId: product.id)
                            } else {
                                await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: favorite.store_id)
                            }
                            await loadFavorites()
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.red)
                        .padding(10)
                        .background(.black.opacity(0.3))
                        .clipShape(Circle())
                        .padding(12)
                }
            }
            
            // DETALLES
            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.product?.name ?? favorite.store?.name ?? "")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("\(favorite.product?.rewardPoints ?? 20) puntos NEXE")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.brandGreen)
                
                HStack(alignment: .bottom, spacing: 8) {
                    if let product = favorite.product {
                        Text(String(format: "%.2f€", product.price))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(product.originalPrice != nil ? .red : .black)
                        
                        if let original = product.originalPrice {
                            Text(String(format: "%.2f€", original))
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .strikethrough()
                                .padding(.bottom, 1)
                        }
                    } else if let store = favorite.store {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundStyle(.yellow)
                            Text(String(format: "%.1f", store.rating)).fontWeight(.bold)
                            Text("•")
                            Text("Local")
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "heart.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.brandGreen.opacity(0.8))
            
            VStack(spacing: 12) {
                Text("Tu lista está vacía")
                    .font(.system(size: 22, weight: .bold))
                
                Text("Guarda los locales y productos que más te gusten para tenerlos siempre a mano.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
            }
            
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    selectedTab = .explore
                }
                UISelectionFeedbackGenerator().selectionChanged()
            } label: {
                Text("Explorar NEXE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 18)
                    .background(Color.brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            Spacer()
        }
    }
    
    private func loadFavorites() async {
        if let userId = authViewModel.currentUser?.id {
            let fetched = await FavoritesManager.shared.fetchDetailedFavorites(userId: userId)
            await MainActor.run {
                self.favorites = fetched
                self.isLoading = false
            }
        } else {
            self.isLoading = false
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Hoy" }
        if calendar.isDateInYesterday(date) { return "Ayer" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date).capitalized
    }
}

#Preview {
    FavoritesView(selectedTab: .constant(.favorites))
}
