import SwiftUI

@main
struct LaymanApp: App {
    @State private var authVM = AuthViewModel()
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isCheckingSession {
                    // Splash while restoring session
                    ZStack {
                        Color.appBackground.ignoresSafeArea()
                        VStack(spacing: 16) {
                            Text("Layman")
                                .font(.system(size: 36, weight: .bold, design: .serif))
                                .foregroundColor(.textPrimary)
                            ProgressView()
                                .tint(.primaryOrange)
                        }
                    }
                } else if authVM.isAuthenticated {
                    MainTabView(authVM: authVM)
                } else if !hasSeenWelcome {
                    WelcomeView(hasSeenWelcome: $hasSeenWelcome)
                } else {
                    AuthView(authVM: authVM)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authVM.isAuthenticated)
            .animation(.easeInOut(duration: 0.3), value: hasSeenWelcome)
            .animation(.easeInOut(duration: 0.3), value: authVM.isCheckingSession)
            .task {
                authVM.startAuthListener()
            }
        }
    }
}
