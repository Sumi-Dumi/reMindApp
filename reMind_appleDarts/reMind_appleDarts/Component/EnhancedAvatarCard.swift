import SwiftUI

struct EnhancedAvatarCard: View {
    let avatar: Avatar
    let onStartSession: () -> Void
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    @State private var showingDeleteAlert = false
    
    init(
        avatar: Avatar,
        onStartSession: @escaping () -> Void,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.avatar = avatar
        self.onStartSession = onStartSession
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white.opacity(0.5)) // Background
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.3), lineWidth: 0.5) // Stroke
            )
            .frame(width: 380, height: 120)
            .overlay(
                HStack(spacing: 20) { // Increased spacing between image and text
                    // Avatar image
                    Image(avatar.profileImg)
                        .resizable()
                        .frame(width: 68, height: 72)
                        .clipShape(Circle())
                    
                    // Text content
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(avatar.name)
                                .font(.system(size: 20, weight: .semibold)) // Apple standard size
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
                            .font(.system(size: 13)) // Apple standard for subtext
                            .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    
                    
                    VStack {
                        Button(action: {
                            onEdit?()
                        }) {
                            Label("Edit", systemImage: "pencil")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
//                                .background(Color.gray.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())

                        Spacer()
                    }
                    .frame(maxHeight: .infinity)

                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            )
    }
}

struct EnhancedAvatarCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleAvatar = Avatar(
            id: 1,
            name: "Sumi",
            isDefault: true,
            language: "English",
            theme: "Calm",
            voiceTone: "Ghibli",
            profileImg: "sample_avatar", // Ensure this exists in assets
            deepfakeReady: true
        )
        
        EnhancedAvatarCard(
            avatar: sampleAvatar,
            onStartSession: { print("Start session tapped") },
            onEdit: { print("Edit tapped") },
            onDelete: { print("Delete tapped") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.white)
    }
}
