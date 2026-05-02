import SwiftUI

struct CuratedCardView: View {
    let title: String
    let store: String
    let image: String
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: image)) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.1)
            }
            .frame(width: 220, height: 300)
            .overlay(
                LinearGradient(colors: [.black.opacity(0.6), .clear, .clear], startPoint: .bottom, endPoint: .top)
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(store)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}
