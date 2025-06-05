/**
 * reMind App - Firebase + Cloudinary Integration (修正版)
 * Fixed version with proper Cloudinary upload
 */

// Cloudinary設定 (あなたの実際の設定)
const CLOUDINARY_CONFIG = {
  cloudName: 'dvyjkf3xq',
  uploadPreset: 'remind_unsigned'
};

// Application state
let appState = {
  isChecked: false,
  hasImages: false,
  hasAudio: false,
  isSubmitting: false,
  images: [],
  maxImages: 3,
  recipientName: '',
  creatorName: '',
  isRecording: false,
  mediaRecorder: null,
  audioChunks: [],
  recordingStartTime: null,
  recordingTimer: null,
  audioBlob: null,
  audioURL: null
};

// DOM elements
let elements = {};

/**
 * Initialize the application when DOM is loaded
 */
document.addEventListener('DOMContentLoaded', function() {
  console.log('🚀 Starting reMind App with Firebase + Cloudinary');
  
  // Wait for Firebase to be available
  if (typeof firebase !== 'undefined') {
    initializeApp();
  } else {
    console.log('⏳ Waiting for Firebase to load...');
    setTimeout(() => {
      if (typeof firebase !== 'undefined') {
        initializeApp();
      } else {
        console.error('❌ Firebase failed to load');
        showError('Firebase configuration error. Please refresh the page.');
      }
    }, 2000);
  }
});

/**
 * Initialize all app functionality
 */
function initializeApp() {
  console.log('✅ Firebase initialized');
  if (firebase.app) {
    console.log('📊 Firebase Project ID:', firebase.app().options.projectId);
  }
  
  // Get DOM elements
  getDOMElements();
  
  // Setup event listeners
  setupEventListeners();
  
  // Enhance image section for upload
  enhanceImageSection();
  
  // Initialize UI state
  updateSubmitButtonState();
  
  console.log('🎉 reMind App initialized successfully');
}

/**
 * Get all necessary DOM elements
 */
function getDOMElements() {
  elements = {
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
  
  console.log('📝 DOM elements loaded');
}

/**
 * Setup all event listeners
 */
function setupEventListeners() {
  // 名前入力フィールド
  if (elements.recipientInput) {
    elements.recipientInput.addEventListener('input', (e) => {
      appState.recipientName = e.target.value.trim();
      updateSubmitButtonState();
    });
  }

  if (elements.creatorInput) {
    elements.creatorInput.addEventListener('input', (e) => {
      appState.creatorName = e.target.value.trim();
      updateSubmitButtonState();
    });
  }

  // Checkbox functionality
  if (elements.agreeTerms) {
    elements.agreeTerms.addEventListener('click', toggleCheckbox);
  }
  
  if (elements.checkbox) {
    elements.checkbox.addEventListener('click', function(e) {
      e.stopPropagation();
      toggleCheckbox();
    });
  }
  
  // Audio recording
  if (elements.audioSection) {
    elements.audioSection.addEventListener('click', handleAudioRecord);
  }
  
  // Submit button (修正: 正しい関数を呼び出し)
  if (elements.submitButton) {
    elements.submitButton.addEventListener('click', handleFirebaseSubmit);
  }
  
  console.log('🎛️ Event listeners setup complete');
}

// =================== 画像処理機能 ===================

function enhanceImageSection() {
  const fileInput = document.createElement('input');
  fileInput.type = 'file';
  fileInput.accept = 'image/*';
  fileInput.multiple = true;
  fileInput.style.display = 'none';
  fileInput.id = 'imageFileInput';
  document.body.appendChild(fileInput);
  
  const originalContent = elements.imageSection.innerHTML;
  
  elements.imageSection.style.cursor = 'pointer';
  elements.imageSection.style.transition = 'all 0.3s ease';
  
  fileInput.addEventListener('change', function(e) {
    const files = Array.from(e.target.files);
    processImageFiles(files);
    e.target.value = '';
  });
  
  elements.imageSection.addEventListener('click', function() {
    if (appState.images.length < appState.maxImages) {
      fileInput.click();
    }
  });
  
  setupDragAndDrop(elements.imageSection);
  
  elements.fileInput = fileInput;
  elements.originalImageContent = originalContent;
}

function setupDragAndDrop(dropZone) {
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, (e) => {
      e.preventDefault();
      e.stopPropagation();
    });
  });
  
  ['dragenter', 'dragover'].forEach(eventName => {
    dropZone.addEventListener(eventName, () => {
      dropZone.style.borderColor = '#dcec7d';
      dropZone.style.backgroundColor = '#f8fdf4';
      dropZone.style.transform = 'scale(1.02)';
    });
  });
  
  ['dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, () => {
      dropZone.style.borderColor = 'var(--Neutral-300, #b8c0cc)';
      dropZone.style.backgroundColor = '';
      dropZone.style.transform = 'scale(1)';
    });
  });
  
  dropZone.addEventListener('drop', (e) => {
    const files = Array.from(e.dataTransfer.files);
    const imageFiles = files.filter(file => file.type.startsWith('image/'));
    processImageFiles(imageFiles);
  });
}

