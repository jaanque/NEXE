import SwiftUI
import Auth
import Supabase
import PostgREST

struct RewardsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var animatedPoints: Int = 0
    @State private var rewards: [RewardItem] = []
    @State private var isLoading = true
    @State private var selectedReward: RewardItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                if isLoading {
                    RewardsSkeletonView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            // ── Puntos (Simplificado) ──
                            VStack(spacing: 8) {
                                if authViewModel.currentUser == nil {
                                    Text("—")
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .foregroundStyle(.secondary.opacity(0.3))
                                    
                                    Text("Inicia sesión para ver tus puntos")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("\(animatedPoints)")
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .monospacedDigit()
                                        .contentTransition(.numericText())
                                    
                                    Text("Puntos acumulados")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.top, 40)

                            
                            // ── Recompensas ──
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Tus recompensas")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12)
                                
                                if rewards.isEmpty {
                                    Text("No hay recompensas disponibles en este momento.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 20)
                                } else {
                                    ForEach(rewards) { reward in
                                        RewardRow(reward: reward, userPoints: authViewModel.userProfile?.points ?? 0)
                                            .onTapGesture {
                                                selectedReward = reward
                                            }
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .refreshable {
                        await fetchRewards()
                    }
                }
            }
            .navigationTitle("Recompensas")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedReward) { reward in
                RewardCheckoutView(reward: reward)
            }
            .task {
                await fetchRewards()
                
                animatedPoints = 0
                try? await Task.sleep(nanoseconds: 100_000_000)
                await MainActor.run {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                        animatedPoints = authViewModel.userProfile?.points ?? 0
                    }
                }
            }
            .onChange(of: authViewModel.userProfile?.points) { _, newValue in
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                    animatedPoints = newValue ?? 0
                }
            }
        }
    }
    
    private func fetchRewards() async {
        do {
            // Join con stores para obtener el nombre del local
            let fetchedRewards: [RewardItem] = try await SupabaseManager.shared.client
                .from("rewards")
                .select("id, title, points_required, image_url, stock, stores(name)")
                .execute()
                .value
            
            await MainActor.run {
                self.rewards = fetchedRewards
                self.isLoading = false
            }
        } catch {
            print("DEBUG: Error fetching rewards: \(error)")
            await MainActor.run { self.isLoading = false }
        }
    }
}

struct RewardItem: Decodable, Identifiable {
    let id: UUID
    let title: String
    let points: Int
    let imageURL: String?
    let storeName: String
    
    let stock: Int
    
    struct StoreInfo: Decodable {
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, imageURL = "image_url", points = "points_required", stores, stock
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        points = try container.decode(Int.self, forKey: .points)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        stock = try container.decodeIfPresent(Int.self, forKey: .stock) ?? 0
        
        let stores = try container.decode(StoreInfo.self, forKey: .stores)
        storeName = stores.name
    }
}

struct RewardRow: View {
    let reward: RewardItem
    let userPoints: Int
    
    var isLocked: Bool { userPoints < reward.points }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Imagen panorámica con overlay si está bloqueado
            ZStack(alignment: .topTrailing) {
                DemoImage(urlString: reward.imageURL ?? "", cornerRadius: 20)
                    .frame(height: 180)
                    .grayscale(isLocked ? 1 : 0)
                    .opacity(isLocked ? 0.6 : 1)
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.3))
                        .clipShape(Circle())
                        .padding(12)
                }
                
                // Badge de puntos
                Text("\(reward.points) pts")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isLocked ? Color.gray : Color.brandGreen)
                    .clipShape(Capsule())
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(reward.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isLocked ? .secondary : .primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "storefront")
                        .font(.caption)
                    Text(reward.storeName)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                
                if !isLocked {
                    Text("Canjear ahora")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.brandGreen)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 20)
        .contentShape(Rectangle())
    }
}
