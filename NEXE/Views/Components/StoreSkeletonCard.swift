import SwiftUI

struct StoreSkeletonCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Main image area
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.gray.opacity(isAnimating ? 0.08 : 0.16))
                .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    skeletonLine(width: 200, height: 24, cornerRadius: 12)
                    Spacer()
                    skeletonLine(width: 60, height: 24, cornerRadius: 10)
                }
                HStack(spacing: 8) {
                    skeletonLine(width: 60, height: 14, cornerRadius: 4)
                    skeletonLine(width: 80, height: 14, cornerRadius: 4)
                }
                skeletonLine(width: 150, height: 16, cornerRadius: 6)
            }
            .padding(.horizontal, 4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private func skeletonLine(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 6) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.gray.opacity(isAnimating ? 0.08 : 0.16))
            .frame(width: width, height: height)
    }
}