function processImageFiles(files) {
  files.forEach(file => {
    if (appState.images.length < appState.maxImages) {
      if (file.size > 10 * 1024 * 1024) {
        showError(`Image "${file.name}" is too large. Maximum size is 10MB.`);
        return;
      }
      addImageToState(file);
    }
  });
}

function addImageToState(file) {
  const reader = new FileReader();
  reader.onload = function(e) {
    const imageData = {
      id: Date.now() + Math.random(),
      file: file,
      dataUrl: e.target.result,
      name: file.name,
      size: file.size
    };
    
    appState.images.push(imageData);
    updateImageDisplay();
    updateSubmitButtonState();
  };
  reader.readAsDataURL(file);
}

function updateImageDisplay() {
  const imageCount = appState.images.length;
  
  if (imageCount === 0) {
    elements.imageSection.innerHTML = elements.originalImageContent;
    appState.hasImages = false;
  } else {
    appState.hasImages = true;
    
    const totalSizeMB = appState.images.reduce((sum, img) => sum + img.size, 0) / (1024 * 1024);
    
    elements.imageSection.innerHTML = `
      <div style="display: flex; align-items: center; gap: 12px; padding: 8px; min-height: 224px;">
        <div style="display: flex; gap: 8px; flex: 1; align-items: center; flex-wrap: wrap;">
          ${appState.images.map(img => `
            <div style="position: relative; width: 70px; height: 70px; border-radius: 8px; overflow: hidden; border: 2px solid #dcec7d; flex-shrink: 0;">
              <img src="${img.dataUrl}" alt="${img.name}" style="width: 100%; height: 100%; object-fit: cover;">
              <button onclick="removeImage('${img.id}')" style="
                position: absolute; top: -6px; right: -6px; width: 20px; height: 20px;
                background: #ef4444; border-radius: 50%; color: white; border: none;
                cursor: pointer; display: flex; align-items: center; justify-content: center;
                font-size: 12px; z-index: 10; font-weight: bold;
              ">×</button>
            </div>
          `).join('')}
          ${imageCount < appState.maxImages ? `
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
          <div style="margin-bottom: 4px;">${imageCount}/${appState.maxImages}</div>
          <div style="margin-bottom: 8px; font-size: 10px; color: #888;">
            ${totalSizeMB.toFixed(1)}MB
          </div>
          <div style="width: 60px; height: 4px; background: #e2e8f0; border-radius: 2px; overflow: hidden;">
            <div style="height: 100%; background: ${imageCount >= 1 ? '#dcec7d' : '#e2e8f0'}; width: ${(imageCount / appState.maxImages) * 100}%; transition: width 0.3s ease;"></div>
          </div>
          ${imageCount >= 1 ? '<div style="margin-top: 4px; color: #22c55e; font-size: 10px;">✓ Ready</div>' : '<div style="margin-top: 4px; color: #ef4444; font-size: 10px;">Need 1+</div>'}
        </div>
      </div>
    `;
  }
}

function removeImage(imageId) {
  appState.images = appState.images.filter(img => img.id != imageId);
  updateImageDisplay();
  updateSubmitButtonState();
}

// =================== 音声処理機能 ===================

async function handleAudioRecord() {
  if (appState.hasAudio) {
    appState.hasAudio = false;
    appState.audioBlob = null;
    if (appState.audioURL) {
      URL.revokeObjectURL(appState.audioURL);
      appState.audioURL = null;
    }
    
    const indicator = elements.audioSection.querySelector('.audio-file-indicator');
    if (indicator) {
      indicator.remove();
    }
    updateSubmitButtonState();
  }
  
  if (appState.isRecording) {
    stopRecording();
  } else {
    await startRecording();
  }
}

async function startRecording() {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ 
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
        sampleRate: 44100
      }
    });
    
    appState.mediaRecorder = new MediaRecorder(stream, {
      mimeType: 'audio/webm;codecs=opus'
    });
    appState.audioChunks = [];
    
    appState.mediaRecorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        appState.audioChunks.push(event.data);
      }
    };
    
    appState.mediaRecorder.onstop = () => {
      appState.audioBlob = new Blob(appState.audioChunks, { type: 'audio/webm;codecs=opus' });
      appState.audioURL = URL.createObjectURL(appState.audioBlob);
      
      stream.getTracks().forEach(track => track.stop());
      closeRecordingPopup();
      showAudioFileIndicator();
      
      console.log(`🎵 Audio recorded: ${(appState.audioBlob.size / 1024 / 1024).toFixed(2)}MB`);
    };
    
    appState.mediaRecorder.start();
    appState.isRecording = true;
    appState.recordingStartTime = Date.now();
    
    showRecordingPopup();
    console.log('🎤 Recording started');
    
  } catch (error) {
    console.error('🎤 Error accessing microphone:', error);
    showError('Cannot access microphone. Please allow microphone access.');
  }
}

function stopRecording() {
  if (appState.mediaRecorder && appState.isRecording) {
    appState.mediaRecorder.stop();
    appState.isRecording = false;
    console.log('🎤 Recording stopped');
  }
}

function showRecordingPopup() {
  const popup = document.createElement('div');
  popup.id = 'recordingPopup';
  popup.style.cssText = `
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0, 0, 0, 0.8); display: flex; align-items: center;
    justify-content: center; z-index: 10000;
  `;
  
  popup.innerHTML = `
    <div style="background: white; border-radius: 20px; padding: 40px; text-align: center; max-width: 400px;">
      <div style="width: 80px; height: 80px; background: #ef4444; border-radius: 50%; margin: 0 auto 24px; display: flex; align-items: center; justify-content: center; animation: pulse 2s ease-in-out infinite;">
        <div style="width: 16px; height: 16px; background: white; border-radius: 50%;"></div>
      </div>
      <h2 style="color: #1f2937; font-size: 24px; margin: 0 0 8px 0;">Recording...</h2>
      <p style="color: #6b7280; margin: 0 0 32px 0;">Speak clearly into your microphone</p>
      <button onclick="window.stopRecording()" style="background: #ef4444; color: white; border: none; border-radius: 12px; padding: 16px 32px; font-size: 16px; cursor: pointer;">
        Stop Recording
      </button>
    </div>
  `;
  
  document.body.appendChild(popup);
  
  // Add CSS for animation
  if (!document.querySelector('#recordingStyles')) {
    const style = document.createElement('style');
    style.id = 'recordingStyles';
    style.textContent = `
      @keyframes pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.05); } }
    `;
    document.head.appendChild(style);
  }
}

function closeRecordingPopup() {
  const popup = document.getElementById('recordingPopup');
  if (popup) popup.remove();
}

function showAudioFileIndicator() {
  appState.hasAudio = true;
  
  const existingIndicator = elements.audioSection.querySelector('.audio-file-indicator');
  if (existingIndicator) {
    existingIndicator.remove();
  }
  
  const indicator = document.createElement('div');
  indicator.className = 'audio-file-indicator';
  indicator.style.cssText = `
    position: absolute; top: -8px; right: -8px; width: 24px; height: 24px;
    background: #22c55e; border-radius: 50%; display: flex; align-items: center;
    justify-content: center; color: white; font-size: 12px; z-index: 5;
  `;
  indicator.innerHTML = '🎵';
  
  elements.audioSection.style.position = 'relative';
  elements.audioSection.appendChild(indicator);
  
  updateSubmitButtonState();
}

// =================== UI状態管理 ===================

function toggleCheckbox() {
  appState.isChecked = !appState.isChecked;
  
  if (appState.isChecked) {
    elements.checkbox.style.background = '#dcec7d';
    elements.checkbox.style.borderColor = '#dcec7d';
    elements.checkbox.innerHTML = '<span style="color: #000; font-weight: bold; font-size: 12px;">✓</span>';
  } else {
    elements.checkbox.style.background = '#fff';
    elements.checkbox.style.borderColor = '#95929e';
    elements.checkbox.innerHTML = '';
  }
  
  updateSubmitButtonState();
}

function updateSubmitButtonState() {
  const canSubmit = appState.isChecked && 
                   appState.images.length >= 1 && 
                   appState.hasAudio &&
                   appState.recipientName.length > 0 &&
                   appState.creatorName.length > 0;
  
  if (canSubmit && !appState.isSubmitting) {
    elements.submitButton.style.background = '#dcec7d';
    elements.submitButton.style.color = '#000';
    elements.submitButton.style.cursor = 'pointer';
    elements.submitButton.style.opacity = '1';
    elements.submitButton.disabled = false;
  } else {
    elements.submitButton.style.background = '#e5e5e5';
    elements.submitButton.style.color = '#999';
    elements.submitButton.style.cursor = 'not-allowed';
    elements.submitButton.style.opacity = '0.6';
    elements.submitButton.disabled = true;
  }
  
  elements.submitButton.style.transition = 'all 0.3s ease';
}

// =================== CLOUDINARY + FIREBASE統合 ===================

/**
 * メイン送信処理 (修正版)
 */
async function handleFirebaseSubmit() {
  if (elements.submitButton.disabled || appState.isSubmitting) return;
  
  appState.isSubmitting = true;
  elements.submitButton.innerHTML = 'Uploading...';
  elements.submitButton.disabled = true;
  updateSubmitButtonState();
  
  try {
    hideMessages();
    console.log('🚀 Starting upload process...');
    
    // Generate unique avatar ID
    const avatarId = 'avatar_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    console.log(`📝 Avatar ID: ${avatarId}`);
    
    // Step 1: Upload to Cloudinary
    console.log('☁️ Uploading to Cloudinary...');
    const { imageUrls, audioUrl } = await uploadToCloudinary(avatarId);
    console.log(`✅ Cloudinary upload complete:`, { imageUrls, audioUrl });
    
    // Step 2: Save metadata to Firebase
    console.log('🔥 Saving metadata to Firebase...');
    const docId = await saveMetadataToFirebase({
      id: avatarId,
      recipient_name: appState.recipientName,
      creator_name: appState.creatorName,
      image_urls: imageUrls,
      audio_url: audioUrl,
      image_count: appState.images.length,
      audio_size_mb: (appState.audioBlob.size / 1024 / 1024).toFixed(2),
      storage_provider: 'cloudinary',
      status: 'ready',
      created_at: firebase.firestore.FieldValue.serverTimestamp(),
      updated_at: firebase.firestore.FieldValue.serverTimestamp()
    });
    
    console.log(`✅ Firebase save complete. Doc ID: ${docId}`);
    
    // Show success
    showSuccessWithSharing(avatarId);
    
  } catch (error) {
    console.error('❌ Upload failed:', error);
    showError(`Upload failed: ${error.message}`);
  } finally {
    appState.isSubmitting = false;
    elements.submitButton.innerHTML = 'Submit';
    updateSubmitButtonState();
  }
}

/**
 * Cloudinaryアップロード (修正版)
 */
async function uploadToCloudinary(avatarId) {
  try {
    console.log('☁️ Starting Cloudinary upload...');
    
    // 画像アップロード
    const imageUrls = await uploadImagesToCloudinary(avatarId);
    
    // 音声アップロード
    const audioUrl = await uploadAudioToCloudinary(avatarId);
    
    return { imageUrls, audioUrl };
    
  } catch (error) {
    console.error('☁️ Cloudinary upload failed:', error);
    throw error;
  }
}

/**
 * 画像をCloudinaryにアップロード
 */
async function uploadImagesToCloudinary(avatarId) {
  const urls = [];
  const total = appState.images.length;
  
  // Show progress
  if (elements.imageUploadProgress) {
    elements.imageUploadProgress.style.display = 'block';
    elements.imageProgressBar.style.width = '0%';
  }
  
  for (let i = 0; i < appState.images.length; i++) {
    const image = appState.images[i];
    
    console.log(`📷 Uploading image ${i + 1}/${total}: ${image.name}`);
    if (elements.imageProgressText) {
      elements.imageProgressText.textContent = `Uploading image ${i + 1}/${total} to Cloudinary...`;
    }
    
    try {
      const formData = new FormData();
      formData.append('file', image.file);
      formData.append('upload_preset', CLOUDINARY_CONFIG.uploadPreset);
      formData.append('public_id', `${avatarId}_image_${i}`);
      formData.append('folder', 'remind_avatars');
      
      const response = await fetch(
        `https://api.cloudinary.com/v1_1/${CLOUDINARY_CONFIG.cloudName}/image/upload`,
        { method: 'POST', body: formData }
      );
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', errorText);
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }
      
      const result = await response.json();
      urls.push(result.secure_url);
      
      console.log(`✅ Image ${i + 1} uploaded: ${result.secure_url}`);
      
      // Update progress
      const progress = ((i + 1) / total) * 100;
      if (elements.imageProgressBar) {
        elements.imageProgressBar.style.width = progress + '%';
      }
      
    } catch (error) {
      console.error(`❌ Image ${i + 1} upload failed:`, error);
      throw new Error(`Failed to upload image ${i + 1}: ${error.message}`);
    }
  }
  
  if (elements.imageProgressText) {
    elements.imageProgressText.textContent = `✅ ${total} images uploaded!`;
  }
  
  // Hide progress after delay
  setTimeout(() => {
    if (elements.imageUploadProgress) {
      elements.imageUploadProgress.style.display = 'none';
    }
  }, 2000);
  
  return urls;
}

