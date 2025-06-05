/**
 * app.js - reMind App エントリーポイント
 * Firebase + Cloudinary統合版
 */

import { mainController } from './mainController.js';

// DOMContentLoaded時にアプリケーション初期化
document.addEventListener('DOMContentLoaded', function() {
  mainController.initialize();
});

console.log('📚 reMind App loaded successfully - Ready for Firebase + Cloudinary!');