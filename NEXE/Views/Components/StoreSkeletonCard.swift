import SwiftUI

struct StoreSkeletonCard: View {
    @State private var isAnimating = false
    var isVertical: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main image area
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.gray.opacity(isAnimating ? 0.08 : 0.16))
                .frame(width: isVertical ? nil : 240, height: isVertical ? 200 : 140)
                .frame(maxWidth: isVertical ? .infinity : 240)
            
            VStack(alignment: .leading, spacing: 8) {
                // Fila 1: Título + Favorito/Rating
                HStack {
                    skeletonLine(width: isVertical ? 180 : 140, height: 20, cornerRadius: 10)
                    Spacer()
                    skeletonLine(width: 30, height: 20, cornerRadius: 10)
                }
                
                // Fila 2: Puntos
                skeletonLine(width: 120, height: 14, cornerRadius: 6)
                
                // Fila 3: Metadatos mixtos
                HStack(spacing: 8) {
                    skeletonLine(width: 60, height: 12, cornerRadius: 4)
                    skeletonLine(width: 80, height: 12, cornerRadius: 4)
                    if isVertical {
                        skeletonLine(width: 50, height: 12, cornerRadius: 4)
                    }
                }
            }
            .padding(.horizontal, 4)
            .frame(width: isVertical ? nil : 240, alignment: .leading)
            .frame(maxWidth: isVertical ? .infinity : 240)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private func skeletonLine(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 6) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.gray.opacity(isAnimating ? 0.08 : 0.16))
            .frame(width: width, height: height)
    }
}