/**
 * 音声をCloudinaryにアップロード
 */
async function uploadAudioToCloudinary(avatarId) {
  // Show progress
  if (elements.audioUploadProgress) {
    elements.audioUploadProgress.style.display = 'block';
    elements.audioProgressBar.style.width = '25%';
    elements.audioProgressText.textContent = 'Uploading audio to Cloudinary...';
  }
  
  try {
    console.log(`🎵 Uploading audio: ${(appState.audioBlob.size / 1024 / 1024).toFixed(2)}MB`);
    
    const formData = new FormData();
    formData.append('file', appState.audioBlob);
    formData.append('upload_preset', CLOUDINARY_CONFIG.uploadPreset);
    formData.append('public_id', `${avatarId}_audio`);
    formData.append('folder', 'remind_avatars');
    formData.append('resource_type', 'video'); // 音声はvideoリソースタイプ
    
    if (elements.audioProgressBar) {
      elements.audioProgressBar.style.width = '50%';
    }
    
    const response = await fetch(
      `https://api.cloudinary.com/v1_1/${CLOUDINARY_CONFIG.cloudName}/video/upload`,
      { method: 'POST', body: formData }
    );
    
    if (elements.audioProgressBar) {
      elements.audioProgressBar.style.width = '75%';
    }
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error('Audio upload response error:', errorText);
      throw new Error(`HTTP ${response.status}: ${errorText}`);
    }
    
    const result = await response.json();
    
    if (elements.audioProgressBar) {
      elements.audioProgressBar.style.width = '100%';
      elements.audioProgressText.textContent = '✅ Audio uploaded!';
    }
    
    console.log(`✅ Audio uploaded: ${result.secure_url}`);
    
    // Hide progress after delay
    setTimeout(() => {
      if (elements.audioUploadProgress) {
        elements.audioUploadProgress.style.display = 'none';
      }
    }, 2000);
    
    return result.secure_url;
    
  } catch (error) {
    console.error('❌ Audio upload failed:', error);
    if (elements.audioUploadProgress) {
      elements.audioUploadProgress.style.display = 'none';
    }
    throw new Error(`Failed to upload audio: ${error.message}`);
  }
}

