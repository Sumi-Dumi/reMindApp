/**
 * uploadService.js - アップロード処理サービス
 */

import { CLOUDINARY_CONFIG } from './config.js';
import { appState } from './state.js';
import { domManager } from './dom.js';

export class UploadService {
  constructor() {
    this.uploadAttempts = new Map(); // リトライ管理用
    this.maxRetries = 3;
  }

  // メインアップロード処理
  async uploadToCloudinary(avatarId) {
    try {
      console.log('☁️ Cloudinaryアップロード開始...');
      
      // 画像とオーディオの並列アップロード
      const [imageUrls, audioUrl] = await Promise.all([
        this.uploadImages(avatarId),
        this.uploadAudio(avatarId)
      ]);
      
      return { imageUrls, audioUrl };
      
    } catch (error) {
      console.error('☁️ Cloudinaryアップロードに失敗:', error);
      // プログレス非表示
      // domManager.showProgress('image', false);
      // domManager.showProgress('audio', false);
      throw error;
    }
  }

  // 画像をCloudinaryにアップロード
  async uploadImages(avatarId) {
    const images = appState.get('images');
    
    if (!images || images.length === 0) {
      throw new Error('アップロードする画像がありません');
    }

    const urls = [];
    const total = images.length;
    
    // プログレス表示開始
    // domManager.showProgress('image', true);
    // domManager.updateProgress('image', 0, '画像アップロードを開始しています...');
    
    try {
      for (let i = 0; i < images.length; i++) {
        const image = images[i];
        
        console.log(`📷 画像アップロード中 ${i + 1}/${total}: ${image.name}`);
        // domManager.updateProgress('image', (i / total) * 80, `画像 ${i + 1}/${total} をCloudinaryにアップロード中...`);
        
        const url = await this.uploadSingleImage(image, avatarId, i);
        urls.push(url);
        
        console.log(`✅ 画像 ${i + 1} アップロード完了: ${url}`);
        
        // プログレス更新
        const progress = ((i + 1) / total) * 100;
        // domManager.updateProgress('image', progress);
      }
      
      // domManager.updateProgress('image', 100, `✅ ${total}枚の画像がアップロードされました！`);
      
      // プログレス非表示（遅延）
      setTimeout(() => {
        domManager.showProgress('image', false);
      }, 2000);
      
      return urls;
      
    } catch (error) {
      domManager.showProgress('image', false);
      throw error;
    }
  }

  // 単一画像のアップロード（リトライ機能付き）
  async uploadSingleImage(image, avatarId, index, attempt = 0) {
    const uploadKey = `${avatarId}_image_${index}`;
    
    try {
      const formData = new FormData();
      formData.append('file', image.file);
      formData.append('upload_preset', CLOUDINARY_CONFIG.uploadPreset);
      formData.append('public_id', `${avatarId}_image_${index}`);
      formData.append('folder', 'remind_avatars');
      
      // タイムアウト設定付きのfetch
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 30000); // 30秒タイムアウト
      
      const response = await fetch(
        `https://api.cloudinary.com/v1_1/${CLOUDINARY_CONFIG.cloudName}/image/upload`,
        { 
          method: 'POST', 
          body: formData,
          signal: controller.signal
        }
      );
      
      clearTimeout(timeoutId);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', errorText);
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }
      
      const result = await response.json();
      
      // 成功時はリトライカウントをリセット
      this.uploadAttempts.delete(uploadKey);
      
