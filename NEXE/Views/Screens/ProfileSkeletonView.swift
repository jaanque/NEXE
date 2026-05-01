import SwiftUI

struct ProfileSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // 1. Cabecera Skeleton
                VStack(spacing: 16) {
                    skeletonShape(width: 80, height: 80, cornerRadius: 40) // Avatar
                    
                    VStack(spacing: 8) {
                        skeletonShape(width: 120, height: 20, cornerRadius: 6) // Name
                        skeletonShape(width: 100, height: 14, cornerRadius: 4) // Status
                    }
                }
                .padding(.top, 20)
                
                // 2. Banner de Puntos Skeleton
                skeletonShape(width: UIScreen.main.bounds.width - 40, height: 90, cornerRadius: 16)
                
                // 3. Secciones Simples Skeletons
                VStack(spacing: 24) {
                    // Grupo 1
                    VStack(spacing: 1) {
                        ForEach(0..<3, id: \.self) { _ in
                            skeletonRow()
                        }
                    }
                    .background(Color.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Grupo 2
                    VStack(spacing: 1) {
                        ForEach(0..<3, id: \.self) { _ in
                            skeletonRow()
                        }
                    }
                    .background(Color.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Botón Salir
                    skeletonShape(width: UIScreen.main.bounds.width - 40, height: 56, cornerRadius: 12)
                }
                
                skeletonShape(width: 80, height: 12, cornerRadius: 4) // Version
                    .padding(.top, 20)
            }
            .padding(20)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    @ViewBuilder
    private func skeletonRow() -> some View {
        HStack(spacing: 16) {
            skeletonShape(width: 24, height: 24, cornerRadius: 6) // Icon
            skeletonShape(width: 140, height: 16, cornerRadius: 4) // Title
            Spacer()
            skeletonShape(width: 10, height: 14, cornerRadius: 2) // Chevron
        }
        .padding()
        .frame(height: 56)
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
        ProfileSkeletonView()
    }
}
