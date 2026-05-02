import SwiftUI

struct StoreDetailSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Header Section Skeleton (Thinner)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            skeletonShape(width: 44, height: 44, cornerRadius: 22)
                                .opacity(0.2)
                            
                            HStack(spacing: 12) {
                                skeletonShape(width: 40, height: 40, cornerRadius: 0)
                                skeletonShape(width: 150, height: 24, cornerRadius: 8)
                            }
                            
                            Spacer()
                            
                            skeletonShape(width: 44, height: 44, cornerRadius: 22)
                                .opacity(0.2)
                        }
                        .padding(.top, 50)
                        
                        // Search Bar Skeleton
                        skeletonShape(width: nil, height: 50, cornerRadius: 16)
                            .opacity(0.15)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .background(Color(hex: "#006CEB")) 
                    
                    Divider() 
                    
                    // Info Secundaria Skeleton
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            skeletonShape(width: 100, height: 28, cornerRadius: 14)
                            skeletonShape(width: 80, height: 28, cornerRadius: 14)
                        }
                        
                        HStack(spacing: 12) {
                            skeletonShape(width: 120, height: 28, cornerRadius: 14)
                            skeletonShape(width: 140, height: 28, cornerRadius: 14)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    
                    Divider().padding(.horizontal, 24).opacity(0.6)
                    
                    // Products List Skeleton
                    VStack(alignment: .leading, spacing: 18) {
                        skeletonShape(width: 180, height: 26, cornerRadius: 8)
                            .padding(.horizontal, 24)
                        
                        ForEach(0..<4, id: \.self) { _ in
                            HStack(spacing: 16) {
                                skeletonShape(width: 80, height: 80, cornerRadius: 12)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    skeletonShape(width: 140, height: 18, cornerRadius: 6)
                                    skeletonShape(width: 60, height: 16, cornerRadius: 6)
                                }
                                
                                Spacer()
                                
                                skeletonShape(width: 36, height: 36, cornerRadius: 10)
                            }
                            .padding(.horizontal, 24)
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
