import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        Group {
            if appViewModel.shouldShowOnboarding {
                OnboardingView()
            } else if appViewModel.shouldShowTutorial {
                TutorialView()
            } else {
                // ログイン済みでチュートリアル完了済み、またはデフォルト
                MainTabView()
            }
        }
        .environmentObject(appViewModel)
        .onAppear {
            setupApp()
        }
        .animation(.easeInOut(duration: 0.3), value: appViewModel.isLoggedIn)
        .animation(.easeInOut(duration: 0.3), value: appViewModel.hasCompletedTutorial)
    }
    
    private func setupApp() {
        print("🚀 ContentView setupApp() called")
        
        appViewModel.checkTutorialStatus()
        appViewModel.checkAutoLogin()
        
        print("✅ Complete initialize:")
        print("  - isLoggedIn: \(appViewModel.isLoggedIn)")
        print("  - hasCompletedTutorial: \(appViewModel.hasCompletedTutorial)")
        print("  - shouldShowOnboarding: \(appViewModel.shouldShowOnboarding)")
        print("  - shouldShowTutorial: \(appViewModel.shouldShowTutorial)")
        print("  - shouldShowMainApp: \(appViewModel.shouldShowMainApp)")
        print("  - hasValidSession: \(appViewModel.hasValidSession())")
    }
}

#Preview {
    ContentView()
}
