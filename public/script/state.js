/**
 * state.js - application state management 
 */

import { APP_CONFIG } from './config.js';

// アプリケーション状態の初期値
const initialState = {
  isChecked: false,
  hasImages: false,
  hasAudio: false,
  isSubmitting: false,
  images: [],
  maxImages: APP_CONFIG.maxImages,
  isRecording: false,
  mediaRecorder: null,
  audioChunks: [],
  recordingStartTime: null,
  recordingTimer: null,
  audioBlob: null,
  audioURL: null
};

// アプリケーション状態管理クラス
export class AppState {
  constructor() {
    this.state = { ...initialState };
    this.observers = [];
  }

  // 状態取得
  get(key) {
    return key ? this.state[key] : this.state;
  }

  // 状態更新
  set(key, value) {
    if (typeof key === 'object') {
      // オブジェクトで一括更新
      this.state = { ...this.state, ...key };
    } else {
      // 単一キーで更新
      this.state[key] = value;
    }
    this.notifyObservers();
  }

  // 状態リセット
  reset() {
    this.state = { ...initialState };
    this.notifyObservers();
  }

  // オブザーバー登録
  subscribe(observer) {
    this.observers.push(observer);
  }

  // オブザーバー通知
  notifyObservers() {
    this.observers.forEach(observer => observer(this.state));
  }

  // 特定のプロパティ用ヘルパーメソッド
  addImage(imageData) {
    if (this.state.images.length < this.state.maxImages) {
      this.state.images.push(imageData);
      this.set('hasImages', this.state.images.length > 0);
    }
  }

  removeImage(imageId) {
    this.state.images = this.state.images.filter(img => img.id != imageId);
    this.set('hasImages', this.state.images.length > 0);
  }

  setAudio(hasAudio, audioBlob = null, audioURL = null) {
    this.set({
      hasAudio,
      audioBlob,
      audioURL
    });
  }

  setRecording(isRecording, mediaRecorder = null) {
    this.set({
      isRecording,
      mediaRecorder,
      recordingStartTime: isRecording ? Date.now() : null
    });
  }

  canSubmit() {
    return this.state.isChecked && 
           this.state.images.length >= 1 && 
           this.state.hasAudio;
  }
}

// シングルトンインスタンス
export const appState = new AppState();

