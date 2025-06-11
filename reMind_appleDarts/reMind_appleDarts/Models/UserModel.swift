import Foundation
import FirebaseFirestore
import SwiftUI

struct Avatar: Codable, Identifiable {
    @DocumentID var documentID: String?
    var id: String

    var name: String
    var isDefault: Bool
    var language: String
    var theme: String
    var voiceTone: String
    var profileImg: String
    var deepfakeReady: Bool
    
    var recipient_name: String
    var creator_name: String
    var image_urls: [String]
    var audio_url: String
    var image_count: Int
    var audio_size_mb: String
    var storage_provider: String
    var status: String
    var created_at: Timestamp?
    var updated_at: Timestamp?
    var deepfake_video_urls: [String]
    var deep_fake_video_url_ghibli: [String]
    
    init(
        id: String = UUID().uuidString,
        name: String,
        isDefault: Bool = false,
        language: String = "English",
        theme: String = "Calm",
        voiceTone: String = "Gentle",
        profileImg: String = "sample_avatar",
        deepfakeReady: Bool = false,
        recipient_name: String,
        creator_name: String,
        image_urls: [String] = [],
        audio_url: String = "",
        image_count: Int = 0,
        audio_size_mb: String = "0",
        storage_provider: String = "cloudinary",
        status: String = "not_ready",
        created_at: Timestamp? = nil,
        updated_at: Timestamp? = nil,
        deepfake_video_urls: [String] = [],
        deep_fake_video_url_ghibli: [String] = []
    ) {
        self.id = id
        self.name = name
        self.isDefault = isDefault
        self.language = language
        self.theme = theme
        self.voiceTone = voiceTone
        self.profileImg = profileImg
        self.deepfakeReady = deepfakeReady
        self.recipient_name = recipient_name
        self.creator_name = creator_name
        self.image_urls = image_urls
        self.audio_url = audio_url
        self.image_count = image_count
        self.audio_size_mb = audio_size_mb
        self.storage_provider = storage_provider
        self.status = status
        self.created_at = created_at
        self.updated_at = updated_at
        self.deepfake_video_urls = deepfake_video_urls
        self.deep_fake_video_url_ghibli = deep_fake_video_url_ghibli
    }
}

extension Avatar {
    var displayDescription: String {
        return "\(language) / \(theme)"
    }
    
    var tagText: String {
        return isDefault ? "default" : ""
    }
    
    var tagColor: Color {
        return isDefault ? Color(red: 211/255, green: 246/255, blue: 242/255) : Color.clear
    }
    
    var formattedCreatedAt: String {
        guard let timestamp = created_at else { return "Unknown" }
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var hasImages: Bool {
        return !image_urls.isEmpty
    }
    
    var hasAudio: Bool {
        return !audio_url.isEmpty
    }
    
    var isReady: Bool {
        return status == "ready" && deepfakeReady
    }
}



struct User: Codable {
    var id: Int
    var name: String
    var email: String
    var password: String
    var profileImageURL: String
    var avatars: [Avatar]
}

extension User {
    var defaultAvatar: Avatar? {
        avatars.first(where: { $0.isDefault })
    }
    
    var displayName: String {
        return name.isEmpty ? "User" : name
    }
    
    var displayProfileImageURL: String {
        if !profileImageURL.isEmpty {
            return profileImageURL
        }
        return "https://res.cloudinary.com/dvyjkf3xq/image/upload/v1749361609/initial_profile_zfoxw0.png"
    }
    

    var hasValidProfileImage: Bool {
        return !profileImageURL.isEmpty && isValidURL(profileImageURL)
    }
    
    private func isValidURL(_ string: String) -> Bool {
        return string.hasPrefix("http://") || string.hasPrefix("https://")
    }
}

struct FirebaseUser: Codable, Identifiable {
    @DocumentID var documentID: String?
    var id: String
    var name: String
    var email: String
    var password: String
    var profileImageURL: String
    var created_at: Timestamp?
    var updated_at: Timestamp?
    
    func toLocalUser() -> User {
        return User(
            id: abs(id.hashValue),
            name: name,
            email: email,
            password: password,
            profileImageURL: profileImageURL,
            avatars: []
        )
    }
    
    static func fromLocalUser(_ user: User) -> FirebaseUser {
        return FirebaseUser(
            id: "user_\(user.id)",
            name: user.name,
            email: user.email,
            password: user.password,
            profileImageURL: user.profileImageURL,
            created_at: Timestamp(date: Date()),
            updated_at: Timestamp(date: Date())
        )
    }
}
