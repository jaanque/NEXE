import SwiftUI

struct HomeSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // 1. Address Header Skeleton (Search + Points)
                HStack(spacing: 12) {
                    skeletonShape(width: UIScreen.main.bounds.width - 120, height: 44, cornerRadius: 22)
                    skeletonShape(width: 80, height: 44, cornerRadius: 22)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // 2. Filter Chips Skeleton
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<5, id: \.self) { _ in
                            skeletonShape(width: 90, height: 36, cornerRadius: 18)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // 3. Categories Skeleton
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
                

                
                // 5. Nearby Vertical Stores
                VStack(alignment: .leading, spacing: 24) {
                    skeletonShape(width: 120, height: 26, cornerRadius: 8)
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
                                skeletonShape(width: 200, height: 18, cornerRadius: 6)
                                skeletonShape(width: 140, height: 14, cornerRadius: 4)
                                skeletonShape(width: 90, height: 18, cornerRadius: 6)
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
    private func skeletonVerticalCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main image area
            skeletonShape(width: UIScreen.main.bounds.width - 32, height: 180, cornerRadius: 20)
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 10) {
                skeletonShape(width: 240, height: 22, cornerRadius: 6)
                HStack(spacing: 8) {
                    skeletonShape(width: 60, height: 14, cornerRadius: 4)
                    skeletonShape(width: 80, height: 14, cornerRadius: 4)
                }
                skeletonShape(width: 150, height: 16, cornerRadius: 6)
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
        HomeSkeletonView()
    }
}
