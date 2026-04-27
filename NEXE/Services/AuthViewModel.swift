import Foundation
import Supabase
import Observation

@Observable
class AuthViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?
    var currentUser: User?
    var userProfile: Profile?
    
    private let client = SupabaseManager.shared.client
    
    init() {
        Task {
            await checkSession()
        }
    }
    
    @MainActor
    func checkSession() async {
        do {
            let session = try await client.auth.session
            self.currentUser = session.user
            await fetchProfile(userId: session.user.id)
        } catch {
            self.currentUser = nil
            self.userProfile = nil
        }
    }
    
    @MainActor
    func fetchProfile(userId: UUID) async {
        do {
            let profile: Profile = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            self.userProfile = profile
        } catch {
            print("Profile not found, will create on demand or on next update.")
            self.userProfile = nil
        }
    }
    
    @MainActor
    func addPoints(_ amount: Int) async {
        guard let user = currentUser else { return }
        
        isLoading = true
        let currentPoints = userProfile?.points ?? 0
        let newPoints = currentPoints + amount
        
        do {
            struct ProfileUpdate: Encodable {
                let id: UUID
                let points: Int
            }
            
            let update = ProfileUpdate(id: user.id, points: newPoints)
            
            try await client
                .from("profiles")
                .upsert(update)
                .execute()
            
            if userProfile == nil {
                userProfile = Profile(id: user.id, points: newPoints)
            } else {
                userProfile?.points = newPoints
            }
        } catch {
            errorMessage = "Error al actualizar puntos: \(error.localizedDescription)"
            print("DEBUG: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func signIn() async {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Por favor, rellena todos los campos."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await client.auth.signIn(email: email, password: password)
            await checkSession()
        } catch {
            errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func signUp() async {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Por favor, rellena todos los campos."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await client.auth.signUp(email: email, password: password)
            errorMessage = "¡Registro éxito! Por favor, verifica tu email si es necesario."
            await checkSession()
        } catch {
            errorMessage = "Error al registrarse: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func signOut() async {
        do {
            try await client.auth.signOut()
            self.currentUser = nil
            self.userProfile = nil
        } catch {
            print("Error signing out: \(error)")
        }
    }
}