/**
 * Firebaseにメタデータ保存
 */
async function saveMetadataToFirebase(data) {
  try {
    console.log('💾 Saving metadata to Firebase...', data);
    
    const docRef = await firebase.firestore().collection('avatars').add(data);
    console.log(`✅ Metadata saved with ID: ${docRef.id}`);
    
    return docRef.id;
  } catch (error) {
    console.error('❌ Firebase save failed:', error);
    throw new Error(`Firebase save failed: ${error.message}`);
  }
}

// =================== メッセージ表示 ===================

function showSuccessWithSharing(avatarId) {
  const shareUrl = `${window.location.origin}/view/${avatarId}`;
  
  if (elements.successMsg) {
    elements.successMsg.style.display = 'block';
    elements.successMsg.innerHTML = `
      <div style="text-align: center;">
        <p style="color: #22c55e; margin: 0; font-weight: 600; font-size: 18px;">🎉 Avatar Created Successfully!</p>
        <p style="color: #16a34a; margin: 8px 0; font-size: 14px;">
          Files uploaded to Cloudinary ☁️<br>
          Metadata saved to Firebase 🔥
        </p>
        
        <div style="margin: 16px 0; padding: 16px; background: #f0f9e8; border-radius: 12px;">
          <p style="margin: 0 0 8px 0; font-weight: 600; color: #16a34a;">📱 Share Link:</p>
          <input type="text" value="${shareUrl}" readonly style="width: 100%; padding: 8px; border: 1px solid #dcec7d; border-radius: 6px; margin: 4px 0;">
          <button onclick="copyShareUrl('${shareUrl}')" style="background: #dcec7d; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; margin-top: 4px;">
            Copy Link
          </button>
        </div>
        
        <div style="font-size: 12px; color: #888;">
          <p style="margin: 2px 0;">Avatar: ${avatarId}</p>
          <p style="margin: 2px 0;">From: ${appState.creatorName} → ${appState.recipientName}</p>
        </div>
      </div>
    `;
  }
  
  if (elements.errorMsg) {
    elements.errorMsg.style.display = 'none';
  }
}

