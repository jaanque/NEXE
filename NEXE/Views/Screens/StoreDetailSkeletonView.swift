import SwiftUI

struct StoreDetailSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Image Skeleton
            skeletonShape(width: nil, height: 240, cornerRadius: 0)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Store Title & Heart Skeleton
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            skeletonShape(width: 240, height: 38, cornerRadius: 12)
                            Spacer()
                            skeletonShape(width: 44, height: 44, cornerRadius: 12)
                        }
                        
                        // Metadata Skeleton
                        HStack(spacing: 8) {
                            skeletonShape(width: 80, height: 16, cornerRadius: 6)
                            skeletonShape(width: 60, height: 16, cornerRadius: 6)
                            skeletonShape(width: 100, height: 16, cornerRadius: 6)
                        }
                        
                        // Status Badge Skeleton
                        skeletonShape(width: 120, height: 32, cornerRadius: 10)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    
                    Divider().padding(.horizontal, 20).opacity(0.6)
                    
                    // Products List Skeleton
                    VStack(alignment: .leading, spacing: 18) {
                        skeletonShape(width: 140, height: 26, cornerRadius: 12)
                            .padding(.horizontal, 20)
                        
                        ForEach(0..<4, id: \.self) { _ in
                            HStack(spacing: 16) {
                                skeletonShape(width: 90, height: 90, cornerRadius: 16)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    skeletonShape(width: 160, height: 18, cornerRadius: 6)
                                    skeletonShape(width: 80, height: 16, cornerRadius: 6)
                                }
                                
                                Spacer()
                                
                                skeletonShape(width: 80, height: 32, cornerRadius: 12)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
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
