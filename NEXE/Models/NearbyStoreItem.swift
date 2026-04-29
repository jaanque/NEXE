import Foundation

struct NearbyStoreItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let rating: Double
    let reviewsCount: Int
    let categoryId: UUID?
    let imageURL: String?
    let description: String?
    let address: String?
    let isNew: Bool
    let givesPoints: Bool
    let logoURL: String?
    
    // El campo distance es dinámico o fallback en la app por ahora
    var distance: String { "300m" }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case rating
        case reviewsCount = "reviews_count"
        case categoryId = "category_id"
        case imageURL = "image_url"
        case description
        case address
        case isNew = "is_new"
        case givesPoints = "gives_points"
        case logoURL = "logo_url"
    }
    
    // Mantenemos los samples como fallback por si falla la red
    static let samples: [NearbyStoreItem] = [
        .init(id: UUID(), name: "Philz Coffee", rating: 4.8, reviewsCount: 1250, categoryId: UUID(), imageURL: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&q=80", description: "Café artesanal.", address: "Lleida", isNew: true, givesPoints: true, logoURL: "https://viterboristorante.it/wp-content/uploads/2019/04/philz-coffee-logo.png"),
        .init(id: UUID(), name: "The Grove", rating: 4.5, reviewsCount: 850, categoryId: UUID(), imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80", description: "Comida rica.", address: "Lleida", isNew: true, givesPoints: false, logoURL: nil)
    ]
}
