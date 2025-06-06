import SwiftUI

struct CreateAvatarView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var avatarName = ""
    @State private var selectedLanguage = "English"
    @State private var selectedTheme = "Calm"
    @State private var selectedVoiceTone = "Gentle"
    @State private var selectedProfileImage = "sample_avatar"
    @State private var isDefault = false
    @State private var showingImagePicker = false
    @State private var showSuccessAlert = false
    @State private var isCreating = false
    @State private var validationMessage = ""
    
    var onAvatarCreated: (() -> Void)? = nil
    
    private let languages = ["English", "Japanese", "Spanish", "French", "German", "Italian"]
    private let themes = ["Calm", "Energetic", "Peaceful", "Motivational", "Relaxing", "Cheerful"]
    private let voiceTones = ["Gentle", "Soft", "Medium", "Warm", "Clear", "Soothing"]
    private let profileImages = ["sample_avatar", "avatar_1", "avatar_2", "avatar_3", "avatar_4"]
    
    // Computed property to check if form is valid
    private var isFormValid: Bool {
        let validation = appViewModel.avatarManager.validateAvatarData(name: avatarName)
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
        .alert("Avatar Created!", isPresented: $showSuccessAlert) {
            Button("OK") {
                onAvatarCreated?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text("Your new avatar '\(avatarName)' has been created successfully!")
        }
        .onChange(of: avatarName) { _ in
            validateForm()
        }
        .onAppear {
            // Set as default if this is the first avatar
            isDefault = !appViewModel.hasAvatars
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Create New Avatar")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primaryText)
            
            Text("Design your personal support companion")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
        }
        .padding(.top, 20)
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
                         "This will be your primary companion" :
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
            
            if !appViewModel.hasAvatars {
                Text("💡 This will be your first avatar and will be set as default")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Cancel Button
                Button(action: {
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
                Button(action: createAvatar) {
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
        let validation = appViewModel.avatarManager.validateAvatarData(name: avatarName)
        validationMessage = validation.isValid ? "" : validation.message
    }
    
    private func createAvatar() {
        // Validate form one more time
        let validation = appViewModel.avatarManager.validateAvatarData(name: avatarName.trimmingCharacters(in: .whitespacesAndNewlines))
        
        if !validation.isValid {
            validationMessage = validation.message
            return
        }
        
        // Set loading state
        isCreating = true
        
        // Add a small delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Create new avatar
            let newAvatar = Avatar(
                id: Int.random(in: 10000...99999),
                name: avatarName.trimmingCharacters(in: .whitespacesAndNewlines),
                isDefault: isDefault || !appViewModel.hasAvatars, // Set as default if first avatar
                language: selectedLanguage,
                theme: selectedTheme,
                voiceTone: selectedVoiceTone,
                profileImg: selectedProfileImage,
                deepfakeReady: false
            )
            
            appViewModel.avatarManager.addAvatar(newAvatar)
            

            appViewModel.objectWillChange.send()
            
            print("✅ Avatar created: \(newAvatar.name), Total avatars: \(appViewModel.avatarManager.avatars.count)")
            
            // Reset loading state
            isCreating = false
            
            // Show success alert
            showSuccessAlert = true
        }
    }
}

#Preview {
    CreateAvatarView()
        .environmentObject(AppViewModel())
}
