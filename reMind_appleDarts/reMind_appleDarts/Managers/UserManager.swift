import Foundation

class UserManager {
    static let shared = UserManager()

    private let userKey = "currentUser"

    func saveUser(_ user: User) {
        let correctedUser = enforceSingleDefaultAvatar(user)

        if let data = try? JSONEncoder().encode(correctedUser) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    func loadUser() -> User? {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            return user
        }
        return nil
    }

    func clearUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }

    private func enforceSingleDefaultAvatar(_ user: User) -> User {
        var updatedUser = user
        let defaultAvatars = user.avatars.filter { $0.isDefault }

        if defaultAvatars.count <= 1 {
            return user
        }

        var foundOne = false
        updatedUser.avatars = user.avatars.map { avatar in
            var a = avatar
            if a.isDefault {
                if !foundOne {
                    foundOne = true
                    a.isDefault = true
                } else {
                    a.isDefault = false
                }
            }
            return a
        }

        return updatedUser
    }
}
