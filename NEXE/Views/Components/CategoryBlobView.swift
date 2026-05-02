import SwiftUI

struct CategoryBlobView: View {
    let category: HomeCategory
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Text(category.emoji)
                .font(.system(size: 32))
            
            Text(category.name)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? category.color : Color.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 8)
        .frame(minWidth: 70)
    }
}
 
