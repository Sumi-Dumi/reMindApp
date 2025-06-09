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
  } catch (err) {
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
  });

  window.addEventListener('unhandledrejection', function(e) {
    console.error('💥 未処理のPromise拒否:', e.reason);
  });
}

// グローバル関数（onclick用）
window.copyShareUrl = copyShareUrl;