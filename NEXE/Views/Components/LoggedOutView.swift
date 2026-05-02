import SwiftUI

struct LoggedOutView: View {
    let icon: String
    let title: String
    let description: String
    
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var activeAuthMode: AuthMode?
    
    enum AuthMode: String, Identifiable {
        case login
        case signup
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // Cabecera limpia
            VStack(spacing: 24) {
                Image(systemName: icon)
                    .font(.system(size: 70))
                    .foregroundStyle(Color.brandGreen)
                    .padding(.top, 60)
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                }
            }
            
            // Acciones directas
            VStack(spacing: 16) {
                Button {
                    activeAuthMode = .login
                } label: {
                    Text("Iniciar Sesión")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.brandGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button {
                    activeAuthMode = .signup
                } label: {
                    Text("Crear una cuenta")
                        .font(.headline)
                        .foregroundStyle(Color.brandGreen)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .background(Color.brandBackground)
        .sheet(item: $activeAuthMode) { mode in
            NavigationStack {
                if mode == .login {
                    LoginView(viewModel: authViewModel)
                } else {
                    SignUpView(viewModel: authViewModel)
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    LoggedOutView(
        icon: "person.circle",
        title: "Inicia sesión para ver tu perfil",
        description: "Accede a tus puntos, pedidos y favoritos desde cualquier dispositivo."
    )
    .environment(AuthViewModel())
}
