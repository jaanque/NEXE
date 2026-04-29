import SwiftUI

struct ReservationsView: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // EMPTY STATE
                VStack(spacing: 32) {
                    Image(systemName: "calendar")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.brandGreen.opacity(0.8))
                    
                    VStack(spacing: 12) {
                        Text("No tienes reservas")
                            .font(.system(size: 22, weight: .bold))
                        
                        Text("Aquí aparecerán tus citas y reservas en restaurantes o servicios de la ciudad.")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 50)
                    }
                    
                    // BOTÓN CTA: Explorar (Estética NEXE)
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedTab = .explore
                        }
                        UISelectionFeedbackGenerator().selectionChanged()
                    } label: {
                        HStack(spacing: 12) {
                            Text("Explorar NEXE")
                                .font(.system(size: 16, weight: .bold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 18)
                        .background(Color.brandGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ReservationsView(selectedTab: .constant(.reservations))
}
