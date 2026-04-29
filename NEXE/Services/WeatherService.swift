import Foundation
import WeatherKit
import CoreLocation
import Combine

@MainActor
class WeatherService: ObservableObject {
    @Published var temperature: Int = 21 
    @Published var condition: String = "Despejado"
    @Published var highTemp: Int = 26
    @Published var lowTemp: Int = 13
    @Published var iconName: String = "sun.max.fill"
    @Published var isLoading: Bool = true
    
    private let lleidaLocation = CLLocation(latitude: 41.6176, longitude: 0.6200)
    
    func fetchWeather() async {
        self.isLoading = true
        
        do {
            // Reconexión con Apple WeatherKit
            let weather = try await WeatherKit.WeatherService.shared.weather(for: lleidaLocation)
            
            self.temperature = Int(weather.currentWeather.temperature.converted(to: .celsius).value)
            self.condition = translateCondition(weather.currentWeather.condition.description)
            self.iconName = weather.currentWeather.symbolName
            
            if let today = weather.dailyForecast.first {
                self.highTemp = Int(today.highTemperature.converted(to: .celsius).value)
                self.lowTemp = Int(today.lowTemperature.converted(to: .celsius).value)
            }
            
            self.isLoading = false
        } catch {
            print("WeatherKit no disponible. Usando Fallback...")
            await fetchFallbackWeather()
        }
    }
    
    private func fetchFallbackWeather() async {
        guard let url = URL(string: "https://wttr.in/Lleida?format=j1") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(wttrData.self, from: data)
            if let current = decoded.current_condition.first, let today = decoded.weather.first {
                self.temperature = Int(current.temp_C) ?? self.temperature
                self.highTemp = Int(today.maxtempC) ?? self.highTemp
                self.lowTemp = Int(today.mintempC) ?? self.lowTemp
                self.condition = translateCondition(current.weatherDesc.first?.value ?? "Despejado")
                self.iconName = mapIcon(current.weatherDesc.first?.value ?? "")
            }
            self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }
    
    private func translateCondition(_ condition: String) -> String {
        let dict = [
            "sunny": "Soleado",
            "clear": "Despejado",
            "mostly clear": "Despejado",
            "mostly sunny": "Soleado",
            "partly cloudy": "Parcialmente nublado",
            "cloudy": "Nublado",
            "overcast": "Cubierto",
            "mist": "Neblina",
            "fog": "Niebla",
            "rain": "Lluvia",
            "light rain": "Lluvia ligera",
            "heavy rain": "Lluvia intensa",
            "thunderstorm": "Tormenta",
            "drizzle": "Llovizna",
            "snow": "Nieve"
        ]
        return dict[condition.lowercased()] ?? condition
    }
    
    private func mapIcon(_ condition: String) -> String {
        let c = condition.lowercased()
        if c.contains("sun") || c.contains("clear") { return "sun.max.fill" }
        if c.contains("cloud") { return "cloud.fill" }
        if c.contains("rain") { return "cloud.rain.fill" }
        return "cloud.sun.fill"
    }
}

// Estructuras de datos para Fallback
struct wttrData: Codable {
    let current_condition: [wttrCurrent]
    let weather: [wttrWeather]
}

struct wttrCurrent: Codable {
    let temp_C: String
    let weatherDesc: [wttrDesc]
}

struct wttrWeather: Codable {
    let maxtempC: String
    let mintempC: String
}

struct wttrDesc: Codable {
    let value: String
}
