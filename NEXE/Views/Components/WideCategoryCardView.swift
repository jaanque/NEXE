import SwiftUI

struct WideCategoryCardView: View {
    let title: String
    let emoji: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(emoji)
                .font(.system(size: 32))
        }
        .padding(.horizontal, 16)
        .frame(width: 160, height: 60)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct WideCategoriesSection: View {
    let items = [
        ("Moda y Ropa", "👕"),
        ("Electrónica", "💻"),
        ("Supermercado", "🛒"),
        ("Servicios", "💈")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(items, id: \.0) { item in
                    WideCategoryCardView(title: item.0, emoji: item.1)
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                                .opacity(phase.isIdentity ? 1.0 : 0.8)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }
}
