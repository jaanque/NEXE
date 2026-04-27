import SwiftUI

struct ConfettiView: View {
    let origin: CGPoint
    let counter: Int
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                ConfettiSystem.shared.update(at: timeline.date, origin: origin, counter: counter)
                
                for particle in ConfettiSystem.shared.particles {
                    context.drawParticle(particle)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// Extensión para dibujar formas de confeti con efectos de luz
extension GraphicsContext {
    mutating func drawParticle(_ particle: Particle) {
        let transform = CGAffineTransform(translationX: particle.x, y: particle.y)
            .rotated(by: particle.rotation)
            .scaledBy(x: cos(particle.wobble), y: 1) // Efecto de giro 3D
        
        var context = self
        context.concatenate(transform)
        
        // Simulación de brillo: cambia la opacidad según el giro
        let opacity = 0.3 + (abs(cos(particle.wobble)) * 0.7)
        let rect = CGRect(x: -particle.size/2, y: -particle.size/2, width: particle.size, height: particle.size)
        
        if particle.isCircle {
            context.fill(Circle().path(in: rect), with: .color(particle.color.opacity(opacity)))
        } else {
            context.fill(Path(rect), with: .color(particle.color.opacity(opacity)))
        }
    }
}

class ConfettiSystem {
    static let shared = ConfettiSystem()
    var particles: [Particle] = []
    private var lastUpdate: Date?
    private var lastCounter = 0
    
    func update(at date: Date, origin: CGPoint, counter: Int) {
        let delta = lastUpdate.map { date.timeIntervalSince($0) } ?? 0
        lastUpdate = date
        
        // Disparar ráfaga si el contador cambia
        if counter != lastCounter {
            lastCounter = counter
            spawnBurst(at: origin)
        }
        
        // Solo procesar si hay partículas activas
        guard !particles.isEmpty else { return }
        
        // Actualizar físicas con un límite de velocidad para mayor suavidad
        let dt = CGFloat(min(delta, 1/30)) 
        
        for i in (0..<particles.count).reversed() {
            particles[i].update(delta: TimeInterval(dt))
            
            // Eliminar si salen por abajo o por los lados con margen
            if particles[i].y > UIScreen.main.bounds.height + 100 || 
               particles[i].x < -100 || 
               particles[i].x > UIScreen.main.bounds.width + 100 {
                particles.remove(at: i)
            }
        }
    }
    
    private func spawnBurst(at origin: CGPoint) {
        for _ in 0..<120 {
            particles.append(Particle(at: origin))
        }
    }
}

struct Particle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var size: CGFloat
    var color: Color
    var isCircle: Bool
    var rotation: CGFloat
    var rotationSpeed: CGFloat
    var wobble: CGFloat
    var wobbleSpeed: CGFloat
    
    init(at origin: CGPoint) {
        self.x = origin.x
        self.y = origin.y
        
        // Explosión inicial potente
        let angle = Double.random(in: -Double.pi * 0.9...(-Double.pi * 0.1))
        let speed = CGFloat.random(in: 400...900)
        self.vx = cos(angle) * speed
        self.vy = sin(angle) * speed
        
        self.size = CGFloat.random(in: 4...10)
        self.color = [.red, .blue, .green, .yellow, .pink, .purple, .orange, .brandGreen, .cyan].randomElement()!
        self.isCircle = Bool.random()
        self.rotation = CGFloat.random(in: 0...Double.pi * 2)
        self.rotationSpeed = CGFloat.random(in: 2...8)
        self.wobble = CGFloat.random(in: 0...Double.pi * 2)
        self.wobbleSpeed = CGFloat.random(in: 4...12)
    }
    
    mutating func update(delta: TimeInterval) {
        let dt = CGFloat(delta)
        
        // Físicas: Gravedad + Fricción del aire (Drag)
        let drag: CGFloat = 0.96
        vx *= drag
        vy = (vy * drag) + 15 // Gravedad constante
        
        x += vx * dt
        y += vy * dt
        
        rotation += rotationSpeed * dt
        wobble += wobbleSpeed * dt
    }
}
