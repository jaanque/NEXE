import Foundation

struct Profile: Codable, Equatable {
    let id: UUID
    var points: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case points
    }
}
