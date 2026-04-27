import SwiftUI

struct HomeFilterChipsView: View {
    @State private var deliveryMode = 0 // 0 for Delivery, 1 for Pickup
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                // Filter icon chip
                Button {} label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Sort chip
                Button {} label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Ordenar")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Open Now chip
                Button {} label: {
                    Text("Abierto Ahora")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Points chip
                Button {} label: {
                    HStack(spacing: 4) {
                        Image(systemName: "star.circle.fill")
                            .foregroundStyle(.yellow)
                        Text("Acepta Puntos")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Offers chip
                Button {} label: {
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .foregroundStyle(Color.brandGreen)
                        Text("Ofertas Hoy")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Reserve chip
                Button {} label: {
                    Text("Reserva Inmediata")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
    }
}
