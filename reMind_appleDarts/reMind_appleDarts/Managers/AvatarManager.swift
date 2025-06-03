//
//  AvatarManager.swift
//  reMind_appleDarts
//
//  Created by user on 2025/06/03.
//
import Foundation

class AvatarManager: ObservableObject {
    @Published var avatars: [Avatar] = []
    @Published var isLoading: Bool = false
    
    // Reference to AuthenticationViewModel to access current user
    private weak var authViewModel: AuthenticationViewModel?
    
    init(authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel
        loadAvatars()
    }
    
    init() {
        self.authViewModel = nil
        // Don't load avatars until authViewModel is set
    }
    
    // MARK: - Avatar Queries
    
    /// Get the default avatar
    var defaultAvatar: Avatar? {
        return avatars.first(where: { $0.isDefault })
    }
    
    /// Get avatar count
    var avatarCount: Int {
        return avatars.count
    }
    
    /// Check if user has any avatars
    var hasAvatars: Bool {
        return !avatars.isEmpty
    }
    
    /// Get avatars filtered by language
    func getAvatars(byLanguage language: String) -> [Avatar] {
        return avatars.filter { $0.language == language }
    }
    
    /// Get avatars filtered by theme
    func getAvatars(byTheme theme: String) -> [Avatar] {
        return avatars.filter { $0.theme == theme }
    }
    
    /// Check if an avatar name already exists
    func avatarNameExists(_ name: String, excludingId: Int? = nil) -> Bool {
        return avatars
            .filter { excludingId == nil || $0.id != excludingId }
            .contains { $0.name.lowercased() == name.lowercased() }
    }
    
    // MARK: - Avatar Management
    
    /// Load avatars from current user
    func loadAvatars() {
        guard let user = authViewModel?.currentUser else {
            self.avatars = []
            return
        }
        self.avatars = user.avatars
    }
    
    /// Add a new avatar
    func addAvatar(_ avatar: Avatar) {
        // Ensure we have a user
        if authViewModel?.currentUser == nil {
            authViewModel?.createDummyUser()
        }
        
        guard var user = authViewModel?.currentUser else { return }
        
        // If this avatar is set as default, remove default status from other avatars
        if avatar.isDefault {
            avatars = avatars.map { existingAvatar in
                var updatedAvatar = existingAvatar
                updatedAvatar.isDefault = false
                return updatedAvatar
            }
            user.avatars = avatars
        }
        
        // Add new avatar to local array and user
        avatars.append(avatar)
        user.avatars = avatars
        
        // Update user data
        updateUserData(user)
    }
    
    /// Update an existing avatar
    func updateAvatar(_ updatedAvatar: Avatar) {
        guard var user = authViewModel?.currentUser else { return }
        
        // Find and update the avatar in local array
        if let index = avatars.firstIndex(where: { $0.id == updatedAvatar.id }) {
            // If this avatar is being set as default, remove default from others
            if updatedAvatar.isDefault {
                avatars = avatars.map { avatar in
                    var updated = avatar
                    if updated.id != updatedAvatar.id {
                        updated.isDefault = false
                    }
                    return updated
                }
            }
            
            avatars[index] = updatedAvatar
            user.avatars = avatars
            updateUserData(user)
        }
    }
    
    /// Delete an avatar
    func deleteAvatar(withId avatarId: Int) {
        guard var user = authViewModel?.currentUser else { return }
        
        // Remove the avatar from local array
        avatars.removeAll { $0.id == avatarId }
        
        // If we removed the default avatar and there are other avatars, make the first one default
        if !avatars.isEmpty && defaultAvatar == nil {
            avatars[0].isDefault = true
        }
        
        user.avatars = avatars
        updateUserData(user)
    }
    
    /// Set an avatar as default
    func setDefaultAvatar(withId avatarId: Int) {
        guard var user = authViewModel?.currentUser else { return }
        
        // Update all avatars in local array
        avatars = avatars.map { avatar in
            var updated = avatar
            updated.isDefault = (avatar.id == avatarId)
            return updated
        }
        
        user.avatars = avatars
        updateUserData(user)
    }
    
    // MARK: - Helper Methods
    
    /// Update user data and save
    private func updateUserData(_ user: User) {
        let correctedUser = enforceSingleDefaultAvatar(user)
        authViewModel?.currentUser = correctedUser
        UserManager.shared.saveUser(correctedUser)
        
        // Update local avatars array to match corrected user
        self.avatars = correctedUser.avatars
    }
    
    /// Enforce single default avatar
    private func enforceSingleDefaultAvatar(_ user: User) -> User {
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
    
    /// Validate avatar data before creation/update
    func validateAvatarData(name: String, excludingId: Int? = nil) -> ValidationResult {
        // Check if name is empty
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return ValidationResult(isValid: false, message: "Avatar name cannot be empty")
        }
        
        // Check if name is too long
        if trimmedName.count > 30 {
            return ValidationResult(isValid: false, message: "Avatar name must be 30 characters or less")
        }
        
        // Check for duplicate names
        if avatarNameExists(trimmedName, excludingId: excludingId) {
            return ValidationResult(isValid: false, message: "An avatar with this name already exists")
        }
        
        return ValidationResult(isValid: true, message: "")
    }
    
    /// Create a sample avatar for demonstration
    func createSampleAvatar() -> Avatar {
        return Avatar(
            id: Int.random(in: 10000...99999),
            name: "Sample Avatar",
            isDefault: avatars.isEmpty, // Make default if it's the first avatar
            language: "English",
            theme: "Calm",
            voiceTone: "Gentle",
            profileImg: "sample_avatar",
            deepfakeReady: false
        )
    }
    
    // MARK: - Demo Data
    
    /// Create demo avatars for testing
    func createDemoAvatars() {
        // Ensure we have a user
        if authViewModel?.currentUser == nil {
            authViewModel?.createDummyUser()
        }
        
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
        
        // Set avatars
        self.avatars = demoAvatars
        
        // Update user
        guard var user = authViewModel?.currentUser else { return }
        user.avatars = demoAvatars
        updateUserData(user)
    }
    
    /// Clear all avatars
    func clearAllAvatars() {
        self.avatars = []
        
        guard var user = authViewModel?.currentUser else { return }
        user.avatars = []
        updateUserData(user)
    }
    
    // MARK: - Connection with AuthViewModel
    
    /// Update the reference to AuthenticationViewModel
    func setAuthViewModel(_ authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel
        loadAvatars() // Reload avatars when auth view model is set
    }
}

// MARK: - Validation Result
struct ValidationResult {
    let isValid: Bool
    let message: String
}

// MARK: - Avatar Extensions
extension Avatar {
    var displayDescription: String {
        return "\(language) / \(voiceTone)"
    }
    
    var tagText: String {
        return isDefault ? "default" : ""
    }
    
    var tagColor: Color {
        return isDefault ? Color(red: 211 / 255, green: 246 / 255, blue: 242 / 255) : Color.clear
    }
}

import SwiftUI
extension Color {
    // This ensures Color is available for tagColor property
}
