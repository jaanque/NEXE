import SwiftUI
import CoreImage.CIFilterBuiltins

struct FullScreenQRView: View {
    @Environment(\.dismiss) var dismiss
    let userId: String
    let points: Int
    
    @State private var bgColor: Color = Color.brandBackground
    @State private var patternEmoji: String? = nil
    @State private var showControls = false
    
    let colorPalette: [Color] = [.brandBackground, .white, .brandGreen.opacity(0.1), .blue.opacity(0.1), .purple.opacity(0.1), .orange.opacity(0.1)]
    let emojiStickers = ["✨", "🔥", "💎", "🍕", "🍔", "🛍️", "🎁", "💚", "⚡️", "👑"]
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            // CAPA DE ESTAMPADO
            if let emoji = patternEmoji {
                EmojiPatternView(emoji: emoji)
            }
            
            VStack(spacing: 30) {
                // CABECERA CONTROLES
                HStack {
                    Button {
                        withAnimation(.spring()) {
                            showControls.toggle()
                        }
                    } label: {
                        Image(systemName: "paintpalette.fill")
                            .font(.title3)
                            .foregroundStyle(showControls ? Color.brandGreen : .secondary)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button {
                        saveSettings()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary.opacity(0.5))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 24) {
                    Text("Mi Identificación NEXE")
                        .font(.title2.weight(.bold))
                    
                    if let qrImage = generateQRCode(from: userId) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 260, height: 260)
                            .padding(20)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(color: .black.opacity(0.1), radius: 20)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(points)")
                            .font(.system(size: 54, weight: .black, design: .rounded))
                        Text("pts")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.brandGreen)
                    }
                }
                .scaleEffect(showControls ? 0.95 : 1.0)
                .animation(.spring(), value: showControls)
                
                Spacer()
                
                if showControls {
                    // TOOLBAR DE PERSONALIZACIÓN
                    VStack(spacing: 20) {
                        customizationHeader
                        colorSelector
                        emojiSelector
                    }
                    .padding(.vertical, 20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            loadSettings()
        }
    }
    
    private var customizationHeader: some View {
        HStack {
            Text("Personalizar")
                .font(.headline)
            Spacer()
            Button("Limpiar") {
                patternEmoji = nil
                bgColor = .brandBackground
                saveSettings()
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(.red)
        }
        .padding(.horizontal, 24)
    }
    
    private var colorSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(colorPalette, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 34, height: 34)
                        .overlay(
                            Circle().stroke(Color.primary.opacity(bgColor == color ? 0.5 : 0.1), lineWidth: 2)
                        )
                        .onTapGesture {
                            withAnimation { bgColor = color }
                            saveSettings()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var emojiSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(emojiStickers, id: \.self) { emoji in
                    EmojiItemView(emoji: emoji, isSelected: patternEmoji == emoji) {
                        withAnimation {
                            patternEmoji = (patternEmoji == emoji) ? nil : emoji
                        }
                        saveSettings()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    
    private func saveSettings() {
        let hex = bgColor.toHex() ?? ""
        let settings = QRSettings(bgColorHex: hex, patternEmoji: patternEmoji)
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "nexe_qr_settings")
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "nexe_qr_settings"),
           let settings = try? JSONDecoder().decode(QRSettings.self, from: data) {
            self.bgColor = Color(hex: settings.bgColorHex) ?? .brandBackground
            self.patternEmoji = settings.patternEmoji
        }
    }
}

struct EmojiItemView: View {
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Text(emoji)
            .font(.title)
            .padding(8)
            .background(isSelected ? Color.brandGreen.opacity(0.2) : Color.primary.opacity(0.05))
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .onTapGesture(perform: action)
    }
}

struct EmojiPatternView: View {
    let emoji: String
    
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 60
            let columns = Int(size.width / spacing) + 1
            let rows = Int(size.height / spacing) + 1
            
            for row in 0..<rows {
                for col in 0..<columns {
                    var innerContext = context
                    let x = CGFloat(col) * spacing + (row % 2 == 0 ? 0 : spacing/2)
                    let y = CGFloat(row) * spacing
                    
                    innerContext.opacity = 0.22
                    innerContext.translateBy(x: x, y: y)
                    innerContext.rotate(by: .degrees(Double((row + col) % 4) * 20))
                    
                    innerContext.draw(Text(emoji).font(.system(size: 28)), at: .zero)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct QRSettings: Codable {
    var bgColorHex: String
    var patternEmoji: String?
}
