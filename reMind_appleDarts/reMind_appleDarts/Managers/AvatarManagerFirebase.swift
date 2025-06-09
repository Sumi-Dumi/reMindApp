import Foundation
import FirebaseFirestore
import Combine

class FirebaseAvatarManager: ObservableObject {
    @Published var avatars: [Avatar] = []
    @Published var firestoreAvatars: [Avatar] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchAvatars()
    }
    
    deinit {
        listener?.remove()
    }
    

    func fetchAvatars() {
        isLoading = true
        errorMessage = ""
        
        listener?.remove()
        
        listener = db.collection("avatars")
            .order(by: "created_at", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Firebase fetch error: \(error.localizedDescription)"
                        print("❌ Firebase fetch error: \(error)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "Firebase fetch error"
                        return
                    }
                    
                    let avatars = documents.compactMap { document -> Avatar? in
                        do {
                            return try document.data(as: Avatar.self)
                        } catch {
                            print("❌ Document parsing error: \(error)")
                            return nil
                        }
                    }
                    
                    self?.firestoreAvatars = avatars
                    self?.avatars = avatars
                    
                    print("✅ From Firebase get \(self?.avatars.count ?? 0) avatars")
                }
            }
    }
    

    func saveAvatar(_ avatar: Avatar) {
        var avatarToSave = avatar
        if avatarToSave.created_at == nil {
            avatarToSave.created_at = Timestamp(date: Date())
        }
        avatarToSave.updated_at = Timestamp(date: Date())
        
        do {
            if let documentID = avatar.documentID {
                try db.collection("avatars").document(documentID).setData(from: avatarToSave)
            } else {
                try db.collection("avatars").addDocument(from: avatarToSave)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "fail to save: \(error.localizedDescription)"
            }
        }
    }
    
    func deleteAvatar(_ avatar: Avatar) {
        guard let documentID = avatar.documentID else {
            errorMessage = "cannot find documentID"
            return
        }
        
        db.collection("avatars").document(documentID).delete { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "fail to delete: \(error.localizedDescription)"
                } else {
                    print("comlete delete avatar")
                }
            }
        }
    }
    
    func refresh() {
        fetchAvatars()
    }
    
    func clearError() {
        errorMessage = ""
    }
}
