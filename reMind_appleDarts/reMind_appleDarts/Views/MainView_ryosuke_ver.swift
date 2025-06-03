//
//  MainView_ryosuke_ver.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 3/6/2025.
//


import SwiftUI


struct MainView_ryosuke_ver: View {
    @EnvironmentObject var viewModel: EnhancedMainViewModel
    @State private var showingCreateAvatar = false
    @State private var showingAvatarList = false
    @State private var editingAvatar: Avatar?
    
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
                            // Add avatar button - NavigationLink
                            NavigationLink(destination: CreateAvatarView().environmentObject(viewModel)) {
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
                                    EnhancedAvatarCard(
                                        avatar: avatar,
                                        onStartSession: {
                                            print("\(avatar.name) session started!")
                                        },
                                        onEdit: {
                                            editingAvatar = avatar
                                        }
                                    )
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
                                    
                                    // Create Avatar CTA Button
                                    NavigationLink(destination: CreateAvatarView().environmentObject(viewModel)) {
                                        Text("Create Your First Avatar")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(Color.primaryGreen)
                                            .cornerRadius(12)
                                    }
                                    .padding(.horizontal, 40)
                                }
                                .padding(.vertical, 40)
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
        .sheet(item: $editingAvatar) { avatar in
            EditAvatarView(avatar: avatar)
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

// Enhanced AvatarCard with edit button (keeping original style)
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
        ZStack{
            // border rectangle
            Rectangle()
                .fill(Color.white)
                .opacity(0.1)
                .frame(width: 380, height: 120)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .opacity(0.5)
                )
            
            HStack{
                // image
                Image(avatar.profileImg)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(100)
                
                // text
                VStack(alignment: .leading){
                    HStack{
                        Text(avatar.name)
                            .font(.headline)
                        
                        if avatar.isDefault {
                            ZStack{
                                Rectangle()
                                    .foregroundColor(Color(red: 211 / 255, green: 246 / 255, blue: 242 / 255))
                                    .frame(width: 60, height: 30)
                                    .cornerRadius(10)
                                Text("default")
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    Text("\(avatar.language) / \(avatar.voiceTone)")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    // start session button
                    NavigationLink(destination: SessionView()) {
                        ZStack{
                            Rectangle()
                                .foregroundColor(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                                .frame(width: 90, height: 40)
                                .cornerRadius(10)
                            Text("start session")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // edit button
                    Button(action: {
                        onEdit?()
                    }) {
                        ZStack{
                            Rectangle()
                                .foregroundColor(Color.blue.opacity(0.1))
                                .frame(width: 90, height: 30)
                                .cornerRadius(8)
                            Text("edit")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}


#Preview {
    MainView_ryosuke_ver()
        .environmentObject(EnhancedMainViewModel())
}
