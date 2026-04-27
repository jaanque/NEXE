import SwiftUI

struct IFoodCategoryItemView: View {
    let category: IFoodCategory

    var body: some View {
        VStack(spacing: 8) {
            Text(category.emoji)
                .font(.system(size: 40))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)

            Text(category.title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }
}
