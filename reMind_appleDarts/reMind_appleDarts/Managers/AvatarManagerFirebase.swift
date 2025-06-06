//
//  FirebaseAvatarManager.swift
//  reMind_appleDarts
//
//  Created by Assistant on 2025/06/06.
//

import Foundation
import FirebaseFirestore
import Combine

// Firestore用のAvatarモデル
struct FirestoreAvatar: Codable, Identifiable {
    @DocumentID var documentID: String?
    var id: String
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
    
    // ローカルAvatarモデルに変換
    func toLocalAvatar() -> Avatar {
        return Avatar(
            id: abs(id.hashValue), // idをIntに変換（正の値にする）
            name: creator_name.isEmpty ? "Unknown" : creator_name,
            isDefault: false, // Firestoreのデータにはdefault情報がないため
            language: "English", // デフォルト値
            theme: "Calm", // デフォルト値
            voiceTone: "Gentle", // デフォルト値
            profileImg: image_urls.first ?? "sample_avatar",
            deepfakeReady: status == "ready"
        )
    }
}

// Firebase Avatarマネージャー
class FirebaseAvatarManager: ObservableObject {
    @Published var avatars: [Avatar] = []
    @Published var firestoreAvatars: [FirestoreAvatar] = []
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
    
    // Firebaseからアバターを取得
    func fetchAvatars() {
        isLoading = true
        errorMessage = ""
        
        listener?.remove() // 既存のリスナーを削除
        
        listener = db.collection("avatars")
            .order(by: "created_at", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "データの取得に失敗しました: \(error.localizedDescription)"
                        print("❌ Firebase fetch error: \(error)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "データが見つかりませんでした"
                        return
                    }
                    
                    let firestoreAvatars = documents.compactMap { document -> FirestoreAvatar? in
                        do {
                            return try document.data(as: FirestoreAvatar.self)
                        } catch {
                            print("❌ Document parsing error: \(error)")
                            return nil
                        }
                    }
                    
                    self?.firestoreAvatars = firestoreAvatars
                    self?.avatars = firestoreAvatars.map { $0.toLocalAvatar() }
                    
                    print("✅ Firebaseから\(self?.avatars.count ?? 0)個のアバターを取得しました")
                }
            }
    }
    
    // リフレッシュ
    func refresh() {
        fetchAvatars()
    }
    
    // エラーをクリア
    func clearError() {
        errorMessage = ""
    }
}

// MARK: - Extensions

extension FirestoreAvatar {
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
}
