import SwiftUI

struct StoreSkeletonCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main image area
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray.opacity(isAnimating ? 0.08 : 0.16))
                .frame(height: 180)
            
            VStack(alignment: .leading, spacing: 10) {
                skeletonLine(width: 240, height: 22)
                HStack(spacing: 8) {
                    skeletonLine(width: 60, height: 14)
                    skeletonLine(width: 80, height: 14)
                }
                skeletonLine(width: 150, height: 16)
            }
            .padding(.horizontal, 4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private func skeletonLine(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.gray.opacity(isAnimating ? 0.08 : 0.16))
            .frame(width: width, height: height)
    }
}
