import SwiftUI

struct MainAppView: View {
    @StateObject var viewModel = MainViewModel()

    var body: some View {
        Group {
            if viewModel.isLoggedIn {
                MainView()
                    .environmentObject(viewModel)
            } else {
                OnboardingView()
                    .environmentObject(viewModel)
            }
        }
    }
}
