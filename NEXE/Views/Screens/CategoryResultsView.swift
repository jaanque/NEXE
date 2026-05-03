import SwiftUI
import Foundation
import Supabase

struct CategoryResultsView: View {
    let category: HomeCategory
    
    @State private var stores: [NearbyStoreItem] = []
    @State private var isLoading = true
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Hero Header
                HStack(spacing: 16) {
                    Text(category.emoji)
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.title.bold())
                        Text("Explora los mejores locales")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                if isLoading {
                    VStack(spacing: 20) {
                        ForEach(0..<3) { _ in
                            StoreSkeletonCard()
                        }
                    }
                    .padding(.horizontal, 16)
                } else if stores.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "storefront")
                            .font(.system(size: 50))
                            .foregroundStyle(.tertiary)
                        Text("No hemos encontrado locales en esta categoría")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    LazyVStack(spacing: 24) {
                        ForEach(stores) { store in
                            NearbyStoreCardVerticalView(store: store)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color.brandBackground)
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchStores()
        }
    }
    
    private func fetchStores() {
        Task {
            do {
                let fetched: [NearbyStoreItem] = try await SupabaseManager.shared.client
                    .from("stores")
                    .select()
                    .eq("category_id", value: category.id)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                await MainActor.run {
                    self.stores = fetched.map { store in
                        var updated = store
                        updated.categoryName = category.name
                        return updated
                    }
                    withAnimation {
                        self.isLoading = false
                    }
                }
            } catch {
                print("Error fetching category stores: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
