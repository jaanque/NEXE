import SwiftUI
import Auth
import Supabase
import CoreImage.CIFilterBuiltins

struct RewardCheckoutView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    
    let reward: RewardItem
    @State private var isRedeeming = false
    @State private var redemptionSuccess = false
    @State private var errorMessage: String?
    @State private var redemptionId: String?
    @State private var quantity = 1
    
    var totalCost: Int { reward.points * quantity }
    var maxQuantity: Int {
        return max(1, reward.stock)
    }
    
    var hasEnoughPoints: Bool {
        let points = authViewModel.userProfile?.points ?? 0
        return points >= totalCost
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if redemptionSuccess {
                        successState
                    } else {
                        checkoutState
                    }
                }
                
                if redemptionSuccess {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                }
            }
            .navigationTitle(redemptionSuccess ? "¡Conseguido!" : "Confirmar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !redemptionSuccess {
                        Button("Cancelar") { dismiss() }
                    }
                }
            }
        }
    }
    
    private var checkoutState: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // Reward Preview Card
                    VStack(alignment: .leading, spacing: 16) {
                        DemoImage(urlString: reward.imageURL ?? "", cornerRadius: 24)
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(reward.title)
                                .font(.title.bold())
                                .foregroundStyle(.primary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "storefront.fill")
                                        .font(.caption)
                                    Text(reward.storeName)
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundStyle(.secondary)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: reward.stock < 10 ? "flame.fill" : "archivebox.fill")
                                        .font(.caption2)
                                    Text(reward.stock < 10 ? "¡Últimas unidades! (\(reward.stock) disp.)" : "\(reward.stock) unidades disponibles")
                                        .font(.caption.bold())
                                }
                                .foregroundStyle(reward.stock < 10 ? Color.brandGranate : .secondary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(reward.stock < 10 ? Color.brandGranate.opacity(0.1) : Color.clear)
                                .clipShape(Capsule())
                                .padding(.leading, reward.stock < 10 ? -8 : 0) // Desplazar hacia la izquierda para alinear el icono con el texto superior
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(.bottom, 10)
                    
                    // Selector de Cantidad Estilo Producto
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Cantidad")
                                .font(.headline)
                            Spacer()
                            Text("Máx. \(reward.stock)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)
                        
                        HStack {
                            Button {
                                if quantity > 1 { 
                                    quantity -= 1
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(quantity > 1 ? Color.brandGreen : .secondary.opacity(0.3))
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                            
                            Spacer()
                            
                            Text("\(quantity)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .frame(minWidth: 40)
                                .contentTransition(.numericText())
                                .animation(.spring(), value: quantity)
                            
                            Spacer()
                            
                            Button {
                                if quantity < maxQuantity { 
                                    quantity += 1
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(quantity < maxQuantity ? Color.brandGreen : .secondary.opacity(0.3))
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    // Points Summary Card
                    VStack(spacing: 0) {
                        summaryRow(title: "Saldo actual", value: "\(authViewModel.userProfile?.points ?? 0) pts")
                        Divider().padding(.horizontal, 20)
                        summaryRow(title: "Coste del canje", value: "-\(totalCost) pts", valueColor: .red, isProminent: true)
                        Divider().padding(.horizontal, 20)
                        summaryRow(title: "Saldo final", value: "\((authViewModel.userProfile?.points ?? 0) - totalCost) pts", valueColor: hasEnoughPoints ? .primary : .red, isDiscrete: true)
                    }
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.02), radius: 10)
                    
                    if !hasEnoughPoints {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("No tienes puntos suficientes para esta cantidad")
                        }
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
            
            // Bottom Action
            VStack {
                Button {
                    redeem()
                } label: {
                    HStack(spacing: 12) {
                        if isRedeeming {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(hasEnoughPoints ? "Canjear \(quantity) \(quantity == 1 ? "unidad" : "unidades")" : "Saldo insuficiente")
                                .font(.headline)
                            Spacer()
                            Text("\(totalCost) pts")
                                .font(.headline)
                                .contentTransition(.numericText())
                                .animation(.spring(), value: totalCost)
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(hasEnoughPoints ? Color.brandGreen : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: (hasEnoughPoints ? Color.brandGreen : Color.gray).opacity(0.3), radius: 10, y: 5)
                }
                .disabled(isRedeeming || !hasEnoughPoints)
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            .background(Color.brandBackground)
        }
        .background(Color.brandBackground)
    }
    
    private func summaryRow(title: String, value: String, valueColor: Color = .primary, isProminent: Bool = false, isDiscrete: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(isProminent ? .headline : .subheadline)
                .foregroundStyle(isDiscrete ? .secondary : .primary)
            Spacer()
            Text(value)
                .font(isProminent ? .title3.bold() : (isDiscrete ? .caption : .subheadline.weight(.semibold)))
                .foregroundStyle(isDiscrete ? .secondary : valueColor)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.spring(), value: value)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, isDiscrete ? 12 : 16)
    }
    
    private var successState: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                if let rid = redemptionId, let qrImage = generateQRCode(from: "REWARD-\(rid)") {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                    
                    Text(rid.prefix(8).uppercased())
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                Text("¡Disfruta de tu \(reward.title)!")
                    .font(.title3.bold())
                Text("Enseña este código en \(reward.storeName) para validarlo.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Guardar en mis recompensas")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    private func redeem() {
        guard let userId = authViewModel.currentUser?.id,
              let currentPoints = authViewModel.userProfile?.points,
              currentPoints >= totalCost else {
            errorMessage = "No tienes puntos suficientes"
            return
        }
        
        isRedeeming = true
        errorMessage = nil
        
        Task {
            do {
                let newPoints = currentPoints - totalCost
                try await authViewModel.updatePoints(to: newPoints)
                
                struct RedemptionRequest: Encodable {
                    let user_id: UUID
                    let reward_id: UUID
                    let status: String
                    let quantity: Int
                }
                
                struct RedemptionResult: Codable {
                    let id: UUID
                }
                
                let request = RedemptionRequest(
                    user_id: userId,
                    reward_id: reward.id,
                    status: "used",
                    quantity: quantity
                )
                
                let response: [RedemptionResult] = try await SupabaseManager.shared.client
                    .from("user_redemptions")
                    .insert(request)
                    .select("id")
                    .execute()
                    .value
                
                // Actualizar stock en la tabla de recompensas
                let newStock = reward.stock - quantity
                try await SupabaseManager.shared.client
                    .from("rewards")
                    .update(["stock": newStock])
                    .eq("id", value: reward.id)
                    .execute()
                
                await MainActor.run {
                    if let first = response.first {
                        self.redemptionId = first.id.uuidString
                    }
                    
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation(.spring()) {
                        redemptionSuccess = true
                        isRedeeming = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isRedeeming = false
                }
            }
        }
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
