/**
 * firebaseService.js - Firebase処理サービス
 */

export class FirebaseService {
  constructor() {
    this.initialized = false;
  }

  // Firebase初期化チェック
  waitForFirebase() {
    return new Promise((resolve, reject) => {
      if (typeof firebase !== 'undefined') {
        this.initialized = true;
        resolve();
      } else {
        console.log('⏳ Firebaseの読み込みを待機中...');
        setTimeout(() => {
          if (typeof firebase !== 'undefined') {
            this.initialized = true;
            resolve();
          } else {
            reject(new Error('Firebase設定エラー。ページをリフレッシュしてください。'));
          }
        }, 2000);
      }
    });
  }

  // Firebase初期化
  async initialize() {
    await this.waitForFirebase();
    console.log('✅ Firebase初期化完了');
    if (firebase.app) {
      console.log('📊 Firebase Project ID:', firebase.app().options.projectId);
    }
  }

  // メタデータをFirebaseに保存
  async saveMetadata(data) {
    if (!this.initialized) {
      throw new Error('Firebaseが初期化されていません');
    }

    try {
      console.log('💾 Firebaseにメタデータを保存中...', data);
      
      const docRef = await firebase.firestore().collection('avatars').add(data);
      console.log(`✅ メタデータ保存完了 ID: ${docRef.id}`);
      
      return docRef.id;
    } catch (error) {
      console.error('❌ Firebase保存に失敗:', error);
      throw new Error(`Firebase保存に失敗しました: ${error.message}`);
    }
  }

  // アバターデータ取得
  async getAvatar(avatarId) {
    if (!this.initialized) {
      throw new Error('Firebaseが初期化されていません');
    }

    try {
      const querySnapshot = await firebase.firestore()
        .collection('avatars')
        .where('id', '==', avatarId)
        .limit(1)
        .get();

      if (querySnapshot.empty) {
        throw new Error('アバターが見つかりません');
      }

      const doc = querySnapshot.docs[0];
      return { id: doc.id, ...doc.data() };
    } catch (error) {
      console.error('❌ アバター取得に失敗:', error);
      throw new Error(`アバター取得に失敗しました: ${error.message}`);
    }
  }

  // アバターリスト取得
  async getAvatarsList(limit = 50) {
    if (!this.initialized) {
      throw new Error('Firebaseが初期化されていません');
    }

    try {
      const querySnapshot = await firebase.firestore()
        .collection('avatars')
        .orderBy('created_at', 'desc')
        .limit(limit)
        .get();

      const avatars = [];
      querySnapshot.forEach((doc) => {
        avatars.push({ id: doc.id, ...doc.data() });
      });

      return avatars;
    } catch (error) {
      console.error('❌ アバターリスト取得に失敗:', error);
      throw new Error(`アバターリスト取得に失敗しました: ${error.message}`);
    }
  }

  // アバター更新
  async updateAvatar(docId, updateData) {
    if (!this.initialized) {
      throw new Error('Firebaseが初期化されていません');
    }

    try {
      await firebase.firestore()
        .collection('avatars')
        .doc(docId)
        .update({
          ...updateData,
          updated_at: firebase.firestore.FieldValue.serverTimestamp()
        });

      console.log(`✅ アバター更新完了 ID: ${docId}`);
    } catch (error) {
      console.error('❌ アバター更新に失敗:', error);
      throw new Error(`アバター更新に失敗しました: ${error.message}`);
    }
  }

  // アバター削除
  async deleteAvatar(docId) {
    if (!this.initialized) {
      throw new Error('Firebaseが初期化されていません');
    }

    try {
      await firebase.firestore()
        .collection('avatars')
        .doc(docId)
        .delete();

      console.log(`✅ アバター削除完了 ID: ${docId}`);
    } catch (error) {
      console.error('❌ アバター削除に失敗:', error);
      throw new Error(`アバター削除に失敗しました: ${error.message}`);
    }
  }
}

// シングルトンインスタンス
export const firebaseService = new FirebaseService();