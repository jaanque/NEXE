import SwiftUI
import Supabase

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showAuthSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                    // TÍTULO DE SECCIÓN UNIFICADO
                    HStack {
                        Text("Perfil")
                            .font(.system(size: 34, weight: .bold))
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    if let user = authViewModel.currentUser {
                        loggedInHeader(user: user)
                    } else {
                        loggedOutHeader
                    }
                    
                    VStack(spacing: 32) {
                        activitySection
                        clubSection
                        settingsSection
                        
                        if authViewModel.currentUser != nil {
                            logoutButton
                        }
                        
                        versionInfo
                    }
                    .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showAuthSheet) {
                NavigationStack {
                    SignUpView(viewModel: authViewModel)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private func loggedInHeader(user: User) -> some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color.brandGreen.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(user.email?.prefix(1).uppercased() ?? "U")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.brandGreen)
                )
            
            VStack(spacing: 4) {
                Text(user.email ?? "Usuario")
                    .font(.headline)
                Text("Miembro desde 2024")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Tarjeta de Puntos Destacada
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Puntos Disponibles")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("\(authViewModel.userProfile?.points ?? 0) NEXE Puntos")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "star.circle.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.brandGreen)
            )
            .padding(.horizontal, 16)
        }
        .padding(.top, 10)
    }
    
    private var loggedOutHeader: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("Únete al Club Local")
                    .font(.title3.weight(.bold))
                Text("Regístrate para acumular puntos y canjearlos por descuentos en tus tiendas favoritas.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 12) {
                Button {
                    showAuthSheet = true
                } label: {
                    Text("Iniciar Sesión / Crear Cuenta")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.brandGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.top, 20)
    }
    
    private var activitySection: some View {
        ProfileSection(title: "Mi Actividad") {
            ProfileRow(icon: "bag.fill", title: "Mis Reservas", subtitle: "Pedidos pendientes de recogida")
            ProfileRow(icon: "heart.fill", title: "Mis Favoritos", subtitle: "Tiendas que te encantan")
            ProfileRow(icon: "clock.arrow.circlepath", title: "Historial de Puntos", subtitle: "Ver mis movimientos")
        }
    }
    
    private var clubSection: some View {
        ProfileSection(title: "Club NEXE") {
            ProfileRow(icon: "ticket.fill", title: "Mis Cupones", subtitle: "Descuentos listos para usar")
            ProfileRow(icon: "crown.fill", title: "Nivel Bronce", subtitle: "Te faltan 150pt para nivel Plata")
        }
    }
    
    private var settingsSection: some View {
        ProfileSection(title: "Configuración") {
            ProfileRow(icon: "person.fill", title: "Datos Personales", subtitle: "Gestionar mi cuenta")
            ProfileRow(icon: "bell.fill", title: "Notificaciones", subtitle: "Avisos de ofertas y puntos")
            ProfileRow(icon: "questionmark.circle.fill", title: "Ayuda y Soporte", subtitle: "Preguntas frecuentes")
        }
    }
    
    private var logoutButton: some View {
        Button {
            Task { await authViewModel.signOut() }
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Cerrar Sesión")
            }
            .font(.headline)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }
    
    private var versionInfo: some View {
        Text("Versión 1.0.0 (BETA)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }
}

// MARK: - Components

struct ProfileSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        Button {
            // Acción
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.brandGreen)
                    .frame(width: 36, height: 36)
                    .background(Color.brandGreen.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding(12)
        }
        .buttonStyle(.plain)
    }
}
