import Foundation
import CoreLocation

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
    let latitude: Double?
    let longitude: Double?
    
    // Campo opcional para mostrar el nombre de la categoría (se puebla tras la carga)
    var categoryName: String? = nil
    
    // Propiedad para ordenación numérica
    var distanceInMeters: Double {
        guard let userLoc = LocationManager.shared.userLocation,
              let lat = latitude,
              let lon = longitude else {
            return Double.greatestFiniteMagnitude
        }
        let storeLoc = CLLocation(latitude: lat, longitude: lon)
        return userLoc.distance(from: storeLoc)
    }
    
    // El campo distance ahora se calcula dinámicamente si hay ubicación
    var distance: String {
        let meters = distanceInMeters
        if meters == Double.greatestFiniteMagnitude {
            return "---m"
        }
        
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            return String(format: "%.1fkm", meters / 1000)
        }
    }
    
    let openingTime1: String?
    let closingTime1: String?
    let openingTime2: String?
    let closingTime2: String?
    
    var hasOffers: Bool = false
    
    // Lógica para determinar si el local está abierto ahora
    var isOpen: Bool {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        guard let currentHour = components.hour, let currentMinute = components.minute else { return true }
        let currentTimeInMinutes = currentHour * 60 + currentMinute

        func isTimeInRange(start: String?, end: String?) -> Bool {
            guard let start = start, let end = end else { return false }
            // Manejar formato HH:mm:ss o HH:mm
            let startParts = start.split(separator: ":")
            let endParts = end.split(separator: ":")
            guard startParts.count >= 2, endParts.count >= 2 else { return false }
            
            let startMinutes = (Int(startParts[0]) ?? 0) * 60 + (Int(startParts[1]) ?? 0)
            let endMinutes = (Int(endParts[0]) ?? 0) * 60 + (Int(endParts[1]) ?? 0)
            
            return currentTimeInMinutes >= startMinutes && currentTimeInMinutes < endMinutes
        }

        // Si no hay horarios definidos, asumimos que está abierto (o podrías cambiarlo a false)
        if openingTime1 == nil && openingTime2 == nil { return true }

        return isTimeInRange(start: openingTime1, end: closingTime1) || 
               isTimeInRange(start: openingTime2, end: closingTime2)
    }

    // Devuelve la hora de la próxima apertura si está cerrado
    var nextOpeningTime: String? {
        if isOpen { return nil }
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        guard let currentHour = components.hour, let currentMinute = components.minute else { return nil }
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        
        func getMinutes(_ time: String?) -> Int? {
            guard let time = time else { return nil }
            let parts = time.split(separator: ":")
            guard parts.count >= 2 else { return nil }
            return (Int(parts[0]) ?? 0) * 60 + (Int(parts[1]) ?? 0)
        }
        
        let start1 = getMinutes(openingTime1)
        let start2 = getMinutes(openingTime2)
        
        // Si estamos antes del primer turno
        if let s1 = start1, currentTimeInMinutes < s1 {
            return openingTime1?.prefix(5).description
        }
        
        // Si estamos entre el primero y el segundo
        if let s2 = start2, currentTimeInMinutes < s2 {
            return openingTime2?.prefix(5).description
        }
        
        // Si ya cerramos todo hoy, abrimos mañana en el primer turno (o no hay segundo turno)
        return openingTime1?.prefix(5).description
    }
    
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
        case latitude
        case longitude
        case openingTime1 = "opening_time_1"
        case closingTime1 = "closing_time_1"
        case openingTime2 = "opening_time_2"
        case closingTime2 = "closing_time_2"
    }
    
    static let samples: [NearbyStoreItem] = [
        .init(id: UUID(), name: "Philz Coffee", rating: 4.8, reviewsCount: 1250, categoryId: UUID(), imageURL: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&q=80", description: "Café artesanal.", address: "Lleida", isNew: true, givesPoints: true, logoURL: "https://viterboristorante.it/wp-content/uploads/2019/04/philz-coffee-logo.png", latitude: 41.6176, longitude: 0.6200, openingTime1: "09:00", closingTime1: "14:00", openingTime2: "17:00", closingTime2: "21:00"),
        .init(id: UUID(), name: "The Grove", rating: 4.5, reviewsCount: 850, categoryId: UUID(), imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80", description: "Comida rica.", address: "Lleida", isNew: true, givesPoints: false, logoURL: nil, latitude: 41.6180, longitude: 0.6210, openingTime1: "10:00", closingTime1: "22:00", openingTime2: nil, closingTime2: nil)
    ]
}
