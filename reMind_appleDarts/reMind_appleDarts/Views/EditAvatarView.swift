//
//  EditAvatarView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 3/6/2025.
//
import SwiftUI

struct EditAvatarView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let originalAvatar: Avatar
    
    @State private var avatarName: String
    @State private var selectedLanguage: String
    @State private var selectedTheme: String
    @State private var selectedVoiceTone: String
    @State private var selectedProfileImage: String
    @State private var isDefault: Bool
    @State private var showingImagePicker = false
    @State private var showSuccessAlert = false
    @State private var isUpdating = false
    @State private var validationMessage = ""
    @State private var showingDiscardAlert = false
    
    private let languages = ["English", "Japanese", "Spanish", "French", "German", "Italian"]
    private let themes = ["Calm", "Energetic", "Peaceful", "Motivational", "Relaxing", "Cheerful"]
    private let voiceTones = ["Gentle", "Soft", "Medium", "Warm", "Clear", "Soothing"]
    private let profileImages = ["sample_avatar", "avatar_1", "avatar_2", "avatar_3", "avatar_4"]
    
    init(avatar: Avatar) {
        self.originalAvatar = avatar
        self._avatarName = State(initialValue: avatar.name)
        self._selectedLanguage = State(initialValue: avatar.language)
        self._selectedTheme = State(initialValue: avatar.theme)
        self._selectedVoiceTone = State(initialValue: avatar.voiceTone)
        self._selectedProfileImage = State(initialValue: avatar.profileImg)
        self._isDefault = State(initialValue: avatar.isDefault)
    }
    
    // Check if any changes have been made
    private var hasChanges: Bool {
        avatarName != originalAvatar.name ||
        selectedLanguage != originalAvatar.language ||
        selectedTheme != originalAvatar.theme ||
        selectedVoiceTone != originalAvatar.voiceTone ||
        selectedProfileImage != originalAvatar.profileImg ||
        isDefault != originalAvatar.isDefault
    }
    
    // Form validation
    private var isFormValid: Bool {
        let validation = appViewModel.avatarManager.validateAvatarData(name: avatarName, excludingId: originalAvatar.id)
        return validation.isValid
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                BackGroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Form Fields
                        formFieldsSection
                        
                        // Default Avatar Toggle
                        defaultToggleSection
                        
                        // Validation Message
                        if !validationMessage.isEmpty {
                            Text(validationMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 30)
                        }
                        
                        // Action Buttons
                        actionButtonsSection
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Avatar Updated!", isPresented: $showSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your avatar '\(avatarName)' has been updated successfully!")
        }
        .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
            Button("Keep Editing", role: .cancel) {}
            Button("Discard", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
        .onChange(of: avatarName) { _ in
            validateForm()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Title
            VStack(spacing: 8) {
                Text("Edit Avatar")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primaryText)
                
                Text("Update your support companion")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
        }
    }
    
    // MARK: - Form Fields Section
    private var formFieldsSection: some View {
        VStack(spacing: 20) {
            // Avatar Name
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Avatar Name")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                    
                    Spacer()
                    
                    Text("\(avatarName.count)/30")
                        .font(.caption2)
                        .foregroundColor(avatarName.count > 25 ? .orange : .gray)
                }
                
                TextField("Enter avatar name", text: $avatarName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                !isFormValid && !avatarName.isEmpty ? Color.red : Color.gray.opacity(0.3),
                                lineWidth: !isFormValid && !avatarName.isEmpty ? 2 : 1
                            )
                    )
            }
            
            // Language Selection
            selectionField(
                title: "Language",
                selectedValue: selectedLanguage,
                options: languages,
                icon: "globe"
            ) { language in
                selectedLanguage = language
            }
            
            // Theme Selection
            selectionField(
                title: "Theme",
                selectedValue: selectedTheme,
                options: themes,
                icon: "paintpalette"
            ) { theme in
                selectedTheme = theme
            }
            
            // Voice Tone Selection
            selectionField(
                title: "Voice Tone",
                selectedValue: selectedVoiceTone,
                options: voiceTones,
                icon: "speaker.wave.2"
            ) { voiceTone in
                selectedVoiceTone = voiceTone
            }
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Default Toggle Section
    private var defaultToggleSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Default Avatar")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                    
                    Text(isDefault ?
                         "This is your primary companion" :
                         "Set as your primary companion")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: $isDefault)
                    .toggleStyle(SwitchToggleStyle(tint: .primaryGreen))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDefault ? Color.primaryGreen.opacity(0.1) : Color.white.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDefault ? Color.primaryGreen.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
            )
            
            if originalAvatar.isDefault && !isDefault && appViewModel.avatarCount > 1 {
                Text("⚠️ Removing default status will make another avatar the default")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Changes indicator
            if hasChanges {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                    Text("You have unsaved changes")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            HStack(spacing: 16) {
                // Cancel Button
                Button(action: {
                    if hasChanges {
                        showingDiscardAlert = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text(hasChanges ? "Discard" : "Cancel")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .font(.headline)
                }
                
                // Update Button
                Button(action: updateAvatar) {
                    HStack {
                        if isUpdating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.black)
                        }
                        Text(isUpdating ? "Updating..." : "Update Avatar")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        (!isFormValid || isUpdating || !hasChanges) ?
                        Color.gray.opacity(0.5) :
                        Color.primaryGreen
                    )
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .font(.headline)
                }
                .disabled(!isFormValid || isUpdating || !hasChanges)
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
    }
    
    // MARK: - Helper Views
    private func selectionField(
        title: String,
        selectedValue: String,
        options: [String],
        icon: String,
        onSelection: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        onSelection(option)
                    }) {
                        HStack {
                            Text(option)
                            if selectedValue == option {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primaryText)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    
                    Text(selectedValue)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
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
    }
    
    // MARK: - Functions
    private func validateForm() {
        let validation = appViewModel.avatarManager.validateAvatarData(name: avatarName, excludingId: originalAvatar.id)
        validationMessage = validation.isValid ? "" : validation.message
    }
    
    private func updateAvatar() {
        // Validate form
        let validation = appViewModel.avatarManager.validateAvatarData(name: avatarName.trimmingCharacters(in: .whitespacesAndNewlines), excludingId: originalAvatar.id)
        
        if !validation.isValid {
            validationMessage = validation.message
            return
        }
        
        // Set loading state
        isUpdating = true
        
        // Add a small delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            // Create updated avatar
            let updatedAvatar = Avatar(
                id: originalAvatar.id,
                name: avatarName.trimmingCharacters(in: .whitespacesAndNewlines),
                isDefault: isDefault,
                language: selectedLanguage,
                theme: selectedTheme,
                voiceTone: selectedVoiceTone,
                profileImg: selectedProfileImage,
                deepfakeReady: originalAvatar.deepfakeReady
            )
            
            // Update avatar through appViewModel
            appViewModel.avatarManager.updateAvatar(updatedAvatar)
            
            // Reset loading state
            isUpdating = false
            
            // Show success alert
            showSuccessAlert = true
        }
    }
}

#Preview {
    EditAvatarView(avatar: Avatar(
        id: 1,
        name: "Sample Avatar",
        isDefault: true,
        language: "English",
        theme: "Calm",
        voiceTone: "Gentle",
        profileImg: "sample_avatar",
        deepfakeReady: true
    ))
    .environmentObject(AppViewModel())
}
