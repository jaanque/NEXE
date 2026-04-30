import SwiftUI

struct BlobShape: Shape {
    let seed: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)
        
        let points = 8
        var vertices: [CGPoint] = []
        
        for i in 0..<points {
            let angle = Double(i) * (2.0 * .pi / Double(points))
            let randomValue = Double((abs((seed + i * 53).hashValue) % 100)) / 100.0
            let radius = (width / 2) * (0.8 + (randomValue * 0.2)) 
            
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            vertices.append(CGPoint(x: x, y: y))
        }
        
        path.move(to: CGPoint(x: (vertices[points-1].x + vertices[0].x) / 2, 
                             y: (vertices[points-1].y + vertices[0].y) / 2))
        
        for i in 0..<points {
            let current = vertices[i]
            let next = vertices[(i + 1) % points]
            let mid = CGPoint(x: (current.x + next.x) / 2, y: (current.y + next.y) / 2)
            path.addQuadCurve(to: mid, control: current)
        }
        
        path.closeSubpath()
        return path
    }
}
