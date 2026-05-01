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
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            if authViewModel.currentUser == nil {
                LoggedOutView(
                    icon: "heart",
                    title: "Tus favoritos a un toque",
                    description: "Inicia sesión para guardar los locales y productos que más te gustan y verlos aquí."
                )
            } else if isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else if favorites.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(groupedFavorites, id: \.0) { date, items in
                            VStack(alignment: .leading, spacing: 20) {
                                // Cabecera de fecha más visible
                                Text(formatDate(date))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 24)
                                
                                ForEach(items) { favorite in
                                    if favorite.store != nil && favorite.product == nil {
                                        favoriteCard(for: favorite)
                                            .padding(.horizontal, 16)
                                    } else {
                                        favoriteCard(for: favorite)
                                            .padding(.horizontal, 24)
                                    }
                                }
                                
                                // Separador entre días (excepto el último)
                                if date != groupedFavorites.last?.0 {
                                    Divider()
                                        .padding(.horizontal, 24)
                                        .padding(.top, 10)
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
                .refreshable {
                    await loadFavorites()
                }
            }

        }
        .navigationTitle("Favoritos")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadFavorites()
            FavoritesManager.shared.resetNewCount()
        }
    }
    
    @ViewBuilder
    private func favoriteCard(for favorite: FavoriteItem) -> some View {
        if let store = favorite.store, favorite.product == nil {
            NearbyStoreCardVerticalView(store: store)
                .padding(.bottom, 10)
        } else {
            // Card para productos favoritos (se mantiene simplificada o similar a la anterior)
            VStack(alignment: .leading, spacing: 14) {
                ZStack(alignment: .topTrailing) {
                    let imgURL = favorite.product?.imageURL ?? favorite.store?.imageURL ?? ""
                    DemoImage(urlString: imgURL, cornerRadius: 24)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    
                    Button {
                        if let userId = authViewModel.currentUser?.id {
                            Task {
                                if let product = favorite.product {
                                    await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: favorite.store_id, productId: product.id)
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(favorite.product?.name ?? "")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 10))
                        Text("\(favorite.product?.rewardPoints ?? 20) puntos NEXE")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.brandGreen)
                    
                    if let product = favorite.product {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text(product.price.formatted(.currency(code: "EUR")))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(product.originalPrice != nil ? .red : .primary)
                            
                            if let original = product.originalPrice {
                                Text(original.formatted(.currency(code: "EUR")))
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                                    .strikethrough()
                                    .padding(.bottom, 1)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
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
    FavoritesView(selectedTab: .constant(.profile))
}
