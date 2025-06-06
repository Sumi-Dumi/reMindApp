import SwiftUI

struct MainView_ryosuke_ver: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var editingAvatar: Avatar?
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        ZStack{
            // Background
            BackGroundView()
            
            NavigationView {
                VStack(spacing: 15){
                    // User card with dynamic data
                    UserCard(
                        welcomeText: "Welcome \(appViewModel.userDisplayName)!",
                        descriptionText: appViewModel.avatarCountDescription,
                        avatarImageName: appViewModel.userProfileImage
                    )
                    
                    // Add button and heading of List
                    HStack {
                        Text("Your support circle")
                            .font(.headline)
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Add avatar button - NavigationLink
                            NavigationLink(destination: RequestConsentView()
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
                        }
                    }
                    .padding()
                    
                    // List for supporter
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if appViewModel.hasAvatars {
                                ForEach(getCurrentAvatars(), id: \.id) { avatar in
                                    EnhancedAvatarCard(
                                        avatar: avatar,
                                        onStartSession: {
                                            print("\(avatar.name) session started!")
                                        },
                                        onEdit: {
                                            editingAvatar = avatar
                                        },
                                        onDelete: {
                                            deleteAvatarWithRefresh(avatar.id)
                                        }
                                    )
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .slide),
                                        removal: .opacity.combined(with: .scale(scale: 0.8))
                                    ))
                                }
                                
                            } else {
                                // Empty state with call to action
                                EmptyAvatarStateView()
                            }
                        }
                    }
                    .id(refreshTrigger) // ✅
                    
                    Spacer()
                }
            }
        }
        .sheet(item: $editingAvatar) { avatar in
            EditAvatarView(avatar: avatar)
                .environmentObject(appViewModel)
                .onDisappear {
                    refreshView()
                }
        }
        .onAppear {
            // Initialize app when view appears
            appViewModel.initializeApp()
            refreshView()
        }
        .onReceive(appViewModel.avatarManager.$avatars) { _ in
            print("🔄 Avatar list changed, refreshing view...")
            refreshView()
        }
    }
    
    private func getCurrentAvatars() -> [Avatar] {
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
    
    private func deleteAvatarWithRefresh(_ avatarId: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            appViewModel.avatarManager.deleteAvatar(withId: avatarId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                refreshView()
            }
        }
    }
}

#Preview {
    MainView_ryosuke_ver()
        .environmentObject(AppViewModel())
}
