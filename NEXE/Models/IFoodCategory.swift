import SwiftUI

struct IFoodCategory: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let bgColor: Color

    static let samples: [IFoodCategory] = [
        .init(title: "Zapaterías", emoji: "👞", bgColor: Color.orange.opacity(0.15)),
        .init(title: "Peluquerías", emoji: "✂️", bgColor: Color.blue.opacity(0.15)),
        .init(title: "Ferreterías", emoji: "🛠️", bgColor: Color.red.opacity(0.15)),
        .init(title: "Farmacias", emoji: "💊", bgColor: Color.yellow.opacity(0.2)),
        .init(title: "Librerías", emoji: "📚", bgColor: Color.pink.opacity(0.15)),
        .init(title: "Floristerías", emoji: "💐", bgColor: Color.purple.opacity(0.15)),
        .init(title: "Mascotas", emoji: "🐕", bgColor: Color.teal.opacity(0.15)),
        .init(title: "Gimnasios", emoji: "🏋️", bgColor: Color.indigo.opacity(0.15))
    ]
}
