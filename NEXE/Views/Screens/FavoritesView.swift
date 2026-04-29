import SwiftUI

struct FavoritesView: View {
    @Binding var selectedTab: AppTab
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Cabecera Simple
                HStack {
                    Text("Favoritos")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // EMPTY STATE
                VStack(spacing: 32) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.brandGreen.opacity(0.8))
                    
                    VStack(spacing: 12) {
                        Text("Tu lista está vacía")
                            .font(.system(size: 22, weight: .bold))
                        
                        Text("Guarda los locales y productos que más te gusten para tenerlos siempre a mano.")
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
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    FavoritesView(selectedTab: .constant(.favorites))
}
