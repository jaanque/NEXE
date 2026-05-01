import SwiftUI

struct LoggedOutView: View {
    let icon: String
    let title: String
    let description: String
    
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showAuth = false
    @State private var authMode: AuthMode = .login
    
    enum AuthMode {
        case login
        case signup
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icono ilustrativo con gradiente
            ZStack {
                Circle()
                    .fill(Color.brandGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundStyle(Color.brandGreen)
            }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 16) {
                // Botón Principal: Iniciar Sesión
                Button {
                    authMode = .login
                    showAuth = true
                } label: {
                    Text("Iniciar Sesión")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.brandGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
                // Botón Secundario: Crear Cuenta
                Button {
                    authMode = .signup
                    showAuth = true
                } label: {
                    Text("Crear una cuenta")
                        .font(.headline)
                        .foregroundStyle(Color.brandGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.brandGreen.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.bottom, 40)
        .sheet(isPresented: $showAuth) {
            NavigationStack {
                if authMode == .login {
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
    ZStack {
        Color.brandBackground.ignoresSafeArea()
        LoggedOutView(
            icon: "person.circle",
            title: "Inicia sesión para ver tu perfil",
            description: "Accede a tus puntos, pedidos y favoritos desde cualquier dispositivo."
        )
        .environment(AuthViewModel())
    }
}
