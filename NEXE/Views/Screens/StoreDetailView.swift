import SwiftUI
import Auth
import Supabase

struct StoreDetailView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    let store: NearbyStoreItem

    @State private var rewards: [RewardItem] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var showInfoSheet = false
    @State private var selectedReward: RewardItem?

    private var filteredRewards: [RewardItem] {
        if searchText.isEmpty {
            return rewards
        } else {
            return rewards.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Fondo blanco para toda la pantalla
            Color.white.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Header Section ──
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            // Botón Volver
                            Button { dismiss() } label: {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Circle())
                            }
                            
                            // Logo y Nombre
                            HStack(spacing: 12) {
                                if let logoURL = store.logoURL {
                                    Color.white.opacity(0.1)
                                        .frame(width: 44, height: 44)
                                        .cornerRadius(4)
                                        .overlay(
                                            DemoImage(urlString: logoURL, cornerRadius: 4)
                                        )
                                        .clipped()
                                }
                                
                                Text(store.name)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            // Botones Derecha
                            HStack(spacing: 8) {
                                Button {
                                    if let userId = authViewModel.currentUser?.id {
                                        Task {
                                            await FavoritesManager.shared.toggleFavorite(userId: userId, storeId: store.id)
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                    }
                                } label: {
                                    Image(systemName: FavoritesManager.shared.isStoreFavorite(store.id) ? "heart.fill" : "heart")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.white)
                                        .symbolEffect(.bounce, value: FavoritesManager.shared.isStoreFavorite(store.id))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Circle())
                                }

                                Menu {
                                    Button {
                                        showInfoSheet = true
                                    } label: {
                                        Label("Información del establecimiento", systemImage: "info.circle")
                                    }
                                    
                                    Button(role: .destructive) { } label: {
                                        Label("Reportar problema", systemImage: "exclamationmark.bubble")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.top, 64) // Más espacio arriba
                        .padding(.bottom, 6) // Aire entre info y búsqueda
                        
                        // Barra de Búsqueda
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white.opacity(0.7))
                            
                            TextField("", text: $searchText, prompt: Text("Buscar recompensas...").foregroundColor(.white.opacity(0.5)))
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                                .autocorrectionDisabled()
                            
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28) // Más espacio bajo la búsqueda
                    .background(Color(hex: store.brandColorHex ?? "#006CEB"))
                    .ignoresSafeArea(edges: .top)
                    
                    // ── Contenido ──
                    if isLoading {
                        StoreDetailSkeletonView()
                            .padding(.top, 24)
                    } else {
                        // Listado de Recompensas
                        VStack(alignment: .leading, spacing: 32) {
                            if rewards.isEmpty {
                                emptyStateView(message: "No hay recompensas disponibles")
                            } else if filteredRewards.isEmpty {
                                emptyStateView(message: "No se encontraron recompensas")
                            } else {
                                LazyVStack(spacing: 0) {
                                    ForEach(filteredRewards) { reward in
                                        rewardRowItem(reward)
                                            .onTapGesture {
                                                selectedReward = reward
                                            }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

        }
        .navigationBarHidden(true)
        .task {
            await fetchRewards()
        }
        .sheet(isPresented: $showInfoSheet) {
            StoreInfoView(store: store)
        }
        .sheet(item: $selectedReward) { reward in
            RewardCheckoutView(reward: reward)
        }
    }

    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "cart.badge.questionmark")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    @ViewBuilder
    private func rewardRowItem(_ reward: RewardItem) -> some View {
        let brandColor = Color(hex: store.brandColorHex ?? "#800020")
        let userPoints = authViewModel.userProfile?.points ?? 0
        let isLocked = userPoints < reward.points
        
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                // Imagen
                ZStack {
                    Color.gray.opacity(0.05)
                        .frame(width: 80, height: 80)
                        .overlay(
                            DemoImage(urlString: reward.imageURL ?? "", cornerRadius: 10)
                                .scaledToFill()
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .grayscale(isLocked ? 1 : 0)
                        .opacity(isLocked ? 0.6 : 1)
                        
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(reward.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(isLocked ? .secondary : .primary)
                        .lineLimit(2)
                    
                    HStack(alignment: .center, spacing: 4) {
                        Text("\(reward.points) pts")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isLocked ? Color.gray : brandColor)
                            .cornerRadius(4)
                    }
                    
                    Spacer(minLength: 0)
                    
                    // Selector / Botón
                    HStack {
                        Spacer()
                        if !isLocked {
                            Text("Canjear")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(brandColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(brandColor.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            
            Divider().opacity(0.5)
        }
    }

    private func fetchRewards() async {
        do {
            let fetched: [RewardItem] = try await SupabaseManager.shared.client
                .from("rewards")
                .select("id, title, points_required, image_url, stock, stores(name)")
                .eq("store_id", value: store.id)
                .execute()
                .value
            await MainActor.run {
                self.rewards = fetched
                self.isLoading = false
            }
        } catch {
            print("Error: \(error)")
            await MainActor.run { isLoading = false }
        }
    }
}
