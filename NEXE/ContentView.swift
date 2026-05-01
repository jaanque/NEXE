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
                    Label("Inicio", systemImage: "house")
                }
                .tag(AppTab.home)

                NavigationStack {
                    RewardsView()
                }
                .tabItem {
                    Label("Recompensas", systemImage: "gift")
                }
                .tag(AppTab.rewards)

                NavigationStack {
                    ExploreView(focusToken: exploreFocusToken)
                }
                .tabItem {
                    Label("Explorar", systemImage: "magnifyingglass")
                }
                .tag(AppTab.explore)

                NavigationStack {
                    OrdersView(selectedTab: $selectedTab)
                }
                .tabItem {
                    Label("Pedidos", systemImage: "scroll")
                }
                .tag(AppTab.orders)

                NavigationStack {
                    ProfileView(selectedTab: $selectedTab)
                }
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle")
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
