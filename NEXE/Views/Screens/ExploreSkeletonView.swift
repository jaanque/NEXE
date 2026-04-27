import SwiftUI

struct ExploreSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                
                // Weather Widget Skeleton
                skeletonShape(width: UIScreen.main.bounds.width - 32, height: 90, cornerRadius: 24)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                
                // Categories Skeleton
                VStack(alignment: .leading, spacing: 16) {
                    skeletonShape(width: 120, height: 24, cornerRadius: 8)
                        .padding(.horizontal, 16)
                    
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
                }
                
                // Flash Offers Skeleton
                skeletonSection(titleWidth: 140, itemWidth: 260, itemHeight: 250)
                
                // Inspiration Skeleton
                skeletonSection(titleWidth: 110, itemWidth: 220, itemHeight: 280) // Slightly taller/narrower for Inspiration
                
                // Nearby Skeleton
                VStack(alignment: .leading, spacing: 20) {
                    skeletonShape(width: 200, height: 24, cornerRadius: 8)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 24) {
                        ForEach(0..<3, id: \.self) { _ in
                            skeletonShape(width: UIScreen.main.bounds.width - 32, height: 280, cornerRadius: 22)
                        }
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    @ViewBuilder
    private func skeletonSection(titleWidth: CGFloat, itemWidth: CGFloat, itemHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            skeletonShape(width: titleWidth, height: 24, cornerRadius: 8)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        skeletonShape(width: itemWidth, height: itemHeight, cornerRadius: 18)
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
        ExploreSkeletonView()
    }
}
