import SwiftUI

struct ExploreSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 36) {
                
                // 1. Search Bar Skeleton
                skeletonShape(width: UIScreen.main.bounds.width - 32, height: 48, cornerRadius: 24)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                
                // 2. Weather Widget Skeleton
                skeletonShape(width: UIScreen.main.bounds.width - 32, height: 90, cornerRadius: 24)
                    .padding(.horizontal, 16)
                
                // 3. Categories Skeleton
                VStack(alignment: .leading, spacing: 18) {
                    skeletonShape(width: 140, height: 26, cornerRadius: 8)
                        .padding(.horizontal, 16)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(0..<6, id: \.self) { _ in
                                VStack(spacing: 8) {
                                    skeletonShape(width: 78, height: 78, cornerRadius: 39)
                                    skeletonShape(width: 50, height: 12, cornerRadius: 6)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // 4. Flash Offers
                skeletonHorizontalSection(titleWidth: 150)
                
                // 5. Inspirations (Stacked layout)
                VStack(alignment: .leading, spacing: 20) {
                    skeletonShape(width: 130, height: 26, cornerRadius: 8)
                        .padding(.horizontal, 16)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<3, id: \.self) { _ in
                                skeletonInspirationCard()
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // 6. Nearby Stores
                VStack(alignment: .leading, spacing: 24) {
                    skeletonShape(width: 180, height: 26, cornerRadius: 8)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 28) {
                        ForEach(0..<3, id: \.self) { _ in
                            skeletonVerticalCard()
                        }
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    @ViewBuilder
    private func skeletonHorizontalSection(titleWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            skeletonShape(width: titleWidth, height: 26, cornerRadius: 8)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 14) {
                            skeletonShape(width: 260, height: 150, cornerRadius: 18)
                            VStack(alignment: .leading, spacing: 8) {
                                skeletonShape(width: 190, height: 18, cornerRadius: 6)
                                skeletonShape(width: 130, height: 14, cornerRadius: 4)
                            }
                        }
                        .frame(width: 260)
                    }
                }
                .padding(.horizontal, 16)
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
            .padding(.horizontal, 12)
        }
        .frame(width: 220)
    }
    
    @ViewBuilder
    private func skeletonVerticalCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            skeletonShape(width: UIScreen.main.bounds.width - 32, height: 180, cornerRadius: 20)
                .padding(.horizontal, 16)
            VStack(alignment: .leading, spacing: 10) {
                skeletonShape(width: 220, height: 20, cornerRadius: 6)
                skeletonShape(width: 160, height: 14, cornerRadius: 4)
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func skeletonShape(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.gray.opacity(isAnimating ? 0.08 : 0.16))
            .frame(width: width, height: height)
    }
}

#Preview {
    ZStack {
        Color.brandBackground.ignoresSafeArea()
        ExploreSkeletonView()
    }
}
