import SwiftUI
import Combine

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isSpawning = true
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle)
                }
            }
            .onAppear {
                setupParticles(in: geometry.size)
                // Detener spawn tras un tiempo
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    isSpawning = false
                }
            }
            .onReceive(timer) { _ in
                updateParticles(in: geometry.size)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    private func setupParticles(in size: CGSize) {
        for _ in 0..<110 {
            particles.append(ConfettiParticle(size: size))
        }
    }
    
    private func updateParticles(in size: CGSize) {
        let time = Date().timeIntervalSince1970
        for i in 0..<particles.count {
            // Gravedad reducida para efecto "floaty"
            particles[i].speed += 0.04
            particles[i].y += particles[i].speed
            
            // Sway más pronunciado y lento
            let sway = sin(time * particles[i].swayFrequency + particles[i].swayOffset) * 1.2
            particles[i].x += sway + particles[i].vx
            
            // Rotación 3D más lenta y elegante
            particles[i].rotation += particles[i].rotationSpeed * 0.8
            
            // Solo resetear si seguimos spawneando
            if particles[i].y > size.height + 20 && isSpawning {
                particles[i].reset(in: size)
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat = 0
    var y: CGFloat = 0
    var vx: CGFloat = 0
    var speed: CGFloat = 0
    var color: Color = .brandGreen
    var particleSize: CGFloat = 0
    var rotation: Double = 0
    var rotationSpeed: Double = 0
    var swayOffset: Double = 0
    var swayFrequency: Double = 0
    var shapeType: Int = 0
    
    init(size: CGSize) {
        reset(in: size, initial: true)
    }
    
    mutating func reset(in size: CGSize, initial: Bool = false) {
        self.x = CGFloat.random(in: 0...size.width)
        self.y = initial ? CGFloat.random(in: -size.height...0) : -40
        self.vx = CGFloat.random(in: -0.8...0.8) // Drift suave
        self.speed = CGFloat.random(in: 1.5...3.5) // Velocidad inicial reducida
        self.color = [
            Color.brandGreen, 
            Color.brandGreen.opacity(0.8),
            .yellow, .blue, .red, .orange, .purple, .pink, .cyan, .white
        ].randomElement()!
        self.particleSize = CGFloat.random(in: 7...13)
        self.rotation = Double.random(in: 0...360)
        self.rotationSpeed = Double.random(in: 3...10)
        self.swayOffset = Double.random(in: 0...Double.pi * 2)
        self.swayFrequency = Double.random(in: 1.0...3.0)
        self.shapeType = Int.random(in: 0...3)
    }
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    
    var body: some View {
        Group {
            if particle.shapeType == 0 {
                Rectangle()
            } else if particle.shapeType == 1 {
                Circle()
            } else if particle.shapeType == 2 {
                Capsule()
            } else {
                Image(systemName: "triangle.fill")
                    .resizable()
            }
        }
        .frame(width: particle.particleSize, height: particle.particleSize * (particle.shapeType == 2 ? 1.8 : 1))
        .foregroundStyle(particle.color)
        .rotation3DEffect(.degrees(particle.rotation), axis: (x: 1, y: 1, z: 0))
        .rotationEffect(.degrees(particle.rotation / 2))
        .position(x: particle.x, y: particle.y)
    }
}
