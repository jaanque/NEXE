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
    
    private init() {}
    
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
                // Eliminar usando match para manejar el product_id nulo de forma limpia
                var params: [String: AnyJSON] = [
                    "user_id": .string(userId.uuidString),
                    "store_id": .string(storeId.uuidString)
                ]
                
                if let pid = productId {
                    params["product_id"] = .string(pid.uuidString)
                } else {
                    params["product_id"] = .null
                }
                
                try await client.from("favorites")
                    .delete()
                    .match(params)
                    .execute()
                
                await MainActor.run {
                    if let pid = productId {
                        favoriteProductIds.remove(pid)
                    } else {
                        favoriteStoreIds.remove(storeId)
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
}
