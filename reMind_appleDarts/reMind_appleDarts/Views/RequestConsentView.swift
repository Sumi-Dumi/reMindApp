import SwiftUI
import UIKit
import FirebaseFirestore

struct RequestConsentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingShareSheet = false
    @State private var recipientName: String = ""
    @State private var isCreating = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var createdShareURL: String?
    @State private var createdAvatarId: String?
    
    private var db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Request Consent")
                    .font(.title2.bold())
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Follow these steps for the best experience on this app")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 46)
            }
            
            TextField("Enter recipient's Name...", text: $recipientName)
                .padding()
                .frame(width: 346, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .foregroundColor(.black)

            Button(action: {
                createAvatarInFirestore()
            }) {
                HStack {
                    if isCreating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.black)
                    }
                    Text(isCreating ? "Creating..." : "Send Request")
                    if !isCreating {
                        Image(systemName: "arrow.right")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen)
                .foregroundColor(.black)
                .cornerRadius(15)
                .font(.headline)
                .opacity((recipientName.isEmpty || isCreating) ? 0.3 : 1.0)
            }
            .padding(.horizontal, 30)
            .disabled(recipientName.isEmpty || isCreating)

            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemPink).opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showingShareSheet) {
            ActivityView(activityItems: createActivityItems())
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertTitle == "Success!" {
                    showingShareSheet = true
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Firebase Avatar Creation
    private func createAvatarInFirestore() {
        guard !recipientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isCreating = true
        
        let avatarId = generateUniqueAvatarId()
        createdAvatarId = avatarId
        
        let currentUserName = appViewModel.userDisplayName
        let trimmedRecipientName = recipientName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let baseURL = "https://remind-f54ef.web.app"
        let createURL = "\(baseURL)/?avatarId=\(avatarId)"
        
        let avatarData = createAvatarData(
            avatarId: avatarId,
            recipientName: trimmedRecipientName,
            creatorName: currentUserName,
            createURL: createURL
        )
        
        db.collection("avatars").document(avatarId).setData(avatarData) { [self] error in
            DispatchQueue.main.async {
                isCreating = false
                
                if let error = error {
                    print("❌ Firestore save error: \(error.localizedDescription)")
                    alertTitle = "Error"
                    alertMessage = "Failed to create avatar. Please try again later."
                    showAlert = true
                } else {
                    print("✅ Avatar created in Firestore: \(avatarId)")
                    
                    createdShareURL = createURL
                    
                    alertTitle = "Success!"
                    alertMessage = "Avatar created successfully! Send the URL to \(trimmedRecipientName)!"
                    showAlert = true
                    
                }
            }
        }
    }
    
    // MARK: - Avatar Data Creation
    private func createAvatarData(
        avatarId: String,
        recipientName: String,
        creatorName: String,
        createURL: String
    ) -> [String: Any] {
        return [
            "id": avatarId,
            "name": recipientName,
            "isDefault": false,
            "language": "English",
            "theme": "Human",
            "voiceTone": "Gentle",
            "profileImg": "sample_avatar",
            "deepfakeReady": false,
            
            "recipient_name": recipientName,
            "creator_name": creatorName,
            "image_urls": [],
            "audio_url": "",
            "image_count": 0,
            "audio_size_mb": "0",
            "storage_provider": "cloudinary",
            "status": "not_ready",
            "created_at": Timestamp(date: Date()),
            "updated_at": Timestamp(date: Date()),
            "deepfake_video_urls": [],
            "deep_fake_video_url_ghibli": [],
            "deep_fake_video_url_ghibli_jap": []
        ]
    }
    
    // MARK: - Helper Functions
    private func createActivityItems() -> [Any] {
        if let shareURL = createdShareURL, !shareURL.isEmpty {
            guard let url = URL(string: shareURL) else {
                return createFallbackItems()
            }
            
            let customMessage = "Hey \(recipientName)! Please create an avatar for me using this link:"
            return [customMessage, url]
        } else {
            return createFallbackItems()
        }
    }
    
    private func createFallbackItems() -> [Any] {
        let fallbackMessage = "Hey \(recipientName)! Please create an avatar for me on reMind app 💛"
        
        guard let fallbackURL = URL(string: "https://remind-f54ef.web.app/") else {
            return [fallbackMessage]
        }
        
        return [fallbackMessage, fallbackURL]
    }
    
    private func generateUniqueAvatarId() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let randomComponent = Int.random(in: 1000...9999)
        return "avatar_\(timestamp)_\(randomComponent)"
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    RequestConsentView()
        .environmentObject(AppViewModel())
}
