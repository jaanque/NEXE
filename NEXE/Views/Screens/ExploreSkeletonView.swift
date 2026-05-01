import SwiftUI

struct ExploreSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                
                // 1. Search Bar Skeleton (exploreHeader)
                VStack(alignment: .leading, spacing: 8) {
                    skeletonShape(width: 140, height: 28, cornerRadius: 8)
                    skeletonShape(width: UIScreen.main.bounds.width - 32, height: 54, cornerRadius: 18)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // 2. Inspiración
                VStack(alignment: .leading, spacing: 20) {
                    skeletonShape(width: 130, height: 26, cornerRadius: 8)
                        .padding(.horizontal, 16)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(0..<3, id: \.self) { _ in
                                skeletonInspirationCard()
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                
                // 3. NEXE Curated
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        skeletonShape(width: 30, height: 30, cornerRadius: 15)
                        skeletonShape(width: 180, height: 26, cornerRadius: 8)
                        skeletonShape(width: 30, height: 30, cornerRadius: 15)
                    }
                    .frame(maxWidth: .infinity)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(0..<2, id: \.self) { _ in
                                skeletonShape(width: 220, height: 300, cornerRadius: 28)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // 4. Recién llegados
                VStack(alignment: .leading, spacing: 20) {
                    skeletonShape(width: 220, height: 26, cornerRadius: 8)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 32) {
                        ForEach(0..<2, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 16) {
                                skeletonShape(width: UIScreen.main.bounds.width - 32, height: 220, cornerRadius: 24)
                                VStack(alignment: .leading, spacing: 10) {
                                    skeletonShape(width: 240, height: 24, cornerRadius: 6)
                                    skeletonShape(width: 160, height: 16, cornerRadius: 4)
                                }
                                .padding(.horizontal, 8)
                            }
                            .padding(.horizontal, 16)
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
    private func skeletonInspirationCard() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                skeletonShape(width: 110, height: 140, cornerRadius: 16)
                    .rotationEffect(.degrees(-8))
                    .offset(x: -20)
                skeletonShape(width: 110, height: 140, cornerRadius: 16)
                    .rotationEffect(.degrees(8))
                    .offset(x: 20)
                skeletonShape(width: 110, height: 150, cornerRadius: 16)
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 8) {
                skeletonShape(width: 150, height: 18, cornerRadius: 6)
                skeletonShape(width: 110, height: 12, cornerRadius: 4)
            }
        }
        .frame(width: 220)
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
        ExploreSkeletonView()
    }
}
