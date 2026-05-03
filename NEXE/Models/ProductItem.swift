import Foundation

struct ProductItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let price: Double
    let originalPrice: Double?
    let imageURL: String?
    let isFlashOffer: Bool
    let rewardPoints: Int
    let isForYou: Bool
    let category: String?
    let storeId: UUID?
    let stock: Int?
    let isFeatured: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case originalPrice = "original_price"
        case imageURL = "image_url"
        case isFlashOffer = "is_flash_offer"
        case rewardPoints = "reward_points"
        case isForYou = "is_for_you"
        case category
        case storeId = "store_id"
        case stock
        case isFeatured = "is_featured"
    }
    
    // Fallbacks estáticos
    static let flashOffers: [ProductItem] = []
    static let rewardPoints: [ProductItem] = []
    static let forYou: [ProductItem] = []
}
