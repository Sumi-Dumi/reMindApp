/**
 * mainController.js - メインコントローラー
 */

import { appState } from './state.js';
import { domManager } from './dom.js';
import { imageHandler } from './imageHandler.js';
import { audioHandler } from './audioHandler.js';
import { uploadService } from './uploadService.js';
import { firebaseService } from './firebaseService.js';
import { 
  showError, 
  hideMessages, 
  showSuccessWithSharing, 
  setupGlobalErrorHandling 
} from './utils.js';

export class MainController {
  constructor() {
    this.initialized = false;
  }

  // アプリケーション初期化
  async initialize() {
    try {
      console.log('🚀 reMind App with Firebase + Cloudinary を開始');
      
      // ⭐ まずFirebaseを初期化
      await firebaseService.initialize();
      
      // ⭐ その後でURL解析とアバター読み込み
      const avatarId = this.getAvatarIdFromURL();
      if (avatarId) {
        console.log('🔗 URL Avatar ID:', avatarId);
        appState.set('avatarId', avatarId);
        appState.set('isEditMode', true);
        
        // Firebase初期化後なので安全
        await this.loadExistingAvatar(avatarId);
      } else {
        console.log('🆕 新規アバター作成モード');
        appState.set('isEditMode', false);
      }
      
      // 以下既存のコード...
      domManager.initialize();
      this.setupEventListeners();
      imageHandler.enhanceImageSection();
      this.updateUI();
      this.setupStateObserver();
      setupGlobalErrorHandling();
      
      this.initialized = true;
      console.log('🎉 reMind App初期化完了');
      
    } catch (error) {
      console.error('❌ 初期化に失敗:', error);
      showError(error.message);
    }
  }


  // URL解析メソッドを追加
  getAvatarIdFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    
    // 方式1: ?avatarId=xxx の形式
    const avatarIdParam = urlParams.get('avatarId');
    if (avatarIdParam) {
      return avatarIdParam;
    }
    
    // 方式2: ?avatar_1749297509_8523 の形式
    const queryString = window.location.search;
    if (queryString.startsWith('?avatar_')) {
      return queryString.substring(1);
    }
    
    // 方式3: URLパラメータの最初のキーがアバターIDの場合
    const firstParam = urlParams.keys().next().value;
    if (firstParam && firstParam.startsWith('avatar_')) {
      return firstParam;
    }
    
