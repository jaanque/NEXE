import SwiftUI
import Supabase

struct PersonalSettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Perfil Info
                        if let user = authViewModel.currentUser {
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(Color.brandGreen.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(user.email?.prefix(1).uppercased() ?? "U")
                                            .font(.system(size: 34, weight: .bold))
                                            .foregroundStyle(Color.brandGreen)
                                    )
                                
                                VStack(spacing: 4) {
                                    Text(user.email ?? "Usuario NEXE")
                                        .font(.headline)
                                    Text("Miembro desde \(getMemberDate())")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.top, 20)
                        }
                        
                        VStack(spacing: 24) {
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
                                    dismiss()
                                }
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
                            
                            versionInfo
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hecho") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(Color.brandGreen)
                }
            }
        }
    }
    
    private func getMemberDate() -> String {
        // En una app real, esto vendría del perfil de Supabase
        return "2024"
    }
    
    private var versionInfo: some View {
        Text("Versión 1.0.0 (BETA)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }
}
