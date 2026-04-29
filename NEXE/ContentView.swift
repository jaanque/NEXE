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
                    Image(systemName: "house")
                }
                .tag(AppTab.home)

                NavigationStack {
                    ExploreView(focusToken: exploreFocusToken)
                }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                .tag(AppTab.explore)

                NavigationStack {
                    FavoritesView(selectedTab: $selectedTab)
                }
                .tabItem {
                    Image(systemName: "heart")
                }
                .badge(FavoritesManager.shared.newCount)
                .tag(AppTab.favorites)

                NavigationStack {
                    ReservationsView(selectedTab: $selectedTab)
                }
                .tabItem {
                    Image(systemName: "calendar")
                }
                .tag(AppTab.reservations)

                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Image(systemName: "person.crop.circle")
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
