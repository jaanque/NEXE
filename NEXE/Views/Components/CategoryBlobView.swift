import SwiftUI

struct CategoryBlobView: View {
    let category: HomeCategory
    let isSelected: Bool
    var isCompact: Bool = false
    var namespace: Namespace.ID? = nil
    
    @Namespace private var localNamespace
    
    var body: some View {
        let ns = namespace ?? localNamespace
        
        Group {
            if isCompact {
                // Horizontal Pill (Scrolled / Sticky)
                HStack(spacing: 8) {
                    Text(category.emoji)
                        .font(.system(size: 16))
                        .matchedGeometryEffect(id: "emoji-\(category.id)", in: ns)
                    
                    Text(category.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .matchedGeometryEffect(id: "name-\(category.id)", in: ns)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        .matchedGeometryEffect(id: "bg-\(category.id)", in: ns)
                }
                .padding(.vertical, 2)
            } else {
                // Vertical Item (Initial / In-flow)
                VStack(spacing: 8) {
                    Text(category.emoji)
                        .font(.system(size: 34))
                        .matchedGeometryEffect(id: "emoji-\(category.id)", in: ns)
                    
                    Text(category.name)
                        .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? category.color : Color.secondary)
                        .lineLimit(1)
                        .matchedGeometryEffect(id: "name-\(category.id)", in: ns)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .frame(minWidth: 74)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .matchedGeometryEffect(id: "bg-\(category.id)", in: ns)
                }
            }
        }
        .contentShape(Rectangle())
    }
}
 
