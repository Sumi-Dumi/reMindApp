//
//  EnhancedAvatarCard.swift
//  reMind_appleDarts
//
//  Created by user on 2025/06/03.
//

import SwiftUI

// Enhanced AvatarCard with edit and delete buttons
struct EnhancedAvatarCard: View {
    let avatar: Avatar
    let firestoreAvatar: FirestoreAvatar? // Firebase データを追加
    let onStartSession: () -> Void
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    @State private var showingDeleteAlert = false
    
    private var displayName: String {
        if let firestoreAvatar = firestoreAvatar {
            return firestoreAvatar.recipient_name
        }
        return avatar.name
    }
    
    init(
        avatar: Avatar,
        firestoreAvatar: FirestoreAvatar? = nil, // 
        onStartSession: @escaping () -> Void,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.avatar = avatar
        self.firestoreAvatar = firestoreAvatar
        self.onStartSession = onStartSession
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(avatar.isDefault ? Color(red: 184/255, green: 192/255, blue: 204/255) : Color.gray.opacity(0.5),
                            lineWidth: avatar.isDefault ? 1 : 1)
            )
            .frame(width: 380, height: 120)
            .overlay(
                HStack (spacing: 8){
                    // Image
                    Image(avatar.profileImg)
                        .resizable()
                        .frame(width: 68, height: 72)
                        .clipShape(Circle())
                    
                    // Text content
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(displayName) // 
                                .font(.headline)
                                .foregroundColor(.primaryText)
                            
                            if avatar.isDefault {
                                Text("Default")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(red: 52/255, green: 211/255, blue: 153/255))
                                    .cornerRadius(150)
                            }
                        }
                        
                        Text(avatar.displayDescription)
                            .font(
                                Font.custom("SF Pro", size: 10)
                                    .weight(.medium)
                            )
                            .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        NavigationLink(destination: SessionView()) {
                            HStack(alignment: .center, spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.black)
                                   
                                Text("Start session")
                                    .font(
                                        Font.custom("SF Pro", size: 10)
                                            .weight(.bold)
                                    )
                                .foregroundColor(.black)}
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.primaryGreen)
                            .cornerRadius(4)
                        }
                    }
                }
                    .padding(.horizontal, 12)
            )
    }
}

// Add this at the bottom of your EnhancedAvatarCard.swift file
struct EnhancedAvatarCard_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample avatar
        let sampleAvatar = Avatar(
            id: 1,
            name: "Sumi",
            isDefault: true,
            language: "English",
            theme: "Calm",
            voiceTone: "Ghibli",
            profileImg: "sample_avatar",  // Make sure this image exists in your assets
            deepfakeReady: true
        )
        
        // Create a preview with the sample avatar
        EnhancedAvatarCard(
            avatar: sampleAvatar,
            onStartSession: {
                print("Start session tapped")
            },
            onEdit: {
                print("Edit tapped")
            },
            onDelete: {
                print("Delete tapped")
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.white) // Add background to see the card clearly
    }
}
