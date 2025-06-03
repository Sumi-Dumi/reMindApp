//
//  AuthenticationViewModel.swift
//  reMind_appleDarts
//
//  Created by user on 2025/06/03.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    
    init() {
        loadStoredUser()
    }
    
    // MARK: - User Authentication
    
    func login(with user: User) {
        self.currentUser = user
        self.isLoggedIn = true
        UserManager.shared.saveUser(user)
    }
    
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        UserManager.shared.clearUser()
    }
    
    func createDummyUser() {
        let dummyUser = User(
            id: Int.random(in: 1000...9999),
            name: "User",
            email: "user@example.com",
            password: "",
            profileImg: "sample_avatar",
            avatars: []
        )
        login(with: dummyUser)
    }
    
    private func loadStoredUser() {
        if let storedUser = UserManager.shared.loadUser() {
            self.currentUser = storedUser
            self.isLoggedIn = true
        }
    }
    
    // MARK: - User Profile Management
    
    func updateUserProfile(name: String? = nil, email: String? = nil, profileImg: String? = nil) {
        guard var user = currentUser else { return }
        
        if let name = name {
            user.name = name
        }
        if let email = email {
            user.email = email
        }
        if let profileImg = profileImg {
            user.profileImg = profileImg
        }
        
        self.currentUser = user
        UserManager.shared.saveUser(user)
    }
    
    // MARK: - User Data Access
    
    var userDisplayName: String {
        return currentUser?.displayName ?? "User"
    }
    
    var userProfileImage: String {
        return currentUser?.profileImg ?? "sample_avatar"
    }
    
    var userEmail: String {
        return currentUser?.email ?? ""
    }
    
    var hasUser: Bool {
        return currentUser != nil
    }
}

// MARK: - User Extensions
extension User {
    var displayName: String {
        return name.isEmpty ? "User" : name
    }
}
