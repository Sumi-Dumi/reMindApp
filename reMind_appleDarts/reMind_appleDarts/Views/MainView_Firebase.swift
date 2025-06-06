//
//  MainView_firebase.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 6/6/2025.
//



import SwiftUI

struct MainView_Firebase: View {
    @StateObject private var firebaseAvatarManager = FirebaseAvatarManager()
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var refreshTrigger = UUID()
    @State private var showingCreateView = false
    
    var body: some View {
        ZStack{
            // Background
            BackGroundView()
            
            NavigationView {
                VStack(spacing: 15){
                    // User card with dynamic data
                    UserCard(
                        welcomeText: "Welcome \(appViewModel.userDisplayName)!",
                        descriptionText: avatarCountDescription,
                        avatarImageName: appViewModel.userProfileImage
                    )
                    
                    // Add button and heading of List
                    HStack {
                        Text("Your support circle")
                            .font(.headline)
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Add avatar button (既存のローカル作成)
                            NavigationLink(destination: CreateAvatarView()
                                .environmentObject(appViewModel)
                                .onDisappear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        refreshView()
                                    }
                                }
                            ) {
                                Text("Add more +")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            // Refresh button
                            Button(action: {
                                firebaseAvatarManager.refresh()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    
                    // Error message
                    if !firebaseAvatarManager.errorMessage.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text(firebaseAvatarManager.errorMessage)
                                .font(.caption)
                                .foregroundColor(.orange)
                            Button("Dismiss") {
                                firebaseAvatarManager.clearError()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Loading indicator
                    if firebaseAvatarManager.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading avatars from Firebase...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    // List for supporter
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // ローカルアバター表示
                            ForEach(getCurrentLocalAvatars(), id: \.id) { avatar in
                                EnhancedAvatarCard(
                                    avatar: avatar,
                                    onStartSession: {
                                        print("\(avatar.name) session started!")
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .slide),
                                    removal: .opacity.combined(with: .scale(scale: 0.8))
                                ))
                            }
                            
                            // Firebaseアバター表示
                            ForEach(firebaseAvatarManager.avatars, id: \.id) { avatar in
                                FirebaseAvatarCard(
                                    avatar: avatar,
                                    firestoreAvatar: firebaseAvatarManager.firestoreAvatars.first {
                                        abs($0.id.hashValue) == avatar.id
                                    },
                                    onStartSession: {
                                        print("Firebase \(avatar.name) session started!")
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .slide),
                                    removal: .opacity.combined(with: .scale(scale: 0.8))
                                ))
                            }
                            
                            // Empty state
                            if getCurrentLocalAvatars().isEmpty &&
                               firebaseAvatarManager.avatars.isEmpty &&
                               !firebaseAvatarManager.isLoading {
                                EmptyAvatarStateView()
                                    .padding(.vertical, 40)
                            }
                        }
                    }
                    .id(refreshTrigger)
                    .refreshable {
                        firebaseAvatarManager.refresh()
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingCreateView) {
            CreateAvatarView()
                .environmentObject(appViewModel)
        }
        .onAppear {
            appViewModel.initializeApp()
            firebaseAvatarManager.refresh()
        }
        .onReceive(firebaseAvatarManager.$avatars) { _ in
            refreshView()
        }
    }
    
    private var avatarCountDescription: String {
        let localCount = getCurrentLocalAvatars().count
        let firebaseCount = firebaseAvatarManager.avatars.count
        let totalCount = localCount + firebaseCount
        
        if totalCount == 0 {
            return "No support companions yet"
        } else {
            return "You have \(totalCount) support companion\(totalCount == 1 ? "" : "s")"
        }
    }
    
    private func getCurrentLocalAvatars() -> [Avatar] {
        return appViewModel.avatarManager.avatars.sorted { first, second in
            if first.isDefault && !second.isDefault {
                return true
            } else if !first.isDefault && second.isDefault {
                return false
            } else {
                return first.name < second.name
            }
        }
    }
    
    private func refreshView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            refreshTrigger = UUID()
        }
    }
}

// Firebase用のAvatarCard（シンプル版）
struct FirebaseAvatarCard: View {
    let avatar: Avatar
    let firestoreAvatar: FirestoreAvatar?
    let onStartSession: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .frame(width: 380, height: 120)
            .overlay(
                HStack(spacing: 12) {
                    // Image - Firebaseの画像URLを使用
                    AsyncImage(url: URL(string: firestoreAvatar?.image_urls.first ?? "")) { image in
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
                    
                    // Text content
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(firestoreAvatar?.creator_name ?? avatar.name)
                                .font(.headline)
                                .foregroundColor(.primaryText)
                            
                            // Firebase indicator
                            Text("Web")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .cornerRadius(4)
                        }
                        
                        if let firestoreAvatar = firestoreAvatar {
                            Text("For: \(firestoreAvatar.recipient_name)")
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                            
                            Text("\(firestoreAvatar.status.capitalized)")
                                .font(.caption2)
                                .foregroundColor(statusColor(firestoreAvatar.status))
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        // Start session button
                        NavigationLink(destination: SessionView()) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10))
                                Text("Start")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.primaryGreen)
                            .cornerRadius(6)
                        }
                        .disabled(firestoreAvatar?.status != "ready")
                    }
                }
                .padding(.horizontal, 12)
            )
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "ready":
            return .green
        case "processing":
            return .orange
        case "error":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    MainView_Firebase()
        .environmentObject(AppViewModel())
}
