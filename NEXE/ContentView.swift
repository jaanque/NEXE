//
//  ContentView.swift
//  NEXE
//
//  Created by Jan Queralt Posino on 24/04/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var exploreFocusToken = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView {
                    selectedTab = .explore
                    exploreFocusToken += 1
                }
            }
            .tabItem {
                Label("Inicio", systemImage: "house")
            }
            .tag(AppTab.home)

            NavigationStack {
                ExploreView(focusToken: exploreFocusToken)
            }
            .tabItem {
                Label("Buscar", systemImage: "magnifyingglass")
            }
            .tag(AppTab.explore)

            NavigationStack {
                PlaceholderTabView(
                    title: "Cupones",
                    systemImage: "ticket",
                    description: "Aquí podrás mostrar los cupones activos y su historial."
                )
            }
            .tabItem {
                Label("Cupones", systemImage: "ticket")
            }
            .tag(AppTab.coupons)

            NavigationStack {
                PlaceholderTabView(
                    title: "Perfil",
                    systemImage: "person.crop.circle",
                    description: "Aquí podrás añadir perfil, favoritos y ajustes."
                )
            }
            .tabItem {
                Label("Perfil", systemImage: "person.crop.circle")
            }
            .tag(AppTab.profile)
        }
    }
}

private enum AppTab {
    case home
    case explore
    case coupons
    case profile
}

private struct HomeView: View {
    let onExploreTap: () -> Void

    private let categories = CategoryItem.samples
    private let flashDeals = ProductCard.flashDeals
    private let rewards = RewardCard.samples
    private let selection = ProductCard.personalized
    private let stores = StoreItem.samples

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                header
                categorySection
                flashDealsSection
                rewardsSection
                personalizedSection
                storesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                PointsPill(pointsText: "2.480 puntos")

                Spacer()

                NotificationButton(count: 3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Hola, Jan")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Descubre ofertas y experiencias en Lleida")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
            }

            Button(action: onExploreTap) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    Text("Busca planes, locales o promociones")
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .font(.body)
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Categorías", actionTitle: "Ver todo")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(categories) { category in
                        UberEatsCategoryItem(item: category)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var flashDealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Ofertas flash", subtitle: "Caducan hoy", actionTitle: "Ver más")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(flashDeals) { product in
                        ProductCardView(product: product, accent: .red)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Recompensas con puntos", subtitle: "Canjea experiencias", actionTitle: "Ver más")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(rewards) { reward in
                        RewardCardView(reward: reward)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var personalizedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Selección para ti", subtitle: "Basado en tus favoritos", actionTitle: "Ver más")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(selection) { product in
                        ProductCardView(product: product, accent: Color.accentColor)
                    }

                    SeeMoreCard()
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var storesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Locales cerca de ti", subtitle: "Directorio", actionTitle: "Mapa")

            LazyVStack(spacing: 16) {
                ForEach(stores) { store in
                    StoreRowView(store: store)
                }
            }
        }
    }
}

private struct ExploreView: View {
    let focusToken: Int

    @FocusState private var isSearchFocused: Bool
    @State private var query = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Busca locales, categorías o planes", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isSearchFocused)
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text("Explorar")
                    .font(.title2.bold())

                Text("Aquí podrás conectar el buscador real, filtros y resultados cuando empieces con backend.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Buscar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isSearchFocused = true
        }
        .onChange(of: focusToken) { _, _ in
            isSearchFocused = true
        }
    }
}

private struct PlaceholderTabView: View {
    let title: String
    let systemImage: String
    let description: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 36))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title2.bold())

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(title)
    }
}

private struct PointsPill: View {
    let pointsText: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.orange)

            Text(pointsText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(Capsule())
    }
}

private struct NotificationButton: View {
    let count: Int

    var body: some View {
        Button {
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(Circle())

                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SectionHeader: View {
    let title: String
    var subtitle: String?
    let actionTitle: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.bold())

                if let subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(actionTitle) {
            }
            .font(.footnote.weight(.semibold))
        }
    }
}

