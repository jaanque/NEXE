import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedTab: AppTab = .home

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = UIColor.separator
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView {
                }
            }
            .tabItem {
                Image(systemName: "house")
            }
            .tag(AppTab.home)

            NavigationStack {
                RewardsView()
            }
            .tabItem {
                Image(systemName: "gift")
            }
            .tag(AppTab.rewards)

            NavigationStack {
                OrdersView(selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "scroll")
            }
            .tag(AppTab.orders)

            NavigationStack {
                ProfileView(selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
            }
            .badge(FavoritesManager.shared.newCount)
            .tag(AppTab.profile)
        }
        .tint(Color.brandBlue)
    }
}

#Preview {
    ContentView()
}
