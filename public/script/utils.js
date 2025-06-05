/**
 * utils.js - ユーティリティ関数
 */

import { domManager } from './dom.js';

// エラー表示
export function showError(message) {
  console.error('❌ エラー:', message);
  
  domManager.setErrorMessage(message);
  domManager.showMessage('error', true);
  domManager.showMessage('success', false);
}

// メッセージ非表示
export function hideMessages() {
  domManager.showMessage('success', false);
  domManager.showMessage('error', false);
}

// 成功メッセージ表示（共有リンク付き）
export function showSuccessWithSharing(avatarId, creatorName, recipientName) {
  const shareUrl = `${window.location.origin}/view/${avatarId}`;
  
  const successHtml = `
    <div style="text-align: center;">
      <p style="color: #22c55e; margin: 0; font-weight: 600; font-size: 18px;">🎉 アバターが正常に作成されました！</p>
      <p style="color: #16a34a; margin: 8px 0; font-size: 14px;">
        ファイルがCloudinaryにアップロードされました ☁️<br>
        メタデータがFirebaseに保存されました 🔥
      </p>
      
      <div style="margin: 16px 0; padding: 16px; background: #f0f9e8; border-radius: 12px;">
        <p style="margin: 0 0 8px 0; font-weight: 600; color: #16a34a;">📱 共有リンク:</p>
        <input type="text" value="${shareUrl}" readonly style="width: 100%; padding: 8px; border: 1px solid #dcec7d; border-radius: 6px; margin: 4px 0;">
        <button onclick="copyShareUrl('${shareUrl}')" style="background: #dcec7d; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; margin-top: 4px;">
          リンクをコピー
        </button>
      </div>
      
      <div style="font-size: 12px; color: #888;">
        <p style="margin: 2px 0;">アバター: ${avatarId}</p>
        <p style="margin: 2px 0;">送信者: ${creatorName} → 受信者: ${recipientName}</p>
      </div>
    </div>
  `;
  
  domManager.setSuccessMessage(successHtml);
  domManager.showMessage('success', true);
  domManager.showMessage('error', false);
}

// 共有URLをクリップボードにコピー
export function copyShareUrl(url) {
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(url).then(() => {
      console.log('✅ リンクがクリップボードにコピーされました');
      domManager.showTemporaryMessage('✅ リンクがクリップボードにコピーされました！');
    }).catch(() => {
      fallbackCopyToClipboard(url);
    });
  } else {
    fallbackCopyToClipboard(url);
  }
}

// フォールバックコピー機能
function fallbackCopyToClipboard(text) {
  const textArea = document.createElement('textarea');
  textArea.value = text;
  textArea.style.position = 'fixed';
  textArea.style.left = '-999999px';
  document.body.appendChild(textArea);
  textArea.focus();
  textArea.select();
  
  try {
    document.execCommand('copy');
    domManager.showTemporaryMessage('✅ リンクがコピーされました！');
  } catch (err) {
    domManager.showTemporaryMessage('❌ コピーに失敗しました');
  }
  
  document.body.removeChild(textArea);
}

// ユニークIDを生成
export function generateAvatarId() {
  return 'avatar_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

// ファイルサイズをフォーマット
export function formatFileSize(bytes) {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// 時間フォーマット
export function formatDuration(milliseconds) {
  const seconds = Math.floor(milliseconds / 1000);
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
}

// デバッグ関数
export function getAppDebugInfo() {
  return {
    timestamp: new Date().toISOString(),
    userAgent: navigator.userAgent,
    url: window.location.href,
    firebase: typeof firebase !== 'undefined' ? 'loaded' : 'not loaded'
  };
}

// エラーハンドリング
export function setupGlobalErrorHandling() {
  window.addEventListener('error', function(e) {
    console.error('💥 アプリケーションエラー:', e.error);
    showError('予期しないエラーが発生しました。ページをリフレッシュしてください。');
  });

  window.addEventListener('unhandledrejection', function(e) {
    console.error('💥 未処理のPromise拒否:', e.reason);
    showError('処理中にエラーが発生しました。もう一度お試しください。');
  });
}

// グローバル関数（onclick用）
window.copyShareUrl = copyShareUrl;