private struct UberEatsCategoryItem: View {
    let item: CategoryItem

    var body: some View {
        VStack(spacing: 10) {
            DemoImage(urlString: item.imageURL, cornerRadius: 34)
                .frame(width: 68, height: 68)
                .clipShape(Circle())

            Text(item.title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 78)
        }
    }
}

private struct ProductCardView: View {
    let product: ProductCard
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                DemoImage(urlString: product.imageURL, cornerRadius: 16)
                    .frame(width: 292, height: 164)
                    .overlay(alignment: .bottomLeading) {
                        if let timer = product.countdown {
                            Text(timer)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.black.opacity(0.72))
                                .clipShape(Capsule())
                                .padding(12)
                        }
                    }

                Button {
                } label: {
                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(product.isFavorite ? accent : .primary)
                        .frame(width: 34, height: 34)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(10)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(product.offerPrice)
                        .font(.title3.bold())
                        .foregroundStyle(accent)

                    Text(product.originalPrice)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .strikethrough()
                }

                HStack(spacing: 8) {
                    Text(product.storeName)
                    Label(product.distance, systemImage: "location")
                    Label(product.rating, systemImage: "star.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if let badge = product.topBadge {
                    Text(badge)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 292, alignment: .leading)
    }
}

private struct RewardCardView: View {
    let reward: RewardCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DemoImage(urlString: reward.imageURL, cornerRadius: 16)
                .frame(width: 240, height: 144)
                .overlay(alignment: .topLeading) {
                    Label("\(reward.points) pts", systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.68))
                        .clipShape(Capsule())
                        .padding(12)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(reward.title)
                    .font(.headline)

                Text(reward.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(reward.cityTag)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 240, alignment: .leading)
    }
}

private struct SeeMoreCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "square.grid.2x2")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.accentColor)

            Text("Ver catálogo completo")
                .font(.headline)

            Text("Abre todos los productos y filtros disponibles.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text("Ver más")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.accentColor)
        }
        .padding(16)
        .frame(width: 200, height: 272, alignment: .topLeading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct StoreRowView: View {
    let store: StoreItem

    var body: some View {
        HStack(spacing: 14) {
            DemoImage(urlString: store.imageURL, cornerRadius: 12)
                .frame(width: 84, height: 84)

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.name)
                            .font(.headline)
                            .lineLimit(1)

                        Text(store.category)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    if let ranking = store.topBadge {
                        Text(ranking)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }

                HStack(spacing: 10) {
                    Label(store.distance, systemImage: "location")
                    Label(store.rating, systemImage: "star.fill")
                    Label(store.reviews, systemImage: "text.bubble")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

private struct DemoImage: View {
    let urlString: String
    let cornerRadius: CGFloat

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholder
            @unknown default:
                placeholder
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))

            Image(systemName: "photo")
                .font(.title3)
                .foregroundStyle(.tertiary)
        }
    }
}

private struct CategoryItem: Identifiable {
    let id = UUID()
    let title: String
    let imageURL: String

