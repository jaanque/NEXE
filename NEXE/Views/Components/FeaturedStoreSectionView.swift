import SwiftUI

struct FeaturedStoreSectionView: View {
    let store: NearbyStoreItem
    let products: [ProductItem]
    let categoryEmoji: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ... (rest of the body remains same, just passing categoryEmoji if needed)
            // ...
            HStack(spacing: 12) {
                if let logoURL = store.logoURL {
                    DemoImage(urlString: logoURL, cornerRadius: 8)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ofertas exclusivas")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("En \(store.name)")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                NavigationLink(destination: StoreDetailView(store: store)) {
                    Text("Ver todo")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: store.brandColorHex ?? "#006CEB"))
                        .underline()
                }
            }
            .padding(.horizontal, 16)
            
            // ── Carrusel ──
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // 1. Brand Card (Special)
                    brandCard
                        .padding(.leading, 16)
                    
                    // 2. Product Cards
                    ForEach(products.prefix(5)) { product in
                        FeaturedProductCard(product: product, brandColor: Color(hex: store.brandColorHex ?? "#006CEB"))
                    }
                }
                .padding(.trailing, 16)
            }
        }
    }
    
    private var brandCard: some View {
        NavigationLink(destination: StoreDetailView(store: store)) {
            ZStack(alignment: .bottomLeading) {
                // Background Mosaic Pattern (Mosaico)
                if let emoji = categoryEmoji {
                    Canvas { context, size in
                        let spacing: CGFloat = 40
                        let columns = Int(size.width / spacing) + 2
                        let rows = Int(size.height / spacing) + 2
                        
                        for row in 0..<rows {
                            for col in 0..<columns {
                                var innerContext = context
                                let x = CGFloat(col) * spacing + (row % 2 == 0 ? 0 : spacing/2)
                                let y = CGFloat(row) * spacing
                                
                                innerContext.opacity = 0.35 // Aumentado de 0.15
                                innerContext.translateBy(x: x, y: y)
                                innerContext.rotate(by: .degrees(Double((row + col) % 4) * 15))
                                
                                innerContext.draw(Text(emoji).font(.system(size: 24)), at: .zero) // Aumentado de 18
                            }
                        }
                    }
                    .allowsHitTesting(false)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Logo pequeño arriba
                    if let logoURL = store.logoURL {
                        DemoImage(urlString: logoURL, cornerRadius: 4)
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                    
                    // Texto central
                    Text("Compra a los mejores precios")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Fecha o Info inferior
                    Text("Promoción semanal")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .frame(width: 160, height: 240)
            .background(Color(hex: store.brandColorHex ?? "#006CEB"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

struct FeaturedProductCard: View {
    let product: ProductItem
    let brandColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Imagen con botón "+"
            ZStack(alignment: .topTrailing) {
                DemoImage(urlString: product.imageURL ?? "", cornerRadius: 16)
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(brandColor)
                        .clipShape(Circle())
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Precios
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(product.price.formatted(.currency(code: "EUR")))
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    if let original = product.originalPrice {
                        Text(original.formatted(.currency(code: "EUR")))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .strikethrough()
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                // Descuento (Badge amarillo)
                if let original = product.originalPrice, original > product.price {
                    let discount = Int((1 - (product.price / original)) * 100)
                    Text("\(discount)% off")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.yellow)
                        .clipShape(Rectangle())
                }
                
                // Nombres
                Text(product.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                
                Text(product.category ?? "Producto")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 140)
        }
        .frame(width: 140)
    }
}
