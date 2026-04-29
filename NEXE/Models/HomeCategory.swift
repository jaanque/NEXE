import SwiftUI

struct HomeCategory: Codable, Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    let sortOrder: Int
    let colorHex: String
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
        case sortOrder = "sort_order"
        case colorHex = "color_hex"
    }
}

