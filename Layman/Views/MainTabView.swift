import SwiftUI
import UIKit

struct MainTabView: View {
    @Bindable var authVM: AuthViewModel
    @State private var selectedTab = 0
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView()
            }

            Tab("Saved", systemImage: "bookmark.fill", value: 1) {
                SavedView()
            }

            Tab("Profile", systemImage: "person.fill", value: 2) {
                ProfileView(authVM: authVM)
            }
        }
        .tint(.primaryOrange)
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
        .animation(.easeInOut(duration: 0.4), value: darkModeEnabled)
        .onChange(of: selectedTab) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}
