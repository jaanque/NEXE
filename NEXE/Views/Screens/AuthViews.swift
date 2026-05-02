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
    @State private var currentStep: SignUpStep = .welcome
    
    enum SignUpStep: Int, CaseIterable {
        case welcome = 0
        case email = 1
        case password = 2
        
        var progress: Double {
            Double(self.rawValue + 1) / Double(SignUpStep.allCases.count)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressView(value: currentStep.progress)
                .tint(Color.brandGreen)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .animation(.spring(), value: currentStep)
            
            ZStack {
                switch currentStep {
                case .welcome:
                    welcomeStep
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .email:
                    emailStep
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .password:
                    passwordStep
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .animation(.easeInOut, value: currentStep)
        }
        .background(Color.brandBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if currentStep != .welcome {
                    Button {
                        withAnimation {
                            if let prev = SignUpStep(rawValue: currentStep.rawValue - 1) {
                                currentStep = prev
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.brandGreen)
                    }
                }
            }
        }
    }
    
    // MARK: - Steps
    
    private var welcomeStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Graphic (Welcome)
            let welcomeImagePath = "/Users/jan/.gemini/antigravity/brain/2b43e496-3153-4b08-aa53-a2a48d4269f6/signup_welcome_graphic_1777663048990.png"
            if let uiImage = UIImage(contentsOfFile: welcomeImagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 280)
            } else {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(Color.brandGreen.opacity(0.8))
                    .symbolEffect(.bounce, value: currentStep)
            }
            
            VStack(spacing: 16) {
                Text("Únete a NEXE")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Crea tu cuenta en segundos y empieza a ganar puntos por cada compra en los comercios locales.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            primaryButton(title: "Empezar") {
                withAnimation { currentStep = .email }
            }
            .padding(.bottom, 20)
        }
        .padding(24)
    }
    
    private var emailStep: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text("¿Cuál es tu email?")
                    .font(.title.bold())
                
                Text("Utilizaremos este email para gestionar tus pedidos y puntos.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
            
            CustomTextField(title: "Email", text: $viewModel.email, placeholder: "ejemplo@correo.com", icon: "envelope")
            
            Spacer()
            
            primaryButton(title: "Continuar") {
                if !viewModel.email.isEmpty && viewModel.email.contains("@") {
                    withAnimation { currentStep = .password }
                }
            }
            .disabled(viewModel.email.isEmpty)
            .padding(.bottom, 20)
        }
        .padding(24)
    }
    
    private var passwordStep: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Crea una contraseña")
                    .font(.title.bold())
                
                Text("Asegúrate de que sea segura y fácil de recordar.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
            
            // Graphic (Security)
            let securityImagePath = "/Users/jan/.gemini/antigravity/brain/2b43e496-3153-4b08-aa53-a2a48d4269f6/signup_security_graphic_1777663067892.png"
            if let uiImage = UIImage(contentsOfFile: securityImagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            
            CustomSecureField(title: "Contraseña", text: $viewModel.password, placeholder: "Mínimo 6 caracteres", icon: "lock")
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            primaryButton(title: viewModel.isLoading ? "Cargando..." : "Crear cuenta") {
                Task {
                    await viewModel.signUp()
                    if viewModel.currentUser != nil {
                        dismiss()
                    }
                }
            }
            .disabled(viewModel.password.count < 6 || viewModel.isLoading)
            .padding(.bottom, 20)
        }
        .padding(24)
    }
    
    // MARK: - Components
    
    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline)
                if !viewModel.isLoading {
                    Image(systemName: "arrow.right")
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.brandGreen)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.brandGreen.opacity(0.3), radius: 10, y: 5)
        }
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
