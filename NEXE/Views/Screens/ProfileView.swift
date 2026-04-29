import SwiftUI
import Supabase
import CoreImage.CIFilterBuiltins

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showAuthSheet = false
    @State private var showFullQR = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // ESPACIADO INICIAL (Sustituye al título eliminado)
                        Spacer()
                            .frame(height: 10)
                        
                        if let user = authViewModel.currentUser {
                            VStack(spacing: 16) {
                                Circle()
                                    .fill(Color.brandGreen.opacity(0.1))
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Text(user.email?.prefix(1).uppercased() ?? "U")
                                            .font(.system(size: 38, weight: .bold))
                                            .foregroundStyle(Color.brandGreen)
                                    )
                                
                                VStack(spacing: 4) {
                                    Text(user.email ?? "Usuario NEXE")
                                        .font(.title3.weight(.bold))
                                    Text("Miembro desde \(getMemberDate())")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            pointsBanner(user: user)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    showFullQR = true
                                }
                            
                            VStack(spacing: 32) {
                                activitySection
                                clubSection
                                
                                ProfileSection(title: "Mi Cuenta") {
                                    ProfileRow(icon: "person.fill", title: "Editar Perfil", subtitle: "Nombre, teléfono y dirección")
                                    ProfileRow(icon: "envelope.fill", title: "Email", subtitle: authViewModel.currentUser?.email ?? "")
                                    ProfileRow(icon: "lock.fill", title: "Seguridad", subtitle: "Contraseña y acceso")
                                }
                                
                                ProfileSection(title: "Preferencias") {
                                    ProfileRow(icon: "bell.fill", title: "Notificaciones", subtitle: "Avisos de ofertas y puntos")
                                    ProfileRow(icon: "creditcard.fill", title: "Pagos", subtitle: "Métodos de pago guardados")
                                }
                                
                                ProfileSection(title: "Legal") {
                                    ProfileRow(icon: "doc.text.fill", title: "Términos y Condiciones", subtitle: "Uso de la plataforma")
                                    ProfileRow(icon: "shield.fill", title: "Privacidad", subtitle: "Gestión de tus datos")
                                }
                                
                                Button {
                                    Task {
                                        await authViewModel.signOut()
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Cerrar Sesión")
                                    }
                                    .font(.headline)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.red.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        } else {
                            loggedOutHeader
                        }
                        
                        versionInfo
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAuthSheet) {
                NavigationStack {
                    SignUpView(viewModel: authViewModel)
                }
            }
            .fullScreenCover(isPresented: $showFullQR) {
                if let user = authViewModel.currentUser {
                    FullScreenQRView(userId: user.id.uuidString, points: authViewModel.userProfile?.points ?? 0)
                }
            }
        }
    }
    
    // MARK: - Components
    
    private func getMemberDate() -> String {
        if let createdAt = authViewModel.currentUser?.createdAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: createdAt)
        }
        return "2024"
    }
    
    private func pointsBanner(user: User) -> some View {
        HStack(spacing: 20) {
            // QR Compacto
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                
                if let qrImage = generateQRCode(from: user.id.uuidString) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 42, height: 42)
                        .padding(4)
                }
            }
            .frame(width: 50, height: 50)
            
            // Puntos
            VStack(alignment: .leading, spacing: 0) {
                Text("\(authViewModel.userProfile?.points ?? 0)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                Text("Puntos acumulados")
                    .font(.system(size: 11, weight: .medium))
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
            
            Spacer()
            
            // Nivel y Acción
            HStack(spacing: 4) {
                Text("BRONCE")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .opacity(0.5)
            }
            .foregroundStyle(.white)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(colors: [Color.brandGreen, Color.brandGreen.opacity(0.9)], 
                           startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.brandGreen.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    private var loggedOutHeader: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Únete al Club Local")
                    .font(.title3.weight(.bold))
                Text("Regístrate para acumular puntos y canjearlos por descuentos en tus tiendas favoritas.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
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
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
 
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
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
    
    private var versionInfo: some View {
        HStack {
            Spacer()
            Text("Versión 1.0.0 (BETA)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
        }
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
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
            )
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



