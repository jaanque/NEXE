import SwiftUI

struct PromoBannerView: View {
    var isClaimed: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            
            Image(systemName: isClaimed ? "checkmark.seal.fill" : "gift.fill")
                .font(.system(size: 20))
                .foregroundStyle(isClaimed ? .white : Color.yellow)
            
            Text(isClaimed ? "50 puntos reclamados" : "Reclamar 50 puntos")
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.brandGreen)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
}
