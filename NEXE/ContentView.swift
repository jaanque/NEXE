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
                    selectedTab = .explore
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
                ExploreView(selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
            }
            .tag(AppTab.explore)

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
