import Foundation

class MainViewModel: ObservableObject {
    @Published var currentUser: User? = nil

    var isLoggedIn: Bool {
        currentUser != nil
    }

    init() {
        currentUser = UserManager.shared.loadUser()
    }

    func login(with user: User) {
        currentUser = user
        UserManager.shared.saveUser(user)
    }

    func logout() {
        currentUser = nil
        UserManager.shared.clearUser()
    }
}
