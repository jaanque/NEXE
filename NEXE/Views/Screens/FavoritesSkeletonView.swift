import SwiftUI

struct FavoritesSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                ForEach(0..<2, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 20) {
                        // Date Header Skeleton
                        skeletonShape(width: 120, height: 20, cornerRadius: 12)
                            .padding(.horizontal, 24)
                        
                        // Vertical Card Skeleton (Store/Product)
                        VStack(alignment: .leading, spacing: 14) {
                            skeletonShape(width: nil, height: 200, cornerRadius: 24)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                skeletonShape(width: 220, height: 24, cornerRadius: 12)
                                skeletonShape(width: 160, height: 16, cornerRadius: 6)
                                skeletonShape(width: 100, height: 20, cornerRadius: 8)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 30)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    @ViewBuilder
    private func skeletonShape(width: CGFloat?, height: CGFloat, cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.gray.opacity(0.1))
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
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
