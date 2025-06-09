//
//  ContentView.swift
//  reMind_appleDarts
//
//  Created by Sumi on 30/5/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        Group {
            if appViewModel.isLoading {
                LoadingView()
            } else if appViewModel.shouldShowOnboarding {
                OnboardingView()
            } else if appViewModel.shouldShowTutorial {
                TutorialView()
            } else if appViewModel.shouldShowMainApp {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(appViewModel)
        .onAppear {
            appViewModel.checkTutorialStatus()
            
            appViewModel.checkAutoLogin()
            
            print("🚀 App launched - Current state:")
            print("  - isLoggedIn: \(appViewModel.isLoggedIn)")
            print("  - hasCompletedTutorial: \(appViewModel.hasCompletedTutorial)")
            print("  - shouldShowOnboarding: \(appViewModel.shouldShowOnboarding)")
            print("  - shouldShowTutorial: \(appViewModel.shouldShowTutorial)")
            print("  - shouldShowMainApp: \(appViewModel.shouldShowMainApp)")
            print("  - hasValidSession: \(appViewModel.hasValidSession())")
        }
        .animation(.easeInOut(duration: 0.3), value: appViewModel.isLoggedIn)
        .animation(.easeInOut(duration: 0.3), value: appViewModel.hasCompletedTutorial)
    }
}


#Preview {
    ContentView()
}
