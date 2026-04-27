import SwiftUI

struct NearbyCardView: View {
    let product: ProductItem
    @State private var isFavorite = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) { 
            // Imagen limpia con Botón de Favoritos
            ZStack(alignment: .topTrailing) {
                DemoImage(urlString: product.imageURL ?? "", cornerRadius: 18)
                    .frame(width: 260, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                Button {
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .bold)) // Más pequeño
                        .foregroundStyle(isFavorite ? .red : .white)
                        .padding(8) // Padding reducido
                        .background(.black.opacity(0.3)) // Un poco más oscuro para legibilidad
                        .clipShape(Circle())
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // 1. Título del producto
                Text(product.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                
                // 2. Punto NEXE (Compacto)
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .offset(x: -2)
                    Text("\(product.rewardPoints) puntos NEXE")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(Color.brandGreen)
                
                // 3. Precio con Descuento
                HStack(alignment: .bottom, spacing: 6) {
                    Text(String(format: "%.2f€", product.price))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(product.originalPrice != nil ? .red : .black)
                    
                    if let original = product.originalPrice {
                        Text(String(format: "%.2f€", original))
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .strikethrough()
                            .padding(.bottom, 1)
                    }
                }
                .padding(.vertical, 2)
                
                // 4. Información adicional
                if let category = product.category {
                    Text(category)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.leading, 1) 
        }
        .frame(width: 260)
    }
}
