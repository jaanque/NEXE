import SwiftUI

struct NearbyStoresFullView: View {
    let stores: [NearbyStoreItem]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(stores) { store in
                    NavigationLink(destination: StoreDetailView(store: store)) {
                        NearbyStoreCardVerticalView(store: store)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(Color.brandBackground.ignoresSafeArea())
        .navigationTitle("Cerca de ti")
        .navigationBarTitleDisplayMode(.large)
    }
}
