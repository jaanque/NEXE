import SwiftUI

struct InspirationItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let images: [String]
    let tag: String
    
    static let samples: [InspirationItem] = [
        .init(
            title: "Ruta del Café",
            subtitle: "Los mejores tostaderos de Lleida",
            images: [
                "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&q=80",
                "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&q=80",
                "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=400&q=80"
            ],
            tag: "RECOMENDADO"
        ),
        .init(
            title: "Ruta Burger",
            subtitle: "Hamburgesas gourmet de la ciudad",
            images: [
                "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80",
                "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400&q=80",
                "https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=400&q=80"
            ],
            tag: "TENDENCIA"
        ),
        .init(
            title: "Ruta Gourmet",
            subtitle: "Experiencias culinarias únicas",
            images: [
                "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80",
                "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400&q=80",
                "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=400&q=80"
            ],
            tag: "EDITORIAL"
        )
    ]
}

struct InspirationCardView: View {
    let item: InspirationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // EL ABANICO DE FOTOS (Refinado y Ponderado)
            ZStack {
                ForEach(Array(item.images.enumerated()), id: \.offset) { index, url in
                    photoCard(url: url, index: index)
                }
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            
            // CONTENIDO TEXTUAL ESTILO APPLE NEWS
            VStack(alignment: .leading, spacing: 6) {
                Text(item.tag)
                    .font(.system(size: 10, weight: .black))
                    .kerning(1.2)
                    .foregroundStyle(Color.brandGreen)
                
                Text(item.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(item.subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .frame(width: 220)
    }
    
    @ViewBuilder
    private func photoCard(url: String, index: Int) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.brandBackground
        }
        .frame(width: 110, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white, lineWidth: 2)
        )
        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
            let factor = 1.0 - abs(phase.value)
            let rotation = Double(index - 1) * 8 * max(0, factor)
            let xOffset = CGFloat(index - 1) * 28 * max(0, factor)
            let scale = phase.isIdentity ? 1.0 : 0.95
            
            return content
                .rotationEffect(.degrees(rotation))
                .offset(x: xOffset, y: abs(CGFloat(index - 1)) * 6 * max(0, factor))
                .scaleEffect(scale)
        }
        .zIndex(index == 1 ? 2 : 1)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
