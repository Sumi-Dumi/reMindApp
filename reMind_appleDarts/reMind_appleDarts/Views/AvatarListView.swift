//
//  AvatarListView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 3/6/2025.
//

import SwiftUI

struct AvatarListView: View {
    @EnvironmentObject var viewModel: EnhancedMainViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingCreateAvatar = false
    @State private var showingEditAvatar = false
    @State private var selectedAvatar: Avatar?
    @State private var showingDeleteAlert = false
    @State private var avatarToDelete: Avatar?
    @State private var searchText = ""
    @State private var selectedLanguageFilter = "All"
    @State private var selectedThemeFilter = "All"
    
    private let languageFilters = ["All", "English", "Japanese", "Spanish", "French", "German", "Italian"]
    private let themeFilters = ["All", "Calm", "Energetic", "Peaceful", "Motivational", "Relaxing", "Cheerful"]
    
    var filteredAvatars: [Avatar] {
        var avatars = viewModel.userAvatars
        
        // Apply search filter
        if !searchText.isEmpty {
            avatars = avatars.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.language.localizedCaseInsensitiveContains(searchText) ||
                $0.theme.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply language filter
        if selectedLanguageFilter != "All" {
            avatars = avatars.filter { $0.language == selectedLanguageFilter }
        }
        
        // Apply theme filter
        if selectedThemeFilter != "All" {
            avatars = avatars.filter { $0.theme == selectedThemeFilter }
        }
        
        // Sort: default first, then by name
        return avatars.sorted { first, second in
            if first.isDefault && !second.isDefault {
                return true
            } else if !first.isDefault && second.isDefault {
                return false
            } else {
                return first.name < second.name
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                BackGroundView()
                
                VStack(spacing: 0) {
                    // Custom Header
                    customHeader
                    
                    // Search and Filters
                    if viewModel.hasAvatars {
                        searchAndFiltersSection
                    }
                    
                    // Content
                    if viewModel.userAvatars.isEmpty {
                        emptyStateView
                    } else {
                        avatarListView
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCreateAvatar) {
            CreateAvatarView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingEditAvatar) {
            if let avatar = selectedAvatar {
                EditAvatarView(avatar: avatar)
                    .environmentObject(viewModel)
            }
        }
        .alert("Delete Avatar", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let avatar = avatarToDelete {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.deleteAvatar(withId: avatar.id)
                    }
                }
            }
        } message: {
            if let avatar = avatarToDelete {
                Text("Are you sure you want to delete '\(avatar.name)'? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Custom Header
    private var customHeader: some View {
        HStack {
            // Back Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("Back")
                        .font(.headline)
                }
                .foregroundColor(.primaryText)
            }
            
            Spacer()
            
            // Title with count
            VStack(spacing: 2) {
                Text("My Avatars")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                if viewModel.hasAvatars {
                    Text("\(filteredAvatars.count) of \(viewModel.avatarCount)")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            // Add Button
            Button(action: {
                showingCreateAvatar = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.primaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    // MARK: - Search and Filters
    private var searchAndFiltersSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search avatars...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            // Filter Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Language Filter
                    Menu {
                        ForEach(languageFilters, id: \.self) { language in
                            Button(action: {
                                selectedLanguageFilter = language
                            }) {
                                HStack {
                                    Text(language)
                                    if selectedLanguageFilter == language {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.caption)
                            Text(selectedLanguageFilter)
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedLanguageFilter != "All" ? Color.primaryGreen : Color.white.opacity(0.8))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Theme Filter
                    Menu {
                        ForEach(themeFilters, id: \.self) { theme in
                            Button(action: {
                                selectedThemeFilter = theme
                            }) {
                                HStack {
                                    Text(theme)
                                    if selectedThemeFilter == theme {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "paintpalette")
                                .font(.caption)
                            Text(selectedThemeFilter)
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedThemeFilter != "All" ? Color.primaryGreen : Color.white.opacity(0.8))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Clear Filters
                    if selectedLanguageFilter != "All" || selectedThemeFilter != "All" || !searchText.isEmpty {
                        Button(action: {
                            selectedLanguageFilter = "All"
                            selectedThemeFilter = "All"
                            searchText = ""
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                Text("Clear")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.3.fill")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Avatars Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text("Create your first avatar to get started with personalized support")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showingCreateAvatar = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Create Your First Avatar")
                        .font(.headline)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primaryGreen)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            // Demo button
            Button(action: {
                viewModel.createDemoAvatars()
            }) {
                Text("Load Demo Avatars")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .underline()
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    // MARK: - Avatar List
    private var avatarListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredAvatars.isEmpty {
                    // No results state
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No avatars match your search")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                        
                        Button(action: {
                            selectedLanguageFilter = "All"
                            selectedThemeFilter = "All"
                            searchText = ""
                        }) {
                            Text("Clear All Filters")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(filteredAvatars) { avatar in
                        EnhancedAvatarManagementCard(
                            avatar: avatar,
                            onEdit: {
                                selectedAvatar = avatar
                                showingEditAvatar = true
                            },
                            onDelete: {
                                avatarToDelete = avatar
                                showingDeleteAlert = true
                            },
                            onSetDefault: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.setDefaultAvatar(withId: avatar.id)
                                }
                            },
                            onStartSession: {
                                print("\(avatar.name) session started from list!")
                                // Here you can navigate to SessionView
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Enhanced Avatar Management Card
struct EnhancedAvatarManagementCard: View {
    let avatar: Avatar
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetDefault: () -> Void
    let onStartSession: () -> Void
    
    @State private var showingActionSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar Image with status
            ZStack {
                Image(avatar.profileImg)
                    .resizable()
                    .frame(width: 70, height: 70)
                    .cornerRadius(35)
                    .overlay(
                        Circle()
                            .stroke(avatar.isDefault ? Color.primaryGreen : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                
                // Status indicator
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: avatar.deepfakeReady ? "checkmark.circle.fill" : "clock.fill")
                            .font(.caption)
                            .foregroundColor(avatar.deepfakeReady ? .green : .orange)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .frame(width: 70, height: 70)
            }
            
            // Avatar Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(avatar.name)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    
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
                    
                    Spacer()
                }
                
                Text("\(avatar.language) • \(avatar.theme)")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                
                Text("Voice: \(avatar.voiceTone)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: avatar.deepfakeReady ? "checkmark.circle.fill" : "clock.fill")
                        .font(.caption2)
                        .foregroundColor(avatar.deepfakeReady ? .green : .orange)
                    
                    Text(avatar.deepfakeReady ? "Ready" : "Processing")
                        .font(.caption2)
                        .foregroundColor(avatar.deepfakeReady ? .green : .orange)
                }
            }
            
            // Action Buttons
            VStack(spacing: 8) {
                // Start Session Button
                Button(action: onStartSession) {
                    Text("Start")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 60, height: 28)
                        .background(Color.primaryGreen)
                        .cornerRadius(6)
                }
                
                // Menu Button
                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    if !avatar.isDefault {
                        Button(action: onSetDefault) {
                            Label("Set as Default", systemImage: "star")
                        }
                    }
                    
                    Divider()
                    
                    Button(action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 28)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(avatar.isDefault ? Color.primaryGreen.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AvatarListView()
        .environmentObject(EnhancedMainViewModel())
}
