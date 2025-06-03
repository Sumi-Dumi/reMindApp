import Foundation

struct Avatar: Codable, Identifiable {
    var id: Int
    var name: String
    var isDefault: Bool
    var language: String
    var theme: String
    var voiceTone: String
    var profileImg: String
    var deepfakeReady: Bool
}

struct User: Codable {
    var id: Int
    var name: String
    var email: String
    var password: String
    var profileImg: String
    var avatars: [Avatar]
}

extension User {
    var defaultAvatar: Avatar? {
        avatars.first(where: { $0.isDefault })
    }
}
