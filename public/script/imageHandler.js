/**
 * imageHandler.js - 画像処理機能
 */

import { APP_CONFIG } from './config.js';
import { appState } from './state.js';
import { domManager } from './dom.js';
import { showError } from './utils.js';

export class ImageHandler {
  constructor() {
    this.fileInput = null;
  }

  // 画像セクションの機能拡張
  enhanceImageSection() {
    this.createFileInput();
    this.setupImageSectionEvents();
    this.setupDragAndDrop();
  }

  // ファイル入力要素作成
  createFileInput() {
    this.fileInput = document.createElement('input');
    this.fileInput.type = 'file';
    this.fileInput.accept = 'image/*';
    this.fileInput.multiple = true;
    this.fileInput.style.display = 'none';
    this.fileInput.id = 'imageFileInput';
    document.body.appendChild(this.fileInput);

    this.fileInput.addEventListener('change', (e) => {
      const files = Array.from(e.target.files);
      this.processImageFiles(files);
      e.target.value = '';
    });
  }

  // 画像セクションのイベント設定
  setupImageSectionEvents() {
    const imageSection = domManager.get('imageSection');
    if (!imageSection) return;

    imageSection.style.cursor = 'pointer';
    imageSection.style.transition = 'all 0.3s ease';

    imageSection.addEventListener('click', () => {
      if (appState.get('images').length < appState.get('maxImages')) {
        this.fileInput.click();
      }
    });
  }

  // ドラッグ&ドロップ設定
  setupDragAndDrop() {
    const imageSection = domManager.get('imageSection');
    if (!imageSection) return;

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      imageSection.addEventListener(eventName, (e) => {
        e.preventDefault();
        e.stopPropagation();
      });
    });

    ['dragenter', 'dragover'].forEach(eventName => {
      imageSection.addEventListener(eventName, () => {
        imageSection.style.borderColor = '#dcec7d';
        imageSection.style.backgroundColor = '#f8fdf4';
        imageSection.style.transform = 'scale(1.02)';
      });
    });

    ['dragleave', 'drop'].forEach(eventName => {
      imageSection.addEventListener(eventName, () => {
        imageSection.style.borderColor = 'var(--Neutral-300, #b8c0cc)';
        imageSection.style.backgroundColor = '';
        imageSection.style.transform = 'scale(1)';
      });
    });

    imageSection.addEventListener('drop', (e) => {
      const files = Array.from(e.dataTransfer.files);
      const imageFiles = files.filter(file => file.type.startsWith('image/'));
      this.processImageFiles(imageFiles);
    });
  }

  // 画像ファイル処理
  processImageFiles(files) {
    files.forEach(file => {
      const currentImages = appState.get('images');
      if (currentImages.length < appState.get('maxImages')) {
        if (file.size > APP_CONFIG.maxImageSize) {
          showError(`画像 "${file.name}" のサイズが大きすぎます。最大サイズは10MBです。`);
          return;
        }
        this.addImageToState(file);
      }
    });
  }

  // 画像を状態に追加
  addImageToState(file) {
    const reader = new FileReader();
    reader.onload = (e) => {
      const imageData = {
        id: Date.now() + Math.random(),
        file: file,
        dataUrl: e.target.result,
        name: file.name,
        size: file.size
      };
      
      appState.addImage(imageData);
      this.updateImageDisplay();
    };
    reader.readAsDataURL(file);
  }

  // 画像表示更新
  updateImageDisplay() {
    const images = appState.get('images');
    const imageCount = images.length;
    const imageSection = domManager.get('imageSection');
    
    if (!imageSection) return;
    
    if (imageCount === 0) {
      domManager.resetImageSection();
    } else {
      const totalSizeMB = images.reduce((sum, img) => sum + img.size, 0) / (1024 * 1024);
      const maxImages = appState.get('maxImages');
      
      imageSection.innerHTML = `
        <div style="display: flex; align-items: center; gap: 12px; padding: 8px; min-height: 224px;">
          <div style="display: flex; gap: 8px; flex: 1; align-items: center; flex-wrap: wrap;">
            ${images.map(img => `
              <div style="position: relative; width: 70px; height: 70px; border-radius: 8px; overflow: hidden; border: 2px solid #dcec7d; flex-shrink: 0;">
                <img src="${img.dataUrl}" alt="${img.name}" style="width: 100%; height: 100%; object-fit: cover;">
                <button onclick="imageHandler.removeImage('${img.id}')" style="
                  position: absolute; top: -6px; right: -6px; width: 20px; height: 20px;
                  background: #ef4444; border-radius: 50%; color: white; border: none;
                  cursor: pointer; display: flex; align-items: center; justify-content: center;
                  font-size: 12px; z-index: 10; font-weight: bold;
                ">×</button>
              </div>
            `).join('')}
            ${imageCount < maxImages ? `
              <button onclick="document.getElementById('imageFileInput').click()" style="
                width: 70px; height: 70px; border: 2px dashed #b8c0cc; border-radius: 8px;
                background: white; cursor: pointer; display: flex; align-items: center;
                justify-content: center; flex-shrink: 0;
              ">
                <span style="font-size: 24px; color: #b8c0cc;">+</span>
              </button>
            ` : ''}
          </div>
          <div style="margin-left: auto; text-align: center; color: #64748b; font-size: 12px;">
            <div style="margin-bottom: 4px;">${imageCount}/${maxImages}</div>
            <div style="margin-bottom: 8px; font-size: 10px; color: #888;">
              ${totalSizeMB.toFixed(1)}MB
            </div>
            <div style="width: 60px; height: 4px; background: #e2e8f0; border-radius: 2px; overflow: hidden;">
              <div style="height: 100%; background: ${imageCount >= 1 ? '#dcec7d' : '#e2e8f0'}; width: ${(imageCount / maxImages) * 100}%; transition: width 0.3s ease;"></div>
            </div>
            ${imageCount >= 1 ? '<div style="margin-top: 4px; color: #22c55e; font-size: 10px;">✓ Ready</div>' : '<div style="margin-top: 4px; color: #ef4444; font-size: 10px;">Need 1+</div>'}
          </div>
        </div>
      `;
    }
  }

  // 画像削除
  removeImage(imageId) {
    appState.removeImage(imageId);
    this.updateImageDisplay();
  }
}

// シングルトンインスタンス
export const imageHandler = new ImageHandler();

// グローバル関数（onclick用）
window.imageHandler = imageHandler;