    static let samples: [CategoryItem] = [
        .init(title: "Burger", imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=300&q=80"),
        .init(title: "Sushi", imageURL: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=300&q=80"),
        .init(title: "Brunch", imageURL: "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=300&q=80"),
        .init(title: "Moda", imageURL: "https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=300&q=80"),
        .init(title: "Cine", imageURL: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80"),
        .init(title: "Teatro", imageURL: "https://images.unsplash.com/photo-1503095396549-807759245b35?auto=format&fit=crop&w=300&q=80")
    ]
}

private struct ProductCard: Identifiable {
    let id = UUID()
    let name: String
    let offerPrice: String
    let originalPrice: String
    let storeName: String
    let distance: String
    let rating: String
    let topBadge: String?
    let countdown: String?
    let isFavorite: Bool
    let imageURL: String

    static let flashDeals: [ProductCard] = [
        .init(
            name: "Menú sushi premium para dos",
            offerPrice: "18,90 €",
            originalPrice: "31,00 €",
            storeName: "Sakura Ponent",
            distance: "500 m",
            rating: "4,8",
            topBadge: "#1 en Restauración",
            countdown: "02:14:09",
            isFavorite: true,
            imageURL: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=900&q=80"
        ),
        .init(
            name: "Pack burger + bebida XL",
            offerPrice: "9,90 €",
            originalPrice: "15,50 €",
            storeName: "District Burgers",
            distance: "1,2 km",
            rating: "4,7",
            topBadge: "#2 en Smash Burgers",
            countdown: "01:08:42",
            isFavorite: false,
            imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80"
        )
    ]

    static let personalized: [ProductCard] = [
        .init(
            name: "Entradas 2x1 para cine de autor",
            offerPrice: "12,00 €",
            originalPrice: "18,00 €",
            storeName: "Screen Lleida",
            distance: "900 m",
            rating: "4,6",
            topBadge: "#3 en Cultura",
            countdown: nil,
            isFavorite: true,
            imageURL: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=900&q=80"
        ),
        .init(
            name: "Brunch saludable con café de especialidad",
            offerPrice: "14,50 €",
            originalPrice: "19,50 €",
            storeName: "Verd & Brasa",
            distance: "650 m",
            rating: "4,9",
            topBadge: nil,
            countdown: nil,
            isFavorite: false,
            imageURL: "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=900&q=80"
        ),
        .init(
            name: "Zapatillas urbanas edición outlet",
            offerPrice: "49,00 €",
            originalPrice: "79,00 €",
            storeName: "Rambla Sport",
            distance: "2,1 km",
            rating: "4,5",
            topBadge: "#2 en Moda deportiva",
            countdown: nil,
            isFavorite: true,
            imageURL: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80"
        )
    ]
}

private struct RewardCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let points: Int
    let cityTag: String
    let imageURL: String

    static let samples: [RewardCard] = [
        .init(
            title: "Entradas de cine",
            subtitle: "Sesión doble en pantalla grande",
            points: 900,
            cityTag: "Lleida ciudad",
            imageURL: "https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=900&q=80"
        ),
        .init(
            title: "Teatro principal",
            subtitle: "Butacas para la próxima función",
            points: 1450,
            cityTag: "Centro histórico",
            imageURL: "https://images.unsplash.com/photo-1503095396549-807759245b35?auto=format&fit=crop&w=900&q=80"
        ),
        .init(
            title: "Acceso Fecoll",
            subtitle: "Experiencia local con puntos",
            points: 1100,
            cityTag: "Evento de ciudad",
            imageURL: "https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=900&q=80"
        )
    ]
}

private struct StoreItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let distance: String
    let rating: String
    let reviews: String
    let topBadge: String?
    let imageURL: String

    static let samples: [StoreItem] = [
        .init(
            name: "La Bodegueta Urbana",
            category: "Tapas y cocina local",
            distance: "300 m",
            rating: "4,9",
            reviews: "218 reseñas",
            topBadge: "#1 en Tapas",
            imageURL: "https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=500&q=80"
        ),
        .init(
            name: "Lleida Sneakers Club",
            category: "Moda y calzado",
            distance: "1,4 km",
            rating: "4,7",
            reviews: "124 reseñas",
            topBadge: "#3 en Streetwear",
            imageURL: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=500&q=80"
        ),
        .init(
            name: "Farmàcia Segre",
            category: "Salud y bienestar",
            distance: "800 m",
            rating: "4,8",
            reviews: "89 reseñas",
            topBadge: nil,
            imageURL: "https://images.unsplash.com/photo-1585435557343-3b092031a831?auto=format&fit=crop&w=500&q=80"
        ),
        .init(
            name: "Teatre de Ponent",
            category: "Cultura",
            distance: "1,1 km",
            rating: "4,6",
            reviews: "156 reseñas",
            topBadge: "#2 en Cultura",
            imageURL: "https://images.unsplash.com/photo-1503095396549-807759245b35?auto=format&fit=crop&w=500&q=80"
        )
    ]
}

#Preview {
    ContentView()
}