function copyShareUrl(url) {
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(url).then(() => {
      console.log('✅ Link copied to clipboard');
      showTemporaryMessage('✅ Link copied to clipboard!');
    }).catch(() => {
      fallbackCopyToClipboard(url);
    });
  } else {
    fallbackCopyToClipboard(url);
  }
}

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
    showTemporaryMessage('✅ Link copied!');
  } catch (err) {
    showTemporaryMessage('❌ Copy failed');
  }
  
  document.body.removeChild(textArea);
}

function showTemporaryMessage(message) {
  const temp = document.createElement('div');
  temp.style.cssText = `
    position: fixed; top: 20px; right: 20px; background: #333; color: white;
    padding: 12px 20px; border-radius: 8px; z-index: 10000; font-size: 14px;
  `;
  temp.textContent = message;
  document.body.appendChild(temp);
  
  setTimeout(() => {
    temp.remove();
  }, 2000);
}

function showError(message) {
  console.error('❌ Error:', message);
  
  if (elements.errorMsg) {
    elements.errorMsg.style.display = 'block';
    elements.errorText.textContent = message;
  }
  
  if (elements.successMsg) {
    elements.successMsg.style.display = 'none';
  }
}

function hideMessages() {
  if (elements.successMsg) elements.successMsg.style.display = 'none';
  if (elements.errorMsg) elements.errorMsg.style.display = 'none';
}

