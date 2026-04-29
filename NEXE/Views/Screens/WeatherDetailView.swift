import SwiftUI

struct WeatherDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let condition: String
    let temp: Int
    let icon: String
    
    // Datos simulados de locales recomendados según el tiempo
    let recommendedStores: [NearbyStoreItem] = NearbyStoreItem.samples
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // CABECERA ESTILO APP STORE
                        headerSection
                        
                        // SECCIÓN DE LOCALES RECOMENDADOS
                        VStack(alignment: .leading, spacing: 20) {
                            Text(recommendationTitle)
                                .font(.title2.weight(.bold))
                                .padding(.horizontal, 24)
                            
                            LazyVStack(spacing: 24) {
                                ForEach(recommendedStores) { store in
                                    AppStoreStoreRow(store: store)
                                        .padding(.horizontal, 24)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(colors: [Color.brandGreen, Color.brandGreen.opacity(0.7)], 
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(height: 220)
                
                VStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 80))
                        .symbolRenderingMode(.multicolor)
                    
                    VStack(spacing: 4) {
                        Text("\(temp)°")
                            .font(.system(size: 60, weight: .thin, design: .rounded))
                        Text(condition.uppercased())
                            .font(.headline.weight(.black))
                            .kerning(2)
                    }
                }
                .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
        }
    }
    
    private var recommendationTitle: String {
        let cond = condition.lowercased()
        if cond.contains("lluvia") || cond.contains("tormenta") {
            return "Planes para un día de lluvia"
        } else if cond.contains("soleado") || cond.contains("despejado") {
            return "Disfruta del sol en estos locales"
        } else {
            return "Locales recomendados para hoy"
        }
    }
}

struct AppStoreStoreRow: View {
    let store: NearbyStoreItem
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: store.imageURL ?? "")) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.1)
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(store.name)
                    .font(.headline)
                Text(store.description ?? "Local verificado")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                // Acción
            } label: {
                Text("VER")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.brandGreen)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.brandGreen.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    WeatherDetailView(condition: "Soleado", temp: 24, icon: "sun.max.fill")
}
