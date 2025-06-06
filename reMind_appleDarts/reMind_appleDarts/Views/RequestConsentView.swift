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
    
    private var db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack (spacing: 12){
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
            ActivityView(activityItems: [
                createdShareURL != nil ? URL(string: createdShareURL!)! : URL(string: "https://remind-f54ef.web.app/")!,
                "Hey \(recipientName)! Please create an avatar for me on reMind app 💛"
            ])
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
    
    // MARK: - Firestore Avatar Creation
    private func createAvatarInFirestore() {
        guard !recipientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isCreating = true
        
        // ユニークなアバターIDを生成
        let avatarId = generateAvatarId()
        
        // 現在のユーザー情報を取得
        let currentUserName = appViewModel.userDisplayName
        
        // Firestoreのavatarsコレクションに保存するデータ
        let avatarData = createBlankAvatarData(
            avatarId: avatarId,
            recipientName: recipientName.trimmingCharacters(in: .whitespacesAndNewlines),
            creatorName: currentUserName
        )
        
        // Firestoreに保存
        db.collection("avatars").document(avatarId).setData(avatarData) { [self] error in
            DispatchQueue.main.async {
                isCreating = false
                
                if let error = error {
                    print("❌ Firestore保存エラー: \(error.localizedDescription)")
                    alertTitle = "Error"
                    alertMessage = "Fail to create avatar. Please try again later."
                    showAlert = true
                } else {
                    print("✅ アバターがFirestoreに作成されました: \(avatarId)")
                    
                    // 共有URLを設定（アバター作成ページ）
                    createdShareURL = "https://remind-f54ef.web.app/create/\(avatarId)"
                    
                    alertTitle = "Success!"
                    alertMessage = "Send UrL to \(recipientName)!"
                    showAlert = true
                    
                    // ローカルにもpending状態のアバターを追加
                    addPendingAvatarLocally(avatarId: avatarId)
                }
            }
        }
    }
    
    // MARK: - Avatar Data Creation Function
    private func createBlankAvatarData(avatarId: String, recipientName: String, creatorName: String) -> [String: Any] {
        return [
            "id": avatarId,
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
            "instructions": "Please upload your photos and record a voice message to complete this avatar",
            "requested_by": creatorName,
            "completion_percentage": 0, 
            "required_images": 3,
            "required_audio": true,
            "avatar_type": "consent_requested"
        ]
    }
    
    // MARK: - Local Avatar Addition
    private func addPendingAvatarLocally(avatarId: String) {
        // ローカルのAvatarマネージャーにpending状態のアバターを追加
        let pendingAvatar = Avatar(
            id: abs(avatarId.hashValue),
            name: recipientName.trimmingCharacters(in: .whitespacesAndNewlines),
            isDefault: false,
            language: "English",
            theme: "Pending",
            voiceTone: "Not Set",
            profileImg: "sample_avatar",
            deepfakeReady: false // not_ready状態なのでfalse
        )
        
        appViewModel.avatarManager.addAvatar(pendingAvatar)
        print("📱 ローカルにpendingアバターを追加: \(pendingAvatar.name)")
    }
    
    // MARK: - Helper Functions
    private func generateAvatarId() -> String {
        return "avatar_\(Date().timeIntervalSince1970)_\(Int.random(in: 1000...9999))"
    }
    
    // MARK: - Debug Function
    private func printAvatarData(_ data: [String: Any]) {
        print("🔍 作成されるアバターデータ:")
        for (key, value) in data {
            print("  - \(key): \(value)")
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    RequestConsentView()
        .environmentObject(AppViewModel())
}