function resetForm() {
  appState = {
    isChecked: false,
    hasImages: false,
    hasAudio: false,
    isSubmitting: false,
    images: [],
    maxImages: 3,
    recipientName: '',
    creatorName: '',
    isRecording: false,
    mediaRecorder: null,
    audioChunks: [],
    recordingStartTime: null,
    recordingTimer: null,
    audioBlob: null,
    audioURL: null
  };
  
  if (elements.recipientInput) elements.recipientInput.value = '';
  if (elements.creatorInput) elements.creatorInput.value = '';
  
  elements.checkbox.style.background = '#fff';
  elements.checkbox.style.borderColor = '#95929e';
  elements.checkbox.innerHTML = '';
  
  const indicator = elements.audioSection.querySelector('.audio-file-indicator');
  if (indicator) indicator.remove();
  elements.audioSection.style.position = '';
  
  updateImageDisplay();
  updateSubmitButtonState();
  hideMessages();
  
  console.log('🔄 Form reset');
}

// =================== グローバル関数 ===================

// Global functions for onclick handlers
window.removeImage = removeImage;
window.stopRecording = stopRecording;
window.copyShareUrl = copyShareUrl;

// Debug functions
window.resetApp = () => location.reload();
window.getAppState = () => appState;

// Error handling
window.addEventListener('error', function(e) {
  console.error('💥 Application error:', e.error);
  showError('An unexpected error occurred. Please refresh the page.');
});

console.log('📚 reMind App loaded successfully - Ready for Firebase + Cloudinary!');