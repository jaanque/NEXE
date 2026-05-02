import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var exploreFocusToken = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = UIColor.separator
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
                    RewardsView()
                }
                .tabItem {
                    Image(systemName: "gift")
                }
                .tag(AppTab.rewards)

                NavigationStack {
                    ExploreView(focusToken: exploreFocusToken)
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
            .tint(Color.brandGreen)
        }
    }
}

#Preview {
    ContentView()
}
