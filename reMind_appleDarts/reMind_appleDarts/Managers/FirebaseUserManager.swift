import Foundation
import FirebaseFirestore
import Combine

class FirebaseUserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let userCollectionPath = "users"
    

    @Published var currentUserId: String? {
        didSet {
            if let userId = currentUserId {
                UserDefaults.standard.set(userId, forKey: "currentUserId")
                print("💾 Saved currentUserId to UserDefaults: \(userId)")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUserId")
                print("🗑️ Removed currentUserId from UserDefaults")
            }
        }
    }
    
    init() {
        self.currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
        if let savedUserId = currentUserId {
            print("🔄 Found saved user ID: \(savedUserId)")
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - User Authentication & Management
    
    func saveUser(_ user: User) {
        isLoading = true
        errorMessage = ""
        
        let firebaseUser = FirebaseUser.fromLocalUser(user)
        
        do {
            try db.collection(userCollectionPath)
                .document(firebaseUser.id)
                .setData(from: firebaseUser) { [weak self] error in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        if let error = error {
                            self?.errorMessage = "Firebase user save error: \(error.localizedDescription)"
                            print("❌ Firebase user save error: \(error)")
                        } else {
                            print("✅ User saved to Firebase: \(firebaseUser.id)")
                            self?.currentUser = user
                            self?.currentUserId = firebaseUser.id
                        }
                    }
                }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    func loginUser(userId: String) {
        loadUserFromFirebase(userId: userId)
    }
    
    private func loadUserFromFirebase(userId: String) {
        isLoading = true
        
        listener?.remove()
        listener = db.collection(userCollectionPath)
            .document(userId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Firebase user load error: \(error.localizedDescription)"
                        print("❌ Firebase user load error: \(error)")
                        return
                    }
                    
                    guard let document = documentSnapshot,
                          document.exists else {
                        print("⚠️ User document not found: \(userId)")
                        self?.clearUser()
                        return
                    }
                    
                    do {
                        let firebaseUser = try document.data(as: FirebaseUser.self)
                        self?.currentUser = firebaseUser.toLocalUser()
                        self?.currentUserId = userId
                        print("✅ User loaded from Firebase: \(firebaseUser.name)")
                        print("🖼️ Profile image URL: \(firebaseUser.profileImageURL)")
                    } catch {
                        self?.errorMessage = "User parsing error \(error.localizedDescription)"
                        print("❌ User parsing error: \(error)")
                    }
                }
            }
    }
    
    func updateUser(_ updatedUser: User) {
        print("🔄 updateUser called")
        print("  - currentUserId: \(currentUserId ?? "nil")")
        print("  - updatedUser.name: '\(updatedUser.name)'")
        print("  - updatedUser.profileImageURL: '\(updatedUser.profileImageURL)'")
        
        guard let currentUserId = currentUserId else {
            errorMessage = "currentUserId is nil - cannot update user"
            print("❌ currentUserId is nil - cannot update user")
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        let updateData: [String: Any] = [
            "name": updatedUser.name,
            "email": updatedUser.email,
            "profileImageURL": updatedUser.profileImageURL,
            "updated_at": Timestamp(date: Date())
        ]
        
        print("🔄 Updating Firebase document: \(currentUserId)")
        print("🔄 Update data: \(updateData)")
        
        db.collection(userCollectionPath)
            .document(currentUserId)
            .updateData(updateData) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Firebase user update error: \(error.localizedDescription)"
                        print("❌ Firebase user update error: \(error)")
                    } else {
                        print("✅ User updated in Firebase successfully")
                        print("🖼️ New profile image URL: '\(updatedUser.profileImageURL)'")
                        self?.currentUser = updatedUser
                        self?.errorMessage = "" // Clear any previous errors
                    }
                }
            }
    }
    
    func clearUser() {
        listener?.remove()
        currentUser = nil
        currentUserId = nil
        print("🗑️ User data cleared")
    }
    
    // MARK: - 🆕 Auto Login Methods
    
    func checkAutoLogin() {
        guard let savedUserId = currentUserId else {
            print("⚠️ No saved user ID found")
            return
        }
        
        print("🔄 Attempting auto login for user: \(savedUserId)")
        loadUserFromFirebase(userId: savedUserId)
    }
    
    func hasValidSession() -> Bool {
        return currentUserId != nil
    }
    
    // MARK: - Helper Methods
    
    func createDummyUser() -> User {
        let dummyUser = User(
            id: Int.random(in: 1000...9999),
            name: "User",
            email: "user@example.com",
            password: "",
            profileImageURL: "https://res.cloudinary.com/dvyjkf3xq/image/upload/v1749361609/initial_profile_zfoxw0.png",
            avatars: []
        )
        saveUser(dummyUser)
        return dummyUser
    }
    
    func loadUser() -> User? {
        return currentUser
    }
    
    func getUserById(_ userId: String, completion: @escaping (User?) -> Void) {
        print("🔍 Getting user by ID: \(userId)")
        
        db.collection(userCollectionPath)
            .document(userId)
            .getDocument { [weak self] documentSnapshot, error in
                if let error = error {
                    print("❌ Get user by ID error: \(error)")
                    completion(nil)
                    return
                }
                
                guard let document = documentSnapshot,
                      document.exists else {
                    print("⚠️ User document not found: \(userId)")
                    completion(nil)
                    return
                }
                
                do {
                    let firebaseUser = try document.data(as: FirebaseUser.self)
                    let localUser = firebaseUser.toLocalUser()
                    
    
                    DispatchQueue.main.async {
                        self?.currentUserId = userId
                        print("✅ Set currentUserId to: \(userId)")
                    }
                    
                    print("✅ User found: \(localUser.name)")
                    print("🖼️ ProfileImageURL: '\(localUser.profileImageURL)'")
                    completion(localUser)
                } catch {
                    print("❌ User parsing error: \(error)")
                    completion(nil)
                }
            }
    }
    
    func loadAndSetCurrentUser(userId: String, completion: @escaping (User?) -> Void) {
        getUserById(userId) { [weak self] user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = user
                    self?.currentUserId = userId
                    print("✅ Current user set: \(user.name) (ID: \(userId))")
                }
                completion(user)
            }
        }
    }
    
    func clearError() {
        errorMessage = ""
    }
    
    var isLoggedIn: Bool {
        return currentUser != nil && currentUserId != nil
    }
}