    return null;
  }

  // 既存アバター読み込みメソッドを追加
  async loadExistingAvatar(avatarId) {
    try {
      console.log('📥 Loading existing avatar data for:', avatarId);
      
      const avatarData = await firebaseService.getAvatar(avatarId);
      
      if (avatarData) {
        console.log('✅ Existing avatar found:', avatarData);
        this.displayExistingAvatarInfo(avatarData);
      } else {
        console.log('⚠️ No existing avatar data found for ID:', avatarId);
      }
      
    } catch (error) {
      console.error('❌ Error loading existing avatar:', error);
    }
  }

  // UI更新メソッドを追加
  displayExistingAvatarInfo(avatarData) {
    if (avatarData.recipient_name) {
      const headerText = document.querySelector('.header-text');
      if (headerText) {
        headerText.innerHTML = `Help ${avatarData.recipient_name} feel safer`;
      }
    }
    
    if (avatarData.creator_name) {
      const subheaderText = document.querySelector('.subheader-text');
      if (subheaderText) {
        subheaderText.innerHTML = `${avatarData.creator_name} has requested you to create a personalized avatar.`;
      }
    }
    
    console.log(`📊 Avatar Status: ${avatarData.status}`);
  }

  // イベントリスナー設定
  setupEventListeners() {

    // チェックボックス機能
    const agreeTerms = domManager.get('agreeTerms');
    if (agreeTerms) {
      agreeTerms.addEventListener('click', () => this.toggleCheckbox());
    }
    
    const checkbox = domManager.get('checkbox');
    if (checkbox) {
      checkbox.addEventListener('click', (e) => {
        e.stopPropagation();
        this.toggleCheckbox();
      });
    }
    
    // 音声録音
    const audioSection = domManager.get('audioSection');
    if (audioSection) {
      audioSection.addEventListener('click', () => audioHandler.handleAudioRecord());
    }
    
    // 送信ボタン
    const submitButton = domManager.get('submitButton');
    if (submitButton) {
      submitButton.addEventListener('click', () => this.handleSubmit());
    }
    
    console.log('🎛️ イベントリスナー設定完了');
  }

  // 状態変更の監視
  setupStateObserver() {
    appState.subscribe((state) => {
      this.updateUI();
    });
  }

  // チェックボックス切り替え
  toggleCheckbox() {
    const currentState = appState.get('isChecked');
    appState.set('isChecked', !currentState);
    domManager.updateCheckbox(!currentState);
  }

  // UI状態更新
  updateUI() {
    const canSubmit = appState.canSubmit();
    const isSubmitting = appState.get('isSubmitting');
    
    domManager.updateSubmitButton(canSubmit, isSubmitting);
  }



    // メイン送信処理
  async handleSubmit() {
    const submitButton = domManager.get('submitButton');
    if (submitButton?.disabled || appState.get('isSubmitting')) return;
    
    appState.set('isSubmitting', true);
    submitButton.innerHTML = 'uploading...';
    
    try {
      hideMessages();
      console.log('🚀 アップロードプロセス開始...');
      
      // アバターIDの取得
      const avatarId = appState.get('avatarId');
      if (!avatarId) {
        showError('cannot upload without avatarId');
        return;
      }
      
      // Step 1: Cloudinaryにアップロード
      console.log('☁️ Cloudinaryにアップロード中...');
      const { imageUrls, audioUrl } = await uploadService.uploadToCloudinary(avatarId);
      console.log(`✅ Cloudinaryアップロード完了:`, { imageUrls, audioUrl });
      
      // Step 2: 新規作成ではなく既存ドキュメントを更新
      await firebaseService.updateExistingAvatar(avatarId, {
        image_urls: imageUrls,
        audio_url: audioUrl,
        status: 'not_ready',
        updated_at: firebase.firestore.FieldValue.serverTimestamp()
      });
      
      // ⭐ docIdを削除（更新処理では不要）
      console.log(`✅ Firebase更新完了: ${avatarId}`);
      
      setTimeout(() => {
        window.location.href = './thankyou.html';
      }, 500);
      
      // 成功表示
      showSuccessWithSharing(
        avatarId, 
        appState.get('creatorName'), 
        appState.get('recipientName')
      );
      
    } catch (error) {
      console.error('❌ アップロードに失敗:', error);
      showError(`Failed to upload: ${error.message}`);
    } finally {
      appState.set('isSubmitting', false);
      submitButton.innerHTML = 'Submit';
    }
  }
  // フォームリセット
  resetForm() {
    appState.reset();
    
    const recipientInput = domManager.get('recipientInput');
    const creatorInput = domManager.get('creatorInput');
    
    if (recipientInput) recipientInput.value = '';
    if (creatorInput) creatorInput.value = '';
    
    domManager.updateCheckbox(false);
    
    const audioSection = domManager.get('audioSection');
    const indicator = audioSection?.querySelector('.audio-file-indicator');
    if (indicator) indicator.remove();
    audioSection.style.position = '';
    
    imageHandler.updateImageDisplay();
    hideMessages();
    
    console.log('🔄 フォームリセット完了');
  }

  // デバッグ用ゲッター
  getState() {
    return appState.get();
  }

  // アプリケーションリセット
  resetApp() {
    window.location.reload();
  }
}

// シングルトンインスタンス
export const mainController = new MainController();

// グローバル関数（デバッグ用）
window.resetApp = () => mainController.resetApp();
window.getAppState = () => mainController.getState();