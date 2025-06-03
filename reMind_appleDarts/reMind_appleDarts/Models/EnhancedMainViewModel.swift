//
//  EnhancedMainViewModel.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 3/6/2025.
//

import Foundation

class EnhancedMainViewModel: ObservableObject {
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
    
    // MARK: - Avatar Management
    
    /// Add a new avatar to the current user
    func addAvatar(_ avatar: Avatar) {
        // Create user if doesn't exist
        if currentUser == nil {
            createDummyUser()
        }
        
        guard var user = currentUser else { return }
        
        // If this avatar is set as default, remove default status from other avatars
        if avatar.isDefault {
            user.avatars = user.avatars.map { existingAvatar in
                var updatedAvatar = existingAvatar
                updatedAvatar.isDefault = false
                return updatedAvatar
            }
        }
        
        user.avatars.append(avatar)
        updateUser(user)
    }
    
    /// Update an existing avatar
    func updateAvatar(_ updatedAvatar: Avatar) {
        guard var user = currentUser else { return }
        
        // Find and update the avatar
        if let index = user.avatars.firstIndex(where: { $0.id == updatedAvatar.id }) {
            // If this avatar is being set as default, remove default from others
            if updatedAvatar.isDefault {
                user.avatars = user.avatars.map { avatar in
                    var updated = avatar
                    if updated.id != updatedAvatar.id {
                        updated.isDefault = false
                    }
                    return updated
                }
            }
            
            user.avatars[index] = updatedAvatar
            updateUser(user)
        }
    }
    
    /// Delete an avatar
    func deleteAvatar(withId avatarId: Int) {
        guard var user = currentUser else { return }
        
        // Remove the avatar
        user.avatars.removeAll { $0.id == avatarId }
        
        // If we removed the default avatar and there are other avatars, make the first one default
        if !user.avatars.isEmpty && user.defaultAvatar == nil {
            user.avatars[0].isDefault = true
        }
        
        updateUser(user)
    }
    
    /// Set an avatar as default
    func setDefaultAvatar(withId avatarId: Int) {
        guard var user = currentUser else { return }
        
        // Update all avatars
        user.avatars = user.avatars.map { avatar in
            var updated = avatar
            updated.isDefault = (avatar.id == avatarId)
            return updated
        }
        
        updateUser(user)
    }
    
    // MARK: - Avatar Queries
    
    /// Get all avatars for the current user
    var userAvatars: [Avatar] {
        return currentUser?.avatars ?? []
    }
    
    /// Get the default avatar for the current user
    var defaultAvatar: Avatar? {
        return currentUser?.defaultAvatar
    }
    
    /// Get avatars filtered by language
    func getAvatars(byLanguage language: String) -> [Avatar] {
        return userAvatars.filter { $0.language == language }
    }
    
    /// Get avatars filtered by theme
    func getAvatars(byTheme theme: String) -> [Avatar] {
        return userAvatars.filter { $0.theme == theme }
    }
    
    /// Check if an avatar name already exists
    func avatarNameExists(_ name: String) -> Bool {
        return userAvatars.contains { $0.name.lowercased() == name.lowercased() }
    }
    
    /// Get avatar count
    var avatarCount: Int {
        return userAvatars.count
    }
    
    /// Check if user has any avatars
    var hasAvatars: Bool {
        return !userAvatars.isEmpty
    }
    
    // MARK: - Helper Methods
    
    /// Update the current user and save to UserManager
    private func updateUser(_ user: User) {
        // Enforce single default avatar locally before saving
        let correctedUser = enforceSingleDefaultAvatarLocally(user)
        self.currentUser = correctedUser
        UserManager.shared.saveUser(correctedUser)
    }
    
    /// Local implementation of single default avatar enforcement
    private func enforceSingleDefaultAvatarLocally(_ user: User) -> User {
        var updatedUser = user
        let defaultAvatars = user.avatars.filter { $0.isDefault }

        if defaultAvatars.count <= 1 {
            return user
        }

        var foundOne = false
        updatedUser.avatars = user.avatars.map { avatar in
            var a = avatar
            if a.isDefault {
                if !foundOne {
                    foundOne = true
                    a.isDefault = true
                } else {
                    a.isDefault = false
                }
            }
            return a
        }

        return updatedUser
    }
    
    /// Create a sample avatar for demonstration
    func createSampleAvatar() -> Avatar {
        return Avatar(
            id: Int.random(in: 10000...99999),
            name: "Sample Avatar",
            isDefault: userAvatars.isEmpty, // Make default if it's the first avatar
            language: "English",
            theme: "Calm",
            voiceTone: "Gentle",
            profileImg: "sample_avatar",
            deepfakeReady: false
        )
    }
    
    /// Validate avatar data before creation/update
    func validateAvatarData(name: String, excludingId: Int? = nil) -> ValidationResult {
        // Check if name is empty
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return ValidationResult(isValid: false, message: "Avatar name cannot be empty")
        }
        
        // Check if name is too long
        if name.count > 30 {
            return ValidationResult(isValid: false, message: "Avatar name must be 30 characters or less")
        }
        
        // Check for duplicate names (excluding the current avatar if updating)
        let existingNames = userAvatars
            .filter { excludingId == nil || $0.id != excludingId }
            .map { $0.name.lowercased() }
        
        if existingNames.contains(name.lowercased()) {
            return ValidationResult(isValid: false, message: "An avatar with this name already exists")
        }
        
        return ValidationResult(isValid: true, message: "")
    }
    
    // MARK: - Demo Data
    
    /// Create demo avatars for testing
    func createDemoAvatars() {
        let demoAvatars = [
            Avatar(
                id: 1001,
                name: "Sumi",
                isDefault: true,
                language: "English",
                theme: "Calm",
                voiceTone: "Gentle",
                profileImg: "sample_avatar",
                deepfakeReady: true
            ),
            Avatar(
                id: 1002,
                name: "Maria",
                isDefault: false,
                language: "Spanish",
                theme: "Energetic",
                voiceTone: "Medium",
                profileImg: "sample_avatar",
                deepfakeReady: true
            ),
            Avatar(
                id: 1003,
                name: "Alex",
                isDefault: false,
                language: "English",
                theme: "Motivational",
                voiceTone: "Clear",
                profileImg: "sample_avatar",
                deepfakeReady: false
            )
        ]
        
        // Create user if doesn't exist
        if currentUser == nil {
            createDummyUser()
        }
        
        guard var user = currentUser else { return }
        
        // Add demo avatars
        user.avatars = demoAvatars
        updateUser(user)
    }
    
    /// Clear all avatars
    func clearAllAvatars() {
        guard var user = currentUser else { return }
        user.avatars = []
        updateUser(user)
    }
}

// MARK: - Validation Result
struct ValidationResult {
    let isValid: Bool
    let message: String
}

// MARK: - User Extensions
extension User {
    var displayName: String {
        return name.isEmpty ? "User" : name
    }
    
    var avatarCount: Int {
        return avatars.count
    }
    
    var hasDefaultAvatar: Bool {
        return defaultAvatar != nil
    }
}
