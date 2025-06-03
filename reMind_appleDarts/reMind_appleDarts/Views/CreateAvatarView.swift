//
//  CreateAvatarView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 3/6/2025.
//

import SwiftUI

struct CreateAvatarView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var avatarName = ""
    @State private var selectedLanguage = "English"
    @State private var selectedTheme = "Calm"
    @State private var selectedVoiceTone = "Gentle"
    @State private var selectedProfileImage = "sample_avatar"
    @State private var isDefault = false
    @State private var showingImagePicker = false
    @State private var showSuccessAlert = false
    @State private var isCreating = false // Add loading state
    
    private let languages = ["English", "Japanese", "Spanish", "French", "German", "Italian"]
    private let themes = ["Calm", "Energetic", "Peaceful", "Motivational", "Relaxing", "Cheerful"]
    private let voiceTones = ["Gentle", "Soft", "Medium", "Warm", "Clear", "Soothing"]
    private let profileImages = ["sample_avatar", "avatar_1", "avatar_2", "avatar_3", "avatar_4"]
    
    // Computed property to check if form is valid
    private var isFormValid: Bool {
        !avatarName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            // Background
            BackGroundView()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create New Avatar")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primaryText)
                        
                        Text("Design your personal support companion")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // Avatar Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Avatar Name")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                            
                            TextField("Enter avatar name", text: $avatarName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                        }
                        
                        // Language Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Language")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                            
                            Menu {
                                ForEach(languages, id: \.self) { language in
                                    Button(action: {
                                        selectedLanguage = language
                                    }) {
                                        HStack {
                                            Text(language)
                                            if selectedLanguage == language {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedLanguage)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                            }
                        }
                        
                        // Theme Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Theme")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                            
                            Menu {
                                ForEach(themes, id: \.self) { theme in
                                    Button(action: {
                                        selectedTheme = theme
                                    }) {
                                        HStack {
                                            Text(theme)
                                            if selectedTheme == theme {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedTheme)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                            }
                        }
                        
                        // Voice Tone Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Voice Tone")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                            
                            Menu {
                                ForEach(voiceTones, id: \.self) { tone in
                                    Button(action: {
                                        selectedVoiceTone = tone
                                    }) {
                                        HStack {
                                            Text(tone)
                                            if selectedVoiceTone == tone {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedVoiceTone)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                            }
                        }
                        
                        // Default Avatar Toggle
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Set as Default Avatar")
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryText)
                                
                                Text("This avatar will be your primary companion")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $isDefault)
                                .toggleStyle(SwitchToggleStyle(tint: .primaryGreen))
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Debug info (remove in production)
                        Text("Form Valid: \(isFormValid ? "Yes" : "No")")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 16) {
                            // Cancel Button
                            Button(action: {
                                print("Cancel button pressed")
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.gray.opacity(0.3))
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                                    .font(.headline)
                            }
                            
                            // Create Button
                            Button(action: {
                                print("Create button pressed")
                                print("Avatar name: '\(avatarName)'")
                                print("Is form valid: \(isFormValid)")
                                createAvatar()
                            }) {
                                HStack {
                                    if isCreating {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(.black)
                                    }
                                    Text(isCreating ? "Creating..." : "Create Avatar")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    (!isFormValid || isCreating) ?
                                    Color.gray.opacity(0.5) :
                                    Color.primaryGreen
                                )
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .font(.headline)
                            }
                            .disabled(!isFormValid || isCreating)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Avatar Created!", isPresented: $showSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your new avatar '\(avatarName)' has been created successfully!")
        }
    }
    
    private func createAvatar() {
        print("createAvatar() function called")
        
        // Set loading state
        isCreating = true
        
        // Add a small delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            // Create new avatar
            let newAvatar = Avatar(
                id: Int.random(in: 10000...99999),
                name: avatarName.trimmingCharacters(in: .whitespacesAndNewlines),
                isDefault: isDefault,
                language: selectedLanguage,
                theme: selectedTheme,
                voiceTone: selectedVoiceTone,
                profileImg: selectedProfileImage,
                deepfakeReady: false
            )
            
            print("New avatar created: \(newAvatar)")
            
            // If no current user exists, create a dummy user
            var currentUser = viewModel.currentUser
            if currentUser == nil {
                print("No current user found, creating dummy user")
                currentUser = User(
                    id: Int.random(in: 1000...9999),
                    name: "User",
                    email: "user@example.com",
                    password: "",
                    profileImg: "sample_avatar",
                    avatars: []
                )
                viewModel.currentUser = currentUser
                viewModel.isLoggedIn = true
            }
            
            guard var user = currentUser else {
                print("Failed to create/get user")
                isCreating = false
                return
            }
            
            print("Working with user: \(user.name)")
            
            // If this is set as default, make sure no other avatar is default
            if isDefault {
                user.avatars = user.avatars.map { avatar in
                    var updatedAvatar = avatar
                    updatedAvatar.isDefault = false
                    return updatedAvatar
                }
            }
            
            // Add new avatar
            user.avatars.append(newAvatar)
            
            print("User updated with \(user.avatars.count) avatars")
            
            // Update user in UserManager and ViewModel
            UserManager.shared.saveUser(user)
            viewModel.currentUser = user
            
            print("User saved and viewModel updated")
            
            // Reset loading state
            isCreating = false
            
            // Show success alert
            showSuccessAlert = true
        }
    }
}

// Extension to make MainViewModel work properly if not already implemented
extension MainViewModel {
    func addAvatar(_ avatar: Avatar) {
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
        UserManager.shared.saveUser(user)
        self.currentUser = user
    }
}

#Preview {
    CreateAvatarView()
        .environmentObject(MainViewModel())
}
