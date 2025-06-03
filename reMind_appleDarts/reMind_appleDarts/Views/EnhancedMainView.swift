//
//  EnhancedMainView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 3/6/2025.
//
import SwiftUI

struct EnhancedMainView: View {
    @EnvironmentObject var viewModel: EnhancedMainViewModel
    @State private var showingCreateAvatar = false
    @State private var showingAvatarList = false
    
    var body: some View {
        ZStack{
            // Background
            BackGroundView()
            
            NavigationView {
                VStack(spacing: 15){
                    // User card with dynamic data
                    UserCard(
                        welcomeText: "Welcome \(viewModel.currentUser?.displayName ?? "User")!",
                        descriptionText: viewModel.hasAvatars ?
                            "You have \(viewModel.avatarCount) support companion\(viewModel.avatarCount == 1 ? "" : "s")" :
                            "Feel grounded with your loved one",
                        avatarImageName: viewModel.defaultAvatar?.profileImg ?? viewModel.currentUser?.profileImg ?? "sample_avatar"
                    )
                    
                    // Add button and heading of List
                    HStack {
                        Text("Your support circle")
                            .font(.headline)
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Manage avatars button
                            if viewModel.hasAvatars {
                                Button(action: {
                                    showingAvatarList = true
                                }) {
                                    Text("Manage")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            // Add avatar button
                            Button(action: {
                                showingCreateAvatar = true
                            }) {
                                Text("Add more +")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    
                    // List for supporter
                    ScrollView {
                        VStack(spacing: 12) {
                            if viewModel.hasAvatars {
                                // Display actual user avatars
                                ForEach(Array(viewModel.userAvatars.enumerated()), id: \.element.id) { index, avatar in
                                    AvatarCard(
                                        avatarImageName: avatar.profileImg,
                                        name: avatar.name,
                                        tagText: avatar.isDefault ? "default" : "",
                                        tagColor: avatar.isDefault ?
                                            Color(red: 211 / 255, green: 246 / 255, blue: 242 / 255) :
                                            Color.clear,
                                        description: "\(avatar.language) / \(avatar.voiceTone)",
                                        isDefault: avatar.isDefault
                                    ) {
                                        print("\(avatar.name) session started!")
                                        // Here you can navigate to SessionView with specific avatar
                                    }
                                }
                                
                                // Add more avatars prompt if less than 5
                                if viewModel.avatarCount < 5 {
                                    Button(action: {
                                        showingCreateAvatar = true
                                    }) {
                                        HStack {
                                            Image(systemName: "plus.circle.dashed")
                                                .font(.title2)
                                                .foregroundColor(.gray)
                                            
                                            VStack(alignment: .leading) {
                                                Text("Add another companion")
                                                    .font(.headline)
                                                    .foregroundColor(.primaryText)
                                                
                                                Text("Create up to 5 support avatars")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.6))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .padding(.horizontal, 20)
                                }
                                
                            } else {
                                // Empty state with call to action
                                VStack(spacing: 20) {
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray.opacity(0.6))
                                    
                                    VStack(spacing: 8) {
                                        Text("No Support Companions Yet")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primaryText)
                                        
                                        Text("Create your first avatar to begin your personalized support journey")
                                            .font(.subheadline)
                                            .foregroundColor(.secondaryText)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 20)
                                    }
                                    
                                    Button(action: {
                                        showingCreateAvatar = true
                                    }) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Create Your First Avatar")
                                        }
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.primaryGreen)
                                        .cornerRadius(12)
                                    }
                                    .padding(.horizontal, 40)
                                    
                                    // Demo button for testing
                                    Button(action: {
                                        viewModel.createDemoAvatars()
                                    }) {
                                        Text("Load Demo Avatars")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .underline()
                                    }
                                    .padding(.top, 10)
                                }
                                .padding(.top, 40)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingCreateAvatar) {
            CreateAvatarView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingAvatarList) {
            AvatarListView()
                .environmentObject(viewModel)
        }
        .onAppear {
            // Ensure user exists when view appears
            if viewModel.currentUser == nil {
                viewModel.createDummyUser()
            }
        }
    }
}

// Enhanced UserCard that works better with dynamic data
struct EnhancedUserCard: View {
    let welcomeText: String
    let descriptionText: String
    let avatarImageName: String
    let onAvatarTap: (() -> Void)?
    
    init(
        welcomeText: String = "Welcome, User!",
        descriptionText: String = "Feel grounded with your loved one",
        avatarImageName: String = "sample_avatar",
        onAvatarTap: (() -> Void)? = nil
    ) {
        self.welcomeText = welcomeText
        self.descriptionText = descriptionText
        self.avatarImageName = avatarImageName
        self.onAvatarTap = onAvatarTap
    }
    
    var body: some View {
        HStack{
            Button(action: {
                onAvatarTap?()
            }) {
                Image(avatarImageName)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(50)
                    .overlay(
                        Circle()
                            .stroke(Color.primaryGreen.opacity(0.3), lineWidth: 2)
                    )
                    .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4){
                Text(welcomeText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text(descriptionText)
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

// Enhanced AvatarCard with better visual feedback
struct EnhancedAvatarCard: View {
    let avatar: Avatar
    let onStartSession: () -> Void
    let onEdit: (() -> Void)?
    
    init(avatar: Avatar, onStartSession: @escaping () -> Void, onEdit: (() -> Void)? = nil) {
        self.avatar = avatar
        self.onStartSession = onStartSession
        self.onEdit = onEdit
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar Image with status indicator
            ZStack {
                Image(avatar.profileImg)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(40)
                    .overlay(
                        Circle()
                            .stroke(avatar.isDefault ? Color.primaryGreen : Color.gray.opacity(0.3), lineWidth: 3)
                    )
                
                // Status indicator
                if avatar.deepfakeReady {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 25, y: 25)
                } else {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 25, y: 25)
                }
            }
            
            // Avatar Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(avatar.name)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    if avatar.isDefault {
                        Text("DEFAULT")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.primaryGreen)
                            .foregroundColor(.black)
                            .cornerRadius(4)
                    }
                }
                
                Text("\(avatar.language) • \(avatar.theme)")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                
                Text("Voice: \(avatar.voiceTone)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Action Button
            NavigationLink(destination: SessionView()) {
                Text("Start")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .frame(width: 70, height: 36)
                    .background(Color.primaryGreen)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    EnhancedMainView()
        .environmentObject(EnhancedMainViewModel())
}
