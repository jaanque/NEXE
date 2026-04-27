import SwiftUI

struct WeatherWidgetView: View {
    @StateObject private var weatherService = WeatherService()
    
    var body: some View {
        ZStack {
            // MOTOR ATMOSFÉRICO 5.1 (Optimizado para modo Slim)
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    let condition = weatherService.condition.lowercased()
                    
                    if isNight { drawEnhancedStars(context: context, size: size, time: now) }
                    
                    if condition.contains("tormenta") || condition.contains("relámpagos") {
                        drawRealisticLightning(context: context, size: size, time: now)
                    }
                    
                    if condition.contains("lluvia") || condition.contains("tormenta") {
                        drawKineticRain(context: context, size: size, time: now)
                    }
                    
                    if !isNight && (condition.contains("despejado") || condition.contains("soleado")) {
                        drawEnhancedSun(context: context, size: size, time: now)
                    }
                }
            }
            .background(backgroundGradient)
            
            Rectangle().fill(.ultraThinMaterial.opacity(0.3))
            
            // UI Compacta (90px de alto)
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Lleida").font(.system(size: 16, weight: .bold))
                    Text("\(weatherService.temperature)°").font(.system(size: 38, weight: .thin, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Image(systemName: weatherService.iconName)
                        .font(.title3)
                        .symbolRenderingMode(.multicolor)
                    
                    Text(weatherService.condition)
                        .font(.system(size: 12, weight: .bold))
                        .textCase(.uppercase)
                    
                    Text("H: \(weatherService.highTemp)° L: \(weatherService.lowTemp)°")
                        .font(.system(size: 10, weight: .bold))
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, 24)
            .foregroundStyle(.white)
        }
        .frame(height: 90) // ULTRA SLIM
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        }
        .task { await weatherService.fetchWeather() }
    }
    
    // MARK: - Funciones de Renderizado (Simplificadas para el espacio pequeño)
    
    private func drawRealisticLightning(context: GraphicsContext, size: CGSize, time: Double) {
        let seed = floor(time * 1.5)
        if sin(seed * 999.9) > 0.85 {
            let progress = (time * 1.5).truncatingRemainder(dividingBy: 1.0)
            if progress < 0.2 {
                let opacity = (0.2 - progress) * 5.0
                var path = Path()
                let startX = size.width * (0.3 + (sin(seed) * 0.4 + 0.4))
                var currentPoint = CGPoint(x: startX, y: 0)
                path.move(to: currentPoint)
                for i in 1...4 {
                    let nextPoint = CGPoint(x: currentPoint.x + CGFloat(sin(seed * Double(i) * 10) * 20), y: CGFloat(i) * (size.height / 4))
                    path.addLine(to: nextPoint)
                    currentPoint = nextPoint
                }
                context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: 1.5)
            }
        }
    }
    
    private func drawKineticRain(context: GraphicsContext, size: CGSize, time: Double) {
        for i in 0..<30 {
            let hash = Double(i) * 999.9
            let xStart = (sin(hash) * 0.5 + 0.5) * (size.width + 50)
            let speed = 500.0 + (cos(hash) * 150.0)
            let y = (time * speed + hash).truncatingRemainder(dividingBy: size.height + 20) - 10
            context.stroke(Path { p in p.move(to: CGPoint(x: xStart, y: y)); p.addLine(to: CGPoint(x: xStart - 3, y: y + 15)) }, with: .color(.white.opacity(0.5)), lineWidth: 1)
        }
    }

    private func drawEnhancedStars(context: GraphicsContext, size: CGSize, time: Double) {
        for i in 0..<20 {
            let hash = Double(i) * 123.456
            let x = (sin(hash) * 0.5 + 0.5) * size.width
            let y = (cos(hash * 0.8) * 0.5 + 0.5) * size.height
            let opacity = (sin(time * 0.6 + hash) * 0.5 + 0.5) * 0.6
            context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.2, height: 1.2)), with: .color(.white.opacity(opacity)))
        }
    }
    
    private func drawEnhancedSun(context: GraphicsContext, size: CGSize, time: Double) {
        let sunCenter = CGPoint(x: size.width * 0.85, y: size.height * 0.3)
        context.fill(Path(ellipseIn: CGRect(x: sunCenter.x - 80, y: sunCenter.y - 80, width: 160, height: 160)), with: .radialGradient(Gradient(colors: [.yellow.opacity(0.15), .clear]), center: sunCenter, startRadius: 0, endRadius: 100))
    }
    
    private var isNight: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 21 || hour < 7
    }
    private var isSunset: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 18 && hour < 21
    }
    
    private var backgroundGradient: some View {
        let condition = weatherService.condition.lowercased()
        let colors: [Color]
        if isNight { colors = [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.02, green: 0.02, blue: 0.08)] }
        else if isSunset { colors = [Color(red: 0.95, green: 0.5, blue: 0.35), Color(red: 0.6, green: 0.3, blue: 0.5)] }
        else if condition.contains("lluvia") || condition.contains("tormenta") { colors = [Color(red: 0.35, green: 0.4, blue: 0.5), Color(red: 0.15, green: 0.2, blue: 0.3)] }
        else { colors = [Color(red: 0.25, green: 0.6, blue: 0.95), Color(red: 0.15, green: 0.4, blue: 0.9)] }
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
    }
}
