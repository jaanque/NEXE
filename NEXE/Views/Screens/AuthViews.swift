import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Bienvenido de nuevo")
                    .font(.title.weight(.bold))
                Text("Introduce tus datos para acceder a tu cuenta.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                CustomTextField(title: "Email", text: $viewModel.email, placeholder: "ejemplo@correo.com", icon: "envelope")
                CustomSecureField(title: "Contraseña", text: $viewModel.password, placeholder: "********", icon: "lock")
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task {
                    await viewModel.signIn()
                    if viewModel.currentUser != nil {
                        dismiss()
                    }
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Entrar")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.brandGreen)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.top, 10)
            
            HStack(spacing: 4) {
                Text("¿No tienes cuenta?")
                    .foregroundStyle(.secondary)
                NavigationLink {
                    SignUpView(viewModel: viewModel)
                } label: {
                    Text("Regístrate")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brandGreen)
                }
            }
            .font(.subheadline)
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(24)
        .background(Color.brandBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SignUpView: View {
    @Bindable var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Crea tu cuenta")
                    .font(.title.weight(.bold))
                Text("Únete a NEXE para empezar a acumular puntos.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                CustomTextField(title: "Email", text: $viewModel.email, placeholder: "ejemplo@correo.com", icon: "envelope")
                CustomSecureField(title: "Contraseña", text: $viewModel.password, placeholder: "Mínimo 6 caracteres", icon: "lock")
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(viewModel.currentUser != nil ? .green : .red)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task {
                    await viewModel.signUp()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Registrarse")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.brandGreen)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.top, 10)
            
            HStack(spacing: 4) {
                Text("¿Ya tienes cuenta?")
                    .foregroundStyle(.secondary)
                NavigationLink {
                    LoginView(viewModel: viewModel)
                } label: {
                    Text("Inicia sesión")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brandGreen)
                }
            }
            .font(.subheadline)
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(24)
        .background(Color.brandBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Custom components for cleaner UI
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                SecureField(placeholder, text: $text)
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
