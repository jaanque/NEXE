import SwiftUI
import MapKit

struct StoreInfoView: View {
    @Environment(\.dismiss) private var dismiss
    let store: NearbyStoreItem
    
    // Coordenadas para el mapa
    // Cámara para el mapa
    @State private var position: MapCameraPosition
    
    init(store: NearbyStoreItem) {
        self.store = store
        let center = CLLocationCoordinate2D(
            latitude: store.latitude ?? 41.6176,
            longitude: store.longitude ?? 0.6200
        )
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )))
    }
    
    var body: some View {
        NavigationStack {
            List {
                // ── Cabecera con Logo ──
                Section {
                    HStack(spacing: 16) {
                        if let logoURL = store.logoURL {
                            DemoImage(urlString: logoURL, cornerRadius: 12)
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.name)
                                .font(.title3.bold())
                            if let cat = store.categoryName {
                                Text(cat)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // ── Ubicación (Mapa) ──
                Section("Ubicación") {
                    Map(position: $position) {
                        Marker(store.name, coordinate: CLLocationCoordinate2D(
                            latitude: store.latitude ?? 41.6176,
                            longitude: store.longitude ?? 0.6200
                        ))
                        .tint(Color.brandGranate)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .listRowInsets(EdgeInsets())
                    
                    if let address = store.address {
                        LabeledContent("Dirección", value: address)
                    }
                }
                
                // ── Información Detallada ──
                Section("Detalles") {
                    LabeledContent("Valoración") {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundStyle(.orange)
                            Text(String(format: "%.1f", store.rating))
                            Text("(\(store.reviewsCount))").foregroundStyle(.secondary)
                        }
                    }
                    
                    LabeledContent("Distancia", value: store.distance)
                    
                    LabeledContent("Estado") {
                        Text(store.isOpen ? "Abierto ahora" : "Cerrado")
                            .foregroundStyle(store.isOpen ? .green : .red)
                            .bold()
                    }
                    
                    if store.givesPoints {
                        LabeledContent("Puntos NEXE", value: "Disponible")
                    }
                }
                
                // ── Descripción ──
                if let desc = store.description {
                    Section("Sobre nosotros") {
                        Text(desc)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Información")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Extensión para que NearbyStoreItem funcione con annotationItems del mapa
extension NearbyStoreItem: Equatable {
    public static func == (lhs: NearbyStoreItem, rhs: NearbyStoreItem) -> Bool {
        lhs.id == rhs.id
    }
}
