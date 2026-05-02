import SwiftUI
import Auth
import Supabase

struct OrdersView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Binding var selectedTab: AppTab
    @State private var selectedOrderType = 1 // 0: Pedidos, 1: Recompensas (Default Rewards now)
    @State private var redemptions: [RedemptionRecord] = []
    @State private var isLoadingRedemptions = false
    @State private var selectedRedemption: RedemptionRecord?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                if authViewModel.currentUser == nil {
                    LoggedOutView(
                        icon: "scroll",
                        title: "Tus pedidos te esperan",
                        description: "Inicia sesión para ver tu historial de compras y el estado de tus canjes."
                    )
                } else {
                    VStack(spacing: 0) {
                        // Selector Nativo Segmentado
                        Picker("Tipo de pedido", selection: $selectedOrderType) {
                            Text("Pedidos").tag(0)
                            Text("Recompensas").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                        
                        if selectedOrderType == 0 {
                            // PEDIDOS NORMALES (Empty State por ahora)
                            emptyState(
                                icon: "scroll",
                                title: "No tienes pedidos",
                                description: "Aquí aparecerán tus compras y pedidos realizados en los locales de la ciudad."
                            )
                        } else {
                            // RECOMPENSAS
                            if isLoadingRedemptions {
                                OrdersSkeletonView()
                            } else if redemptions.isEmpty {
                                emptyState(
                                    icon: "gift",
                                    title: "Sin recompensas",
                                    description: "Aquí aparecerán los cupones y premios que hayas canjeado con tus puntos."
                                )
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 24) {
                                        ForEach(redemptions) { redemption in
                                            RedemptionRow(redemption: redemption)
                                                .onTapGesture {
                                                    selectedRedemption = redemption
                                                }
                                        }
                                        .padding(.top, 16)
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .refreshable {
                                    await fetchRedemptions()
                                }
                            }
                        }
                    }
                }

            }
            .navigationTitle("Mis Pedidos")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedRedemption) { redemption in
                RedemptionDetailView(redemption: redemption)
                    .presentationDetents([.medium, .large])
            }
            .task {
                await fetchRedemptions()
            }
        }
    }
    
    @ViewBuilder
    private func emptyState(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(Color.brandGreen.opacity(0.8))
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                
                Text(description)
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
                HStack(spacing: 12) {
                    Text("Explorar NEXE")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 18)
                .background(Color.brandGreen)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.top, 10)
            Spacer()
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    private func fetchRedemptions() async {
        guard let userId = authViewModel.currentUser?.id else { 
            print("DEBUG: No user ID found for fetching redemptions")
            return 
        }
        
        print("DEBUG: Fetching redemptions for user: \(userId.uuidString)")
        await MainActor.run { isLoadingRedemptions = true }
        
        do {
            // Prueba 1: Contar registros sin joins para descartar RLS en tablas unidas
            let countResponse = try await SupabaseManager.shared.client
                .from("user_redemptions")
                .select("id", head: false, count: .exact)
                .eq("user_id", value: userId)
                .execute()
            
            print("DEBUG: Count of redemptions for user: \(countResponse.count ?? 0)")
            
            // Prueba 2: Intento de fetch con joins (Sin created_at por error 42703)
            print("DEBUG: Executing full query with joins...")
            let fetched: [RedemptionRecord] = try await SupabaseManager.shared.client
                .from("user_redemptions")
                .select("""
                    id,
                    status,
                    quantity,
                    rewards (
                        id,
                        title,
                        image_url,
                        stores (
                            name
                        )
                    )
                """)
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("DEBUG: Successfully fetched \(fetched.count) redemptions with joins")
            await MainActor.run {
                self.redemptions = fetched
                self.isLoadingRedemptions = false
            }
        } catch {
            print("DEBUG: Detailed error fetching redemptions: \(error)")
            await MainActor.run { isLoadingRedemptions = false }
        }
    }
}

// MARK: - Models
struct RedemptionRecord: Decodable, Identifiable {
    let id: UUID
    let status: String
    let quantity: Int
    let reward: RewardInfo
    
    struct RewardInfo: Decodable {
        let id: UUID
        let title: String
        let imageURL: String?
        let storeName: String
        
        struct StoreInfo: Decodable {
            let name: String
        }
        
        enum CodingKeys: String, CodingKey {
            case id, title, imageURL = "image_url", stores
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            title = try container.decode(String.self, forKey: .title)
            imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
            
            // Manejar que stores pueda venir como objeto o como array de 1 elemento
            if let storeObj = try? container.decode(StoreInfo.self, forKey: .stores) {
                storeName = storeObj.name
            } else if let storeArr = try? container.decode([StoreInfo].self, forKey: .stores), let first = storeArr.first {
                storeName = first.name
            } else {
                storeName = "Tienda desconocida"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, status, quantity, reward = "rewards"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        status = try container.decode(String.self, forKey: .status)
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity) ?? 1
        
        // Manejar que rewards pueda venir como objeto o como array de 1 elemento
        if let rewardObj = try? container.decode(RewardInfo.self, forKey: .reward) {
            reward = rewardObj
        } else if let rewardArr = try? container.decode([RewardInfo].self, forKey: .reward), let first = rewardArr.first {
            reward = first
        } else {
            throw DecodingError.dataCorruptedError(forKey: .reward, in: container, debugDescription: "Reward data missing or invalid")
        }
    }
}

// MARK: - Views
struct RedemptionRow: View {
    let redemption: RedemptionRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Imagen panorámica
            DemoImage(urlString: redemption.reward.imageURL ?? "", cornerRadius: 24)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(redemption.reward.title)
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Text("x\(redemption.quantity)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.brandGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.brandGreen.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "storefront")
                        .font(.caption)
                    Text(redemption.reward.storeName)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                
                Text("Toca para ver código")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.brandGreen)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 20)
        .contentShape(Rectangle())
        .background(Color.clear)
    }
}

struct RedemptionDetailView: View {
    let redemption: RedemptionRecord
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // CABECERA / CLOSE
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary.opacity(0.5))
                }
            }
            .padding(20)
            
            Spacer()
            
            // CONTENIDO CENTRAL
            VStack(spacing: 24) {
                if let qrImage = generateQRCode(from: "REWARD-\(redemption.id.uuidString)") {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.05), radius: 20)
                }
                
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text(redemption.reward.title)
                            .font(.headline)
                        
                        if redemption.quantity > 1 {
                            Text("x\(redemption.quantity)")
                                .font(.headline.bold())
                                .foregroundStyle(Color.brandGreen)
                        }
                    }
                    
                    Text(redemption.id.uuidString.prefix(8).uppercased())
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.brandGreen.opacity(0.1))
                        .foregroundStyle(Color.brandGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            
            Spacer()
            
            // PIE / INSTRUCCIONES Y BOTÓN
            VStack(spacing: 20) {
                Text("Enseña este código en el local para validar tu recompensa")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button {
                    dismiss()
                } label: {
                    Text("Entendido")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.brandGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 30)
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let shadowImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: shadowImage)
            }
        }
        return nil
    }
}

#Preview {
    OrdersView(selectedTab: .constant(.orders))
}
