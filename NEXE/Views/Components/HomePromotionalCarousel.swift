import SwiftUI

struct HomePromotionalCarousel: View {
    let banners = [
        BannerItem(title: "¡2x1 en Cafés!", subtitle: "Solo hoy en Origen Coffee", image: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800", color: .orange),
        BannerItem(title: "Nuevos Puntos", subtitle: "Gana el doble en locales premium", image: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800", color: .brandGreen),
        BannerItem(title: "Evento: Street Food", subtitle: "Este sábado en el centro", image: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800", color: .blue)
    ]
    
    var body: some View {
        TabView {
            ForEach(banners) { banner in
                ZStack(alignment: .bottomLeading) {
                    DemoImage(urlString: banner.image, cornerRadius: 24)
                        .overlay(
                            LinearGradient(
                                colors: [banner.color.opacity(0.8), banner.color.opacity(0.2), .clear],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(banner.title)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                        
                        Text(banner.subtitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(24)
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(height: 180)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct BannerItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let image: String
    let color: Color
}
