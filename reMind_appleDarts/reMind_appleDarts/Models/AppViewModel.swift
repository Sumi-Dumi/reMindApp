//
//  Untitled.swift
//  reMind_appleDarts
//
//  Created by user on 2025/06/03.
//

import Foundation
import SwiftUI

/// Main application view model that coordinates between authentication and avatar management
class AppViewModel: ObservableObject {
    @Published var authViewModel: AuthenticationViewModel
    @Published var avatarManager: AvatarManager
    
    init() {
        // Initialize both view models without connection first
        self.authViewModel = AuthenticationViewModel()
        self.avatarManager = AvatarManager()
        
        // After initialization, set up the connection
        avatarManager.setAuthViewModel(authViewModel)
        
        // Set up observer for user changes
        setupUserObserver()
    }
    
    // MARK: - Setup
    
    private func setupUserObserver() {
        // When current user changes, reload avatars
        authViewModel.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.avatarManager.loadAvatars()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Convenience Properties
    
    /// User display information
    var userDisplayName: String {
        return authViewModel.userDisplayName
    }
    
    var userProfileImage: String {
        // Return default avatar image if available, otherwise user profile image
        return avatarManager.defaultAvatar?.profileImg ?? authViewModel.userProfileImage
    }
    
    var isLoggedIn: Bool {
        return authViewModel.isLoggedIn
    }
    
    var hasUser: Bool {
        return authViewModel.hasUser
    }
    
    /// Avatar information
    var hasAvatars: Bool {
        return avatarManager.hasAvatars
    }
    
    var avatarCount: Int {
        return avatarManager.avatarCount
    }
    
    var avatarCountDescription: String {
        let count = avatarCount
        return count == 0 ? "Feel grounded with your loved one" :
               "You have \(count) support companion\(count == 1 ? "" : "s")"
    }
    
    // MARK: - Initialization Methods
    
    /// Ensure user exists when app starts
    func initializeApp() {
        if !authViewModel.hasUser {
            authViewModel.createDummyUser()
        }
    }
    
    /// Create demo data for development/testing
    func createDemoData() {
        if !authViewModel.hasUser {
            authViewModel.createDummyUser()
        }
        avatarManager.createDemoAvatars()
    }
    
    /// Reset all data
    func resetAllData() {
        avatarManager.clearAllAvatars()
        authViewModel.logout()
    }
    
    // MARK: - Quick Actions
    
    /// Quick method to create a sample avatar
    func createSampleAvatar() {
        let sampleAvatar = avatarManager.createSampleAvatar()
        avatarManager.addAvatar(sampleAvatar)
    }
}

// MARK: - Combine Import
import Combine
