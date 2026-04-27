import SwiftUI

struct HomeSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Filter Chips Skeleton
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { _ in
                            skeletonShape(width: 80, height: 36, cornerRadius: 18)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Categories Skeleton
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(0..<5, id: \.self) { _ in
                            VStack(spacing: 6) {
                                skeletonShape(width: 78, height: 78, cornerRadius: 39)
                                skeletonShape(width: 50, height: 12, cornerRadius: 6)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Flash Offers Skeleton
                skeletonSection(titleWidth: 120, height: 250)
                
                // Rewards Skeleton
                skeletonSection(titleWidth: 180, height: 250)
                
                // For You Skeleton
                skeletonSection(titleWidth: 140, height: 250)
                
                // Nearby Skeleton
                VStack(alignment: .leading, spacing: 20) {
                    skeletonShape(width: 100, height: 24, cornerRadius: 8)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 24) {
                        ForEach(0..<3, id: \.self) { _ in
                            skeletonShape(width: UIScreen.main.bounds.width - 32, height: 280, cornerRadius: 22)
                        }
                    }
                }
            }
            .padding(.bottom, 28)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    @ViewBuilder
    private func skeletonSection(titleWidth: CGFloat, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            skeletonShape(width: titleWidth, height: 24, cornerRadius: 8)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        skeletonShape(width: 260, height: height, cornerRadius: 18)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    @ViewBuilder
    private func skeletonShape(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.gray.opacity(isAnimating ? 0.1 : 0.2))
            .frame(width: width, height: height)
    }
}

#Preview {
    ZStack {
        Color.brandBackground.ignoresSafeArea()
        HomeSkeletonView()
    }
}
