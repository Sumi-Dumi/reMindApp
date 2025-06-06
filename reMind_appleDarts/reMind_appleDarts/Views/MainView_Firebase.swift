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
        NavigationView {
        ZStack{
            // Background
            BackGroundView()
            

                VStack(spacing: 15){
                    // User card with dynamic data
                    UserCard(
                        welcomeText: "Welcome \(appViewModel.userDisplayName)!",
                        descriptionText: avatarCountDescription,
                        avatarImageName: appViewModel.userProfileImage
                    )
                    
                    Spacer()
                    
                    // Add button and heading of List
                    HStack {
                        Text("Your support circle")
                            .font(.headline)
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Add avatar button
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
                    .padding(.horizontal, 16)
                    .padding(.bottom, 0)
                    
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
                            ForEach(firebaseAvatarManager.firestoreAvatars, id: \.id) { firestoreAvatar in
                                if firestoreAvatar.status == "ready" {
                                    // if Ready
                                    EnhancedAvatarCard(
                                        avatar: firestoreAvatar.toLocalAvatar(),
                                        firestoreAvatar: firestoreAvatar,
                                        onStartSession: {
                                            print("Firebase \(firestoreAvatar.recipient_name) session started!")
                                        }
                                    )
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .slide),
                                        removal: .opacity.combined(with: .scale(scale: 0.8))
                                    ))

                                } else {
                                    // else PendingCard
                                    PendingCard(avatarName: firestoreAvatar.recipient_name)
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .slide),
                                            removal: .opacity.combined(with: .scale(scale: 0.8))
                                        ))
                                }
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

#Preview {
    MainView_Firebase()
        .environmentObject(AppViewModel())
}
