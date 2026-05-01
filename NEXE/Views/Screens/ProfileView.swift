import SwiftUI
import Supabase
import CoreImage.CIFilterBuiltins

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Binding var selectedTab: AppTab
    @State private var showFullQR = false
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                if isLoading {
                    ProfileSkeletonView()
                } else {
                    if let user = authViewModel.currentUser {
                        ScrollView {
                            VStack(spacing: 24) {
                                // Cabecera Simple
                                VStack(spacing: 16) {
                                    Circle()
                                        .fill(Color.brandGreen.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Text(user.email?.prefix(1).uppercased() ?? "U")
                                                .font(.title.bold())
                                                .foregroundStyle(Color.brandGreen)
                                        )
                                    
                                    VStack(spacing: 4) {
                                        Text(user.email?.components(separatedBy: "@").first?.capitalized ?? "Usuario")
                                            .font(.headline)
                                        Text("Miembro NEXE")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.top, 20)
                                
                                // Banner de Puntos Simple
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Puntos acumulados")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.8))
                                        Text("\(authViewModel.userProfile?.points ?? 0) PT")
                                            .font(.title2.bold())
                                            .foregroundStyle(.white)
                                    }
                                    Spacer()
                                    Image(systemName: "qrcode")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                }
                                .padding(20)
                                .background(Color.brandGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .onTapGesture { showFullQR = true }
                                
                                // Secciones Simples
                                VStack(spacing: 1) {
                                    ProfileRow(icon: "scroll", title: "Mis Pedidos")
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                selectedTab = .orders
                                            }
                                            UISelectionFeedbackGenerator().selectionChanged()
                                        }
                                    Divider().padding(.leading, 56)
                                    NavigationLink(destination: FavoritesView(selectedTab: $selectedTab)) {
                                        ProfileRow(icon: "heart", title: "Favoritos")
                                    }
                                    .buttonStyle(.plain)
                                    Divider().padding(.leading, 56)
                                    ProfileRow(icon: "star", title: "Historial de Puntos")
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                VStack(spacing: 1) {
                                    ProfileRow(icon: "person", title: "Datos de la cuenta")
                                    Divider().padding(.leading, 56)
                                    ProfileRow(icon: "bell", title: "Notificaciones")
                                    Divider().padding(.leading, 56)
                                    ProfileRow(icon: "lock", title: "Privacidad y Seguridad")
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                // Botón Salir
                                Button {
                                    Task { await authViewModel.signOut() }
                                } label: {
                                    Text("Cerrar Sesión")
                                        .font(.headline)
                                        .foregroundStyle(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                Text("Versión 1.0.0")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 20)
                            }
                            .padding(20)
                        }
                    } else {
                        LoggedOutView(
                            icon: "person.circle",
                            title: "Inicia sesión para ver tu perfil",
                            description: "Accede a tus puntos, pedidos y favoritos desde cualquier dispositivo."
                        )
                    }
                }
            }
            .navigationBarTitle("Perfil", displayMode: .inline)
            .task {
                // Pequeño delay para que el skeleton sea visible y la transición sea suave
                try? await Task.sleep(nanoseconds: 600_000_000)
                withAnimation(.easeInOut(duration: 0.4)) {
                    isLoading = false
                }
            }
            .fullScreenCover(isPresented: $showFullQR) {
                if let user = authViewModel.currentUser {
                    FullScreenQRView(userId: user.id.uuidString, points: authViewModel.userProfile?.points ?? 0)
                }
            }
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(Color.brandGreen)
            Text(title)
                .font(.body)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .contentShape(Rectangle())
    }
}
