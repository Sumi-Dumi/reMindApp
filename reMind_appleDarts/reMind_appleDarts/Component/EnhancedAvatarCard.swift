import SwiftUI

struct EnhancedAvatarCard: View {
    let avatar: Avatar
    let onEdit: (() -> Void)?
    
    @State private var showingEditView = false
    @State private var showingSessionView = false
    
    init(
        avatar: Avatar,
        onEdit: (() -> Void)? = nil
    ) {
        self.avatar = avatar
        self.onEdit = onEdit
    }
    
    var body: some View {
        Button(action: {
            showingSessionView = true
        }) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                )
                .frame(width: 380, height: 120)
                .overlay(
                    HStack(spacing: 20) {
                        // Avatar image
                        if let imageUrl = avatar.image_urls.first, !imageUrl.isEmpty {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image("sample_avatar")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                            .frame(width: 68, height: 72)
                            .clipShape(Circle())
                        } else {
                            Image("sample_avatar")
                                .resizable()
                                .frame(width: 68, height: 72)
                                .clipShape(Circle())
                        }
                        
                        // Text content
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(avatar.name)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primaryText)
                                if avatar.isDefault {
                                    Text("Default")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(red: 52/255, green: 211/255, blue: 153/255).opacity(0.8))
                                        .cornerRadius(150)
                                }
                            }
                            
                            Text(avatar.displayDescription)
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if let onEdit = onEdit {
                                onEdit()
                            } else {
                                showingEditView = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16, weight: .medium))

                                Text("Edit")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(8)
                           
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                )
        }
        .fullScreenCover(isPresented: $showingSessionView) {
            SessionView(avatar: avatar)
        }
        .sheet(isPresented: $showingEditView) {
            EditAvatarView(avatar: avatar)
                .environmentObject(AppViewModel())
        }
    }
}

struct UpdatedAvatarCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleFirestoreAvatar = Avatar(
            id: "avatar_12345",
            name: "Bob",
            isDefault: true,
            language: "English",
            theme: "Ghibli",
            voiceTone: "Gentle",
            profileImg: "sample_avatar",
            deepfakeReady: true,
            recipient_name: "Alice",
            creator_name: "Bob",
            image_urls: ["https://example.com/avatar.jpg"],
            audio_url: "https://example.com/audio.mp3",
            image_count: 3,
            audio_size_mb: "2.5",
            storage_provider: "cloudinary",
            status: "ready",
            created_at: nil,
            updated_at: nil,
            deepfake_video_urls: [
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_1_ouhhqp.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294447/Grandma_part_5_vva1zv.mp4"
            ]
        )
        
        EnhancedAvatarCard(avatar: sampleFirestoreAvatar)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.white)
    }
}
