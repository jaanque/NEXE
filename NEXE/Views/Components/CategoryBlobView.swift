import SwiftUI

struct CategoryBlobView: View {
    let category: HomeCategory
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                BlobShape(seed: category.id.hashValue)
                    .fill(isSelected ? category.color.opacity(0.18) : Color.black.opacity(0.001))
                    .frame(width: 78, height: 78)
                    .rotationEffect(.degrees(Double(abs(category.id.hashValue) % 360)))
                
                Text(category.emoji)
                    .font(.system(size: 40))
                    .shadow(color: .black.opacity(isSelected ? 0 : 0.08), radius: 2, x: 0, y: 1)
            }
            .frame(width: 84, height: 84)
            .contentShape(Rectangle())
            
            Text(category.name)
                .font(.caption2.weight(.medium))
                .foregroundStyle(isSelected ? category.color : .primary)
                .lineLimit(1)
        }
    }
}
 
