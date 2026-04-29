//
//  ContentView.swift
//  NEXE
//
//  Created by Jan Queralt Posino on 24/04/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var exploreFocusToken = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Color.brandBackground)
        appearance.backgroundEffect = nil // Eliminar blur para color sólido
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView {
                        selectedTab = .explore
                        exploreFocusToken += 1
                    }
                }
                .tabItem {
                    Label("Inicio", systemImage: "house")
                }
                .tag(AppTab.home)

                NavigationStack {
                    ExploreView(focusToken: exploreFocusToken)
                }
                .tabItem {
                    Label("Explorar", systemImage: "magnifyingglass")
                }
                .tag(AppTab.explore)

                NavigationStack {
                    FavoritesView(selectedTab: $selectedTab)
                }
                .tabItem {
                    Label("Favoritos", systemImage: "heart")
                }
                .tag(AppTab.favorites)

                NavigationStack {
                    ReservationsView(selectedTab: $selectedTab)
                }
                .tabItem {
                    Label("Reservas", systemImage: "calendar")
                }
                .tag(AppTab.reservations)

                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle")
                }
                .tag(AppTab.profile)
            }
            .tint(Color.brandGreen)
        }
    }
}

#Preview {
    ContentView()
}
