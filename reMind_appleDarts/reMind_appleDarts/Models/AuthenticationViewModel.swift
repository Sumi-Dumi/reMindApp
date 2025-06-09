import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    

    private var firebaseUserManager: FirebaseUserManager?
    private var cancellables = Set<AnyCancellable>()
    
    init() {

    }
    

    func setFirebaseUserManager(_ manager: FirebaseUserManager) {
        self.firebaseUserManager = manager
        setupUserObserver()
    }
    
    private func setupUserObserver() {
        guard let firebaseUserManager = firebaseUserManager else { return }
        
        firebaseUserManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isLoggedIn = user != nil
            }
            .store(in: &cancellables)
        
        firebaseUserManager.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.isLoading = loading
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Authentication
    
    func login(with user: User) {
        firebaseUserManager?.saveUser(user)
    }
    
    func loginWithFirebaseUser(_ firebaseUser: FirebaseUser) {
        let localUser = firebaseUser.toLocalUser()
        self.currentUser = localUser
        self.isLoggedIn = true
        
        firebaseUserManager?.currentUser = localUser
        firebaseUserManager?.currentUserId = firebaseUser.id
        
        print("✅ User logged in: \(firebaseUser.name)")
    }
    
    func logout() {
        firebaseUserManager?.clearUser()
        self.currentUser = nil
        self.isLoggedIn = false
    }
    
    func createDummyUser() {
        guard let firebaseUserManager = firebaseUserManager else { return }
        let dummyUser = firebaseUserManager.createDummyUser()
        print("✅ Dummy user created: \(dummyUser.name)")
    }
    
    // MARK: - User Profile Management
    
    func updateUserProfile(name: String? = nil, email: String? = nil, profileImageURL: String? = nil, password: String? = nil) {
        guard var user = currentUser else {
            print("❌ No current user to update")
            return
        }
        
        print("🔄 Updating user profile...")
        print("  - Current user: \(user.name)")
        print("  - FirebaseUserManager currentUserId: \(firebaseUserManager?.currentUserId ?? "nil")")
        
        if let name = name {
            user.name = name
        }
        if let email = email {
            user.email = email
        }
        if let profileImageURL = profileImageURL {
            user.profileImageURL = profileImageURL
        }
        
        firebaseUserManager?.updateUser(user)
    }
    
    // MARK: - User Data Access
    
    var userDisplayName: String {
        return currentUser?.displayName ?? "User"
    }
    
    var userProfileImageURL: String {
        return currentUser?.displayProfileImageURL ?? ""
    }
    
    var userEmail: String {
        return currentUser?.email ?? ""
    }
    
    var hasUser: Bool {
        return currentUser != nil
    }
    
    var hasValidProfileImage: Bool {
        return currentUser?.hasValidProfileImage ?? false
    }
    
    // MARK: - Error Handling
    
    var errorMessage: String {
        return firebaseUserManager?.errorMessage ?? ""
    }
    
    func clearError() {
        firebaseUserManager?.clearError()
    }
}
