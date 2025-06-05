/**
 * dom.js - DOM manage
 */

// DOM要素管理クラス
export class DOMManager {
  constructor() {
    this.elements = {};
    this.originalImageContent = '';
  }

  // DOM要素を取得して保存
  initialize() {
    this.elements = {
      checkbox: document.querySelector('.checkbox'),
      submitButton: document.querySelector('.button-primary'),
      agreeTerms: document.querySelector('.agree-terms'),
      imageSection: document.querySelector('.image'),
      audioSection: document.querySelector('.mic-audio'),
      mainContainer: document.querySelector('.main'),
      mobileInterface: document.querySelector('.mobile-interface'),
      recipientInput: document.getElementById('recipientName'),
      creatorInput: document.getElementById('creatorName'),
      submitBtn: document.getElementById('submitBtn'),
      successMsg: document.getElementById('successMessage'),
      errorMsg: document.getElementById('errorMessage'),
      errorText: document.getElementById('errorText'),
      imageUploadProgress: document.getElementById('imageUploadProgress'),
      imageProgressBar: document.getElementById('imageProgressBar'),
      imageProgressText: document.getElementById('imageProgressText'),
      audioUploadProgress: document.getElementById('audioUploadProgress'),
      audioProgressBar: document.getElementById('audioProgressBar'),
      audioProgressText: document.getElementById('audioProgressText')
    };
    
    // 元の画像セクションコンテンツを保存
    this.originalImageContent = this.elements.imageSection.innerHTML;
    
    console.log('📝 DOM elements loaded');
    return this.elements;
  }

  // 要素取得
  get(elementName) {
    return this.elements[elementName];
  }

  // 画像セクションのコンテンツリセット
  resetImageSection() {
    this.elements.imageSection.innerHTML = this.originalImageContent;
  }

  // プログレスバー表示制御
  showProgress(type, show = true) {
    const progressElement = this.elements[`${type}UploadProgress`];
    if (progressElement) {
      progressElement.style.display = show ? 'block' : 'none';
    }
  }

  // プログレスバー更新
  updateProgress(type, percentage, text = '') {
    const progressBar = this.elements[`${type}ProgressBar`];
    const progressText = this.elements[`${type}ProgressText`];
    
    if (progressBar) {
      progressBar.style.width = `${percentage}%`;
    }
    
    if (progressText && text) {
      progressText.textContent = text;
    }
  }

  // メッセージ表示制御
  showMessage(type, show = true) {
    const messageElement = this.elements[`${type}Msg`];
    if (messageElement) {
      messageElement.style.display = show ? 'block' : 'none';
    }
  }

  // エラーメッセージ設定
  setErrorMessage(message) {
    if (this.elements.errorText) {
      this.elements.errorText.textContent = message;
    }
  }

  // 成功メッセージ設定
  setSuccessMessage(html) {
    if (this.elements.successMsg) {
      this.elements.successMsg.innerHTML = html;
    }
  }

  // 要素のスタイル更新
  updateElementStyle(elementName, styles) {
    const element = this.get(elementName);
    if (element) {
      Object.assign(element.style, styles);
    }
  }

  // チェックボックス状態更新
  updateCheckbox(isChecked) {
    const checkbox = this.get('checkbox');
    if (!checkbox) return;

    if (isChecked) {
      checkbox.style.background = '#dcec7d';
      checkbox.style.borderColor = '#dcec7d';
      checkbox.innerHTML = '<span style="color: #000; font-weight: bold; font-size: 12px;">✓</span>';
    } else {
      checkbox.style.background = '#fff';
      checkbox.style.borderColor = '#95929e';
      checkbox.innerHTML = '';
    }
  }

  // 送信ボタン状態更新
  updateSubmitButton(canSubmit, isSubmitting = false) {
    const button = this.get('submitButton');
    if (!button) return;

    if (canSubmit && !isSubmitting) {
      Object.assign(button.style, {
        background: '#dcec7d',
        color: '#000',
        cursor: 'pointer',
        opacity: '1',
        transition: 'all 0.3s ease'
      });
      button.disabled = false;
    } else {
      Object.assign(button.style, {
        background: '#e5e5e5',
        color: '#999',
        cursor: 'not-allowed',
        opacity: '0.6',
        transition: 'all 0.3s ease'
      });
      button.disabled = true;
    }
  }

  // 一時的なメッセージ表示
  showTemporaryMessage(message, duration = 2000) {
    const temp = document.createElement('div');
    temp.style.cssText = `
      position: fixed; top: 20px; right: 20px; background: #333; color: white;
      padding: 12px 20px; border-radius: 8px; z-index: 10000; font-size: 14px;
    `;
    temp.textContent = message;
    document.body.appendChild(temp);
    
    setTimeout(() => {
      temp.remove();
    }, duration);
  }
}

// シングルトンインスタンス
export const domManager = new DOMManager();