import SwiftUI

struct RewardsSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // 1. Puntos Skeleton
                VStack(spacing: 12) {
                    skeletonShape(width: 120, height: 64, cornerRadius: 12)
                    skeletonShape(width: 140, height: 16, cornerRadius: 4)
                }
                .padding(.top, 40)
                
                // 2. Título Sección
                VStack(alignment: .leading, spacing: 0) {
                    skeletonShape(width: 130, height: 16, cornerRadius: 4)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    
                    // 3. Lista de Recompensas
                    VStack(spacing: 24) {
                        ForEach(0..<3, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 12) {
                                // Imagen panorámica
                                skeletonShape(width: UIScreen.main.bounds.width - 32, height: 180, cornerRadius: 20)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    skeletonShape(width: 200, height: 22, cornerRadius: 6)
                                    skeletonShape(width: 120, height: 14, cornerRadius: 4)
                                    skeletonShape(width: 100, height: 16, cornerRadius: 4)
                                        .padding(.top, 2)
                                }
                                .padding(.horizontal, 4)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    @ViewBuilder
    private func skeletonShape(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.gray.opacity(0.1))
            .frame(width: width, height: height)
            .overlay(
                GeometryReader { geo in
                    LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 200)
                        .offset(x: isAnimating ? geo.size.width : -200)
                }
            )
            .clipped()
    }
}

#Preview {
    ZStack {
        Color.brandBackground.ignoresSafeArea()
        RewardsSkeletonView()
    }
}