      return result.secure_url;
      
    } catch (error) {
      console.error(`❌ 画像 ${index + 1} アップロード試行 ${attempt + 1} に失敗:`, error);
      
      // リトライ処理
      if (attempt < this.maxRetries) {
        console.log(`🔄 画像 ${index + 1} を再試行中... (${attempt + 2}/${this.maxRetries + 1})`);
        
        // 指数バックオフでリトライ
        const delay = Math.pow(2, attempt) * 1000; // 1秒, 2秒, 4秒
        await new Promise(resolve => setTimeout(resolve, delay));
        
        return this.uploadSingleImage(image, avatarId, index, attempt + 1);
      }
      
      throw new Error(`画像 ${index + 1} (${image.name}) のアップロードに失敗しました: ${error.message}`);
    }
  }

  // 音声をCloudinaryにアップロード（リトライ機能付き）
  async uploadAudio(avatarId, attempt = 0) {
    const audioBlob = appState.get('audioBlob');
    if (!audioBlob) {
      throw new Error('音声データが見つかりません');
    }

    // プログレス表示開始
    // domManager.showProgress('audio', true);
    // domManager.updateProgress('audio', 25, 'Cloudinaryに音声をアップロード中...');
    
    try {
      console.log(`🎵 音声アップロード中: ${(audioBlob.size / 1024 / 1024).toFixed(2)}MB`);
      
      const formData = new FormData();
      formData.append('file', audioBlob);
      formData.append('upload_preset', CLOUDINARY_CONFIG.uploadPreset);
      formData.append('public_id', `${avatarId}_audio`);
      formData.append('folder', 'remind_avatars');
      formData.append('resource_type', 'video'); // 音声はvideoリソースタイプ
      
      // domManager.updateProgress('audio', 50, '音声データを送信中...');
      
      // タイムアウト設定付きのfetch
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 60000); // 60秒タイムアウト（音声は大きいファイルの可能性）
      
      const response = await fetch(
        `https://api.cloudinary.com/v1_1/${CLOUDINARY_CONFIG.cloudName}/video/upload`,
        { 
          method: 'POST', 
          body: formData,
          signal: controller.signal
        }
      );
      
      clearTimeout(timeoutId);
      // domManager.updateProgress('audio', 75, '音声処理中...');
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('Audio upload response error:', errorText);
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }
      
      const result = await response.json();
      
      // domManager.updateProgress('audio', 100, '✅ 音声がアップロードされました！');
      
      console.log(`✅ 音声アップロード完了: ${result.secure_url}`);
      
      // // プログレス非表示（遅延）
      // setTimeout(() => {
      //   domManager.showProgress('audio', false);
      // }, 2000);
      
      return result.secure_url;
      
    } catch (error) {
      console.error('❌ 音声アップロード試行', attempt + 1, 'に失敗:', error);
      
      // リトライ処理
      if (attempt < this.maxRetries) {
        console.log(`🔄 音声を再試行中... (${attempt + 2}/${this.maxRetries + 1})`);
        
        // プログレスリセット
        // domManager.updateProgress('audio', 10, `再試行中... (${attempt + 2}/${this.maxRetries + 1})`);
        
        // 指数バックオフでリトライ
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        
        return this.uploadAudio(avatarId, attempt + 1);
      }
      
      // domManager.showProgress('audio', false);
      throw new Error(`音声のアップロードに失敗しました: ${error.message}`);
    }
  }

  // アップロード状況の検証
  async validateUpload(imageUrls, audioUrl) {
    const validationResults = {
      images: [],
      audio: null,
      allValid: true
    };

    try {
      // 画像URLの検証
      for (let i = 0; i < imageUrls.length; i++) {
        try {
          const response = await fetch(imageUrls[i], { method: 'HEAD' });
          validationResults.images.push({
            index: i,
            url: imageUrls[i],
            valid: response.ok,
            status: response.status
          });
          
          if (!response.ok) {
            validationResults.allValid = false;
          }
        } catch (error) {
          validationResults.images.push({
            index: i,
            url: imageUrls[i],
            valid: false,
            error: error.message
          });
          validationResults.allValid = false;
        }
      }

      // 音声URLの検証
      try {
        const response = await fetch(audioUrl, { method: 'HEAD' });
        validationResults.audio = {
          url: audioUrl,
          valid: response.ok,
          status: response.status
        };
        
        if (!response.ok) {
          validationResults.allValid = false;
        }
      } catch (error) {
        validationResults.audio = {
          url: audioUrl,
          valid: false,
          error: error.message
        };
        validationResults.allValid = false;
      }

    } catch (error) {
      console.error('❌ アップロード検証中にエラー:', error);
      validationResults.allValid = false;
    }

    return validationResults;
  }

  // アップロード進捗のクリーンアップ
  cleanup() {
    this.uploadAttempts.clear();
    domManager.showProgress('image', false);
    domManager.showProgress('audio', false);
  }

  // アップロード統計取得
  getUploadStats() {
    const images = appState.get('images');
    const audioBlob = appState.get('audioBlob');
    
    const totalImageSize = images.reduce((sum, img) => sum + img.file.size, 0);
    const audioSize = audioBlob ? audioBlob.size : 0;
    const totalSize = totalImageSize + audioSize;

    return {
      imageCount: images.length,
      totalImageSize,
      audioSize,
      totalSize,
      totalSizeMB: (totalSize / 1024 / 1024).toFixed(2)
    };
  }
}

// シングルトンインスタンス
export const uploadService = new UploadService();