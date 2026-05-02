import SwiftUI

struct CategoryBlobView: View {
    let category: HomeCategory
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Text(category.emoji)
                .font(.system(size: 16))
            
            Text(category.name)
                .font(.system(size: 13, weight: isSelected ? .bold : .bold, design: .rounded))
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .frame(height: 38)
        .background(
            isSelected ? 
            category.color.opacity(0.15) : 
            Color.black.opacity(0.06)
        )
        .foregroundStyle(isSelected ? category.color : Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(category.color.opacity(isSelected ? 0.3 : 0), lineWidth: 1)
        )
    }
}
 
