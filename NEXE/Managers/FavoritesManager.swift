import Foundation
import Supabase
import Observation
import SwiftUI
import PostgREST
import Auth

@Observable
class FavoritesManager {
    static let shared = FavoritesManager()
    private let client = SupabaseManager.shared.client
    
    var favoriteProductIds: Set<UUID> = []
    var favoriteStoreIds: Set<UUID> = []
    var newCount = 0
    
    private init() {}
    
    func resetNewCount() {
        newCount = 0
    }
    
    func isProductFavorite(_ productId: UUID) -> Bool {
        favoriteProductIds.contains(productId)
    }
    
    func isStoreFavorite(_ storeId: UUID) -> Bool {
        favoriteStoreIds.contains(storeId)
    }
    
    func toggleFavorite(userId: UUID, storeId: UUID, productId: UUID? = nil) async {
        let isFavorite = productId != nil ? favoriteProductIds.contains(productId!) : favoriteStoreIds.contains(storeId)
        
        do {
            if isFavorite {
                var query = client.from("favorites")
                    .delete()
                    .eq("user_id", value: userId)
                    .eq("store_id", value: storeId)
                
                if let pid = productId {
                    query = query.eq("product_id", value: pid)
                } else {
                    query = query.is("product_id", value: nil)
                }
                
                try await query.execute()
                
                await MainActor.run {
                    if let pid = productId {
                        favoriteProductIds.remove(pid)
                    } else {
                        favoriteStoreIds.remove(storeId)
                    }
                    if newCount > 0 {
                        newCount -= 1
                    }
                }
            } else {
                // Insertar
                var favorite: [String: AnyJSON] = [
                    "user_id": .string(userId.uuidString),
                    "store_id": .string(storeId.uuidString)
                ]
                
                if let pid = productId {
                    favorite["product_id"] = .string(pid.uuidString)
                }
                
                try await client.from("favorites").insert(favorite).execute()
                
                await MainActor.run {
                    if let pid = productId {
                        favoriteProductIds.insert(pid)
                    } else {
                        favoriteStoreIds.insert(storeId)
                    }
                    newCount += 1
                }
            }
        } catch {
            print("DEBUG: Error toggling favorite: \(error)")
        }
    }
    
    func fetchFavorites(userId: UUID) async {
        do {
            let favorites: [FavoriteRow] = try await client.from("favorites")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            await MainActor.run {
                self.favoriteProductIds = Set(favorites.compactMap { $0.product_id })
                self.favoriteStoreIds = Set(favorites.filter { $0.product_id == nil }.map { $0.store_id })
            }
        } catch {
            print("DEBUG: Error fetching favorites: \(error)")
        }
    }
}

struct FavoriteRow: Codable {
    let store_id: UUID
    let product_id: UUID?
    let created_at: Date
}

struct FavoriteItem: Codable, Identifiable {
    let id: UUID
    let created_at: Date
    let store_id: UUID
    let product: ProductItem?
    let store: NearbyStoreItem?
    
    enum CodingKeys: String, CodingKey {
        case id, created_at, store_id, product = "products", store = "stores"
    }
}

extension FavoritesManager {
    func fetchDetailedFavorites(userId: UUID) async -> [FavoriteItem] {
        do {
            // Join con productos y tiendas
            let favorites: [FavoriteItem] = try await client.from("favorites")
                .select("id, created_at, store_id, products(*), stores(*)")
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return favorites
        } catch {
            print("DEBUG: Error fetching detailed favorites: \(error)")
            return []
        }
    }
}
