import Foundation

class MainViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false

    func login(with user: User) {
        self.currentUser = user
        self.isLoggedIn = true
    }

    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
    }
}
