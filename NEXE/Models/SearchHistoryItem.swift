import Foundation

struct SearchHistoryItem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let query: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case query
        case createdAt = "created_at"
    }
}
