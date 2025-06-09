import SwiftUI

struct EditUserView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var profileImageURL: String = ""
    @State private var navigateToMain = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    let previewUserId: String?

    init(previewUserId: String? = nil) {
        self.previewUserId = previewUserId
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundView()

                VStack(spacing: 24) {
                    Spacer()

                    Text(name.isEmpty ? "User Profile" : name)
                        .font(.title)
                        .bold()

                    AsyncImage(url: URL(string: profileImageURL.isEmpty ? defaultProfileImageURL : profileImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 16) {
                        LabeledTextField(label: "Name", value: $name)
                        LabeledTextField(label: "Email", value: $email)
                        LabeledTextField(label: "Password", value: $password, isSecure: true)
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    Button(action: saveProfile) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.black)
                            }
                            Text(isLoading ? "Saving..." : "Save")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.primaryGreen)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                        .font(.headline)
                    }
                    .padding(.horizontal, 30)
                    .disabled(isLoading)

                    Spacer(minLength: 10)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadUserData()
        }
        .alert("Profile Updated", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("success") {
                    navigateToMain = true
                }
            }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $navigateToMain) {
            MainTabView()
        }
    }
    
    private func loadUserData() {
        if let userId = previewUserId {
            loadPreviewUser(userId: userId)
        }
        else if let user = appViewModel.authViewModel.currentUser {
            name = user.name
            email = user.email
            password = user.password
            profileImageURL = user.profileImageURL
            print("✅ Loaded current user: \(user.name)")
        }
    }
    
    // 🔴 AppViewModelの共有FirebaseUserManagerを使用
    private func loadPreviewUser(userId: String) {
        print("🔄 Loading preview user: \(userId)")
        
        appViewModel.loadAndSetCurrentUser(userId: userId) { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.name = user.name
                    self.email = user.email
                    self.password = user.password
                    self.profileImageURL = user.profileImageURL
                    
                    print("✅ Preview user loaded: \(user.name)")
                    print("🖼️ Preview profileImageURL: '\(user.profileImageURL)'")
                    print("🔍 FirebaseUserManager currentUserId: \(self.appViewModel.firebaseUserManager.currentUserId ?? "nil")")
                } else {
                    self.loadTestUserData(userId: userId)
                }
            }
        }
    }
    
    private func loadTestUserData(userId: String) {
        self.name = "Test User (\(userId.prefix(8)))"
        self.email = "test@example.com"
        self.password = "password123"
        self.profileImageURL = "https://picsum.photos/150/150?random=\(userId.hashValue.magnitude % 100)"
        print("✅ Test user data loaded for preview")
    }
    
    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Name cannot be empty"
            showAlert = true
            return
        }
        
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Email cannot be empty"
            showAlert = true
            return
        }
        
        print("🔄 Saving profile...")
        print("  - Name: '\(name.trimmingCharacters(in: .whitespacesAndNewlines))'")
        print("  - Email: '\(email.trimmingCharacters(in: .whitespacesAndNewlines))'")
        print("  - ProfileImageURL: '\(profileImageURL.trimmingCharacters(in: .whitespacesAndNewlines))'")
        print("  - FirebaseUserManager currentUserId: \(appViewModel.firebaseUserManager.currentUserId ?? "nil")")
        
        appViewModel.updateProfile(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            profileImageURL: profileImageURL.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password.isEmpty ? nil : password
        )
        
        // Firebase更新結果を監視
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if appViewModel.errorMessage.isEmpty {
                alertMessage = "Profile updated successfully!"
                print("✅ Profile update successful")
            } else {
                alertMessage = "Update failed: \(appViewModel.errorMessage)"
                print("❌ Profile update failed: \(appViewModel.errorMessage)")
            }
            showAlert = true
        }
    }
    
    private var defaultProfileImageURL: String {
        return "https://res.cloudinary.com/dvyjkf3xq/image/upload/v1749361609/initial_profile_zfoxw0.png"
    }
}

struct LabeledTextField: View {
    let label: String
    @Binding var value: String
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)

            Group {
                if isSecure {
                    SecureField(" \(label.lowercased())", text: $value)
                } else {
                    TextField(" \(label.lowercased())", text: $value)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        }
    }
}

#Preview {
    EditUserView(previewUserId: "BKkzo8JLqoCNQq4jo3yw")
        .environmentObject(AppViewModel())
}
