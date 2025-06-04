/**
 * reMind App with Firebase CLI Integration
 * Uses Firebase Hosting auto-configuration
 */

// App state
let appState = {
  isChecked: false,
  hasImages: false,
  hasAudio: false,
  images: [],
  audioBlob: null,
  recipientName: '',
  isUploading: false
};

// DOM elements
let elements = {};

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
  console.log('Starting reMind App with Firebase CLI...');
  
  // Wait for Firebase to initialize
  if (typeof firebase !== 'undefined') {
    initializeApp();
  } else {
    console.log('Waiting for Firebase to load...');
    setTimeout(() => {
      if (typeof firebase !== 'undefined') {
        initializeApp();
      } else {
        console.error('Firebase failed to load');
        showError('Firebase configuration error. Please refresh the page.');
      }
    }, 2000);
  }
});

function initializeApp() {
  // Firebase is auto-configured by CLI
  console.log('Firebase initialized via CLI');
  console.log('Project ID:', firebase.app().options.projectId);
  
  getDOMElements();
  setupEventListeners();
  enhanceImageSection();
  updateSubmitButton();
  
  console.log('reMind App ready!');
}

function getDOMElements() {
  elements = {
    recipientInput: document.getElementById('recipientName'),
    imageSection: document.querySelector('.image'),
    audioSection: document.querySelector('.mic-audio'),
    checkbox: document.querySelector('.checkbox'),
    agreeTerms: document.querySelector('.agree-terms'),
    submitBtn: document.getElementById('submitBtn'),
    fileInput: document.getElementById('imageFileInput'),
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
}

function setupEventListeners() {
  // Recipient name
  elements.recipientInput.addEventListener('input', (e) => {
    appState.recipientName = e.target.value.trim();
    updateSubmitButton();
  });

  // File input
  elements.fileInput.addEventListener('change', handleImageSelect);

  // Checkbox
  elements.agreeTerms.addEventListener('click', toggleCheckbox);

  // Audio recording
  elements.audioSection.addEventListener('click', handleAudioClick);

  // Submit
  elements.submitBtn.addEventListener('click', handleSubmit);
}

function enhanceImageSection() {
  elements.imageSection.style.cursor = 'pointer';
  elements.imageSection.addEventListener('click', () => {
    if (appState.images.length < 3) {
      elements.fileInput.click();
    }
  });

  // Drag & drop
  elements.imageSection.addEventListener('dragover', (e) => {
    e.preventDefault();
    elements.imageSection.style.backgroundColor = '#f0f9e8';
  });

  elements.imageSection.addEventListener('dragleave', () => {
    elements.imageSection.style.backgroundColor = '';
  });

  elements.imageSection.addEventListener('drop', (e) => {
    e.preventDefault();
    elements.imageSection.style.backgroundColor = '';
    
    const files = Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/'));
    addImages(files);
  });
}

function handleImageSelect(e) {
  const files = Array.from(e.target.files);
  addImages(files);
  e.target.value = ''; // Reset
}

function addImages(files) {
  files.forEach(file => {
    if (appState.images.length < 3) {
      const reader = new FileReader();
      reader.onload = (e) => {
        appState.images.push({
          id: Date.now() + Math.random(),
          file: file,
          dataUrl: e.target.result,
          name: file.name
        });
        updateImageDisplay();
        updateSubmitButton();
      };
      reader.readAsDataURL(file);
    }
  });
}

function updateImageDisplay() {
  const count = appState.images.length;
  
  if (count === 0) {
    elements.imageSection.innerHTML = `
      <img src="./src/image/image-add.png" alt="addimage" />
      <p>Tap to add images or drag and drop</p>
    `;
    appState.hasImages = false;
  } else {
    appState.hasImages = true;
    elements.imageSection.innerHTML = `
      <div style="display: flex; gap: 8px; align-items: center; padding: 16px;">
        ${appState.images.map(img => `
          <div style="position: relative; width: 80px; height: 80px;">
            <img src="${img.dataUrl}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 8px; border: 2px solid #dcec7d;">
            <button onclick="removeImage('${img.id}')" style="position: absolute; top: -8px; right: -8px; width: 24px; height: 24px; background: #ef4444; color: white; border: none; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center;">×</button>
          </div>
        `).join('')}
        ${count < 3 ? `
          <button onclick="document.getElementById('imageFileInput').click()" style="width: 80px; height: 80px; border: 2px dashed #ccc; background: white; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 24px; color: #ccc;">+</button>
        ` : ''}
        <div style="margin-left: auto; text-align: center; color: #666; font-size: 12px;">
          ${count}/3 images
          <div style="margin-top: 4px; color: ${count >= 1 ? '#22c55e' : '#ef4444'};">
            ${count >= 1 ? '✓ Ready' : 'Need 1+'}
          </div>
        </div>
      </div>
    `;
  }
}

function removeImage(imageId) {
  appState.images = appState.images.filter(img => img.id != imageId);
  updateImageDisplay();
  updateSubmitButton();
}

function handleAudioClick() {
  if (appState.hasAudio) {
    // Reset audio
    appState.hasAudio = false;
    appState.audioBlob = null;
    resetAudioDisplay();
  } else {
    startRecording();
  }
}

function startRecording() {
  navigator.mediaDevices.getUserMedia({ audio: true })
    .then(stream => {
      const mediaRecorder = new MediaRecorder(stream);
      const chunks = [];

      mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) chunks.push(e.data);
      };

      mediaRecorder.onstop = () => {
        appState.audioBlob = new Blob(chunks, { type: 'audio/wav' });
        appState.hasAudio = true;
        stream.getTracks().forEach(track => track.stop());
        closeRecordingModal();
        showAudioSuccess();
        updateSubmitButton();
      };

      showRecordingModal(mediaRecorder);
      mediaRecorder.start();
    })
    .catch(err => {
      console.error('Microphone error:', err);
      showError('Cannot access microphone. Please allow microphone access.');
    });
}

function showRecordingModal(mediaRecorder) {
  const modal = document.createElement('div');
  modal.id = 'recordingModal';
  modal.style.cssText = `
    position: fixed; top: 0; left: 0; right: 0; bottom: 0; 
    background: rgba(0,0,0,0.8); display: flex; align-items: center; 
    justify-content: center; z-index: 1000;
  `;
  
  modal.innerHTML = `
    <div style="background: white; padding: 40px; border-radius: 16px; text-align: center; max-width: 400px;">
      <div style="width: 80px; height: 80px; background: #ef4444; border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; animation: pulse 1.5s infinite;">
        <div style="width: 20px; height: 20px; background: white; border-radius: 50%;"></div>
      </div>
      <h2>Recording...</h2>
      <p>Speak clearly into your microphone</p>
      <button onclick="stopRecording()" style="background: #ef4444; color: white; border: none; padding: 12px 24px; border-radius: 8px; cursor: pointer; font-size: 16px;">Stop Recording</button>
    </div>
  `;
  
  document.body.appendChild(modal);
  window.currentMediaRecorder = mediaRecorder;
}

function stopRecording() {
  if (window.currentMediaRecorder) {
    window.currentMediaRecorder.stop();
  }
}

function closeRecordingModal() {
  const modal = document.getElementById('recordingModal');
  if (modal) modal.remove();
}

function showAudioSuccess() {
  const indicator = document.createElement('div');
  indicator.className = 'audio-indicator';
  indicator.style.cssText = `
    position: absolute; top: -8px; right: -8px; width: 24px; height: 24px;
    background: #22c55e; border-radius: 50%; color: white; display: flex; 
    align-items: center; justify-content: center; font-size: 12px; z-index: 5;
  `;
  indicator.innerHTML = '🎵';
  
  elements.audioSection.style.position = 'relative';
  elements.audioSection.appendChild(indicator);
}

function resetAudioDisplay() {
  const indicator = elements.audioSection.querySelector('.audio-indicator');
  if (indicator) indicator.remove();
  elements.audioSection.style.position = '';
}

function toggleCheckbox() {
  appState.isChecked = !appState.isChecked;
  
  if (appState.isChecked) {
    elements.checkbox.style.background = '#dcec7d';
    elements.checkbox.innerHTML = '✓';
  } else {
    elements.checkbox.style.background = '#fff';
    elements.checkbox.innerHTML = '';
  }
  
  updateSubmitButton();
}

function updateSubmitButton() {
  const canSubmit = appState.isChecked && 
                   appState.hasImages && 
                   appState.hasAudio &&
                   appState.recipientName.length > 0;
  
  if (canSubmit && !appState.isUploading) {
    elements.submitBtn.style.background = '#dcec7d';
    elements.submitBtn.style.cursor = 'pointer';
    elements.submitBtn.disabled = false;
  } else {
    elements.submitBtn.style.background = '#ccc';
    elements.submitBtn.style.cursor = 'not-allowed';
    elements.submitBtn.disabled = true;
  }
}

async function handleSubmit() {
  if (elements.submitBtn.disabled) return;
  
  appState.isUploading = true;
  elements.submitBtn.innerHTML = 'Uploading...';
  updateSubmitButton();
  
  try {
    hideMessages();
    console.log('Starting upload to Firebase...');
    
    // Generate unique ID
    const avatarId = 'avatar_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    
    // Upload images
    const imageUrls = await uploadImages(avatarId);
    
    // Upload audio
    const audioUrl = await uploadAudio(avatarId);
    
    // Save to Firestore
    await saveToFirestore({
      id: avatarId,
      recipient_name: appState.recipientName,
      image_urls: imageUrls,
      audio_url: audioUrl,
      status: 'ready',
      created_at: firebase.firestore.FieldValue.serverTimestamp(),
      updated_at: firebase.firestore.FieldValue.serverTimestamp()
    });
    
    showSuccess('🎉 Avatar created successfully and saved to Firebase!');
    
    // Reset form after 3 seconds
    setTimeout(resetForm, 3000);
    
  } catch (error) {
    console.error('Upload error:', error);
    showError('Upload failed: ' + error.message);
  } finally {
    appState.isUploading = false;
    elements.submitBtn.innerHTML = 'Submit';
    updateSubmitButton();
  }
}

async function uploadImages(avatarId) {
  const urls = [];
  const total = appState.images.length;
  
  // Show progress
  elements.imageUploadProgress.style.display = 'block';
  
  for (let i = 0; i < appState.images.length; i++) {
    const image = appState.images[i];
    const fileName = `${avatarId}_image_${i}_${Date.now()}.jpg`;
    const ref = firebase.storage().ref().child(`avatars/${fileName}`);
    
    console.log(`Uploading image ${i + 1}/${total}...`);
    elements.imageProgressText.textContent = `Uploading image ${i + 1}/${total}...`;
    
    const snapshot = await ref.put(image.file);
    const url = await snapshot.ref.getDownloadURL();
    urls.push(url);
    
    // Update progress
    const progress = ((i + 1) / total) * 100;
    elements.imageProgressBar.style.width = progress + '%';
  }
  
  elements.imageProgressText.textContent = 'Images uploaded successfully!';
  setTimeout(() => {
    elements.imageUploadProgress.style.display = 'none';
  }, 1000);
  
  return urls;
}

async function uploadAudio(avatarId) {
  // Show progress
  elements.audioUploadProgress.style.display = 'block';
  elements.audioProgressText.textContent = 'Uploading audio...';
  elements.audioProgressBar.style.width = '50%';
  
  const fileName = `${avatarId}_audio_${Date.now()}.wav`;
  const ref = firebase.storage().ref().child(`avatars/${fileName}`);
  
  console.log('Uploading audio...');
  const snapshot = await ref.put(appState.audioBlob);
  const url = await snapshot.ref.getDownloadURL();
  
  elements.audioProgressBar.style.width = '100%';
  elements.audioProgressText.textContent = 'Audio uploaded successfully!';
  
  setTimeout(() => {
    elements.audioUploadProgress.style.display = 'none';
  }, 1000);
  
  return url;
}

async function saveToFirestore(data) {
  console.log('Saving to Firestore...');
  const docRef = await firebase.firestore().collection('avatars').add(data);
  console.log('Saved with ID:', docRef.id);
  return docRef.id;
}

function showSuccess(message) {
  elements.successMsg.style.display = 'block';
  elements.successMsg.querySelector('p:last-child').textContent = message;
  elements.errorMsg.style.display = 'none';
}

function showError(message) {
  elements.errorMsg.style.display = 'block';
  elements.errorText.textContent = message;
  elements.successMsg.style.display = 'none';
}

function hideMessages() {
  elements.successMsg.style.display = 'none';
  elements.errorMsg.style.display = 'none';
}

function resetForm() {
  appState = {
    isChecked: false,
    hasImages: false,
    hasAudio: false,
    images: [],
    audioBlob: null,
    recipientName: '',
    isUploading: false
  };
  
  elements.recipientInput.value = '';
  elements.checkbox.style.background = '#fff';
  elements.checkbox.innerHTML = '';
  
  updateImageDisplay();
  resetAudioDisplay();
  updateSubmitButton();
  hideMessages();
}

// Global functions for onclick handlers
window.removeImage = removeImage;
window.stopRecording = stopRecording;

// Pulse animation for recording modal
const style = document.createElement('style');
style.textContent = `
  @keyframes pulse {
    0%, 100% { transform: scale(1); opacity: 1; }
    50% { transform: scale(1.1); opacity: 0.8; }
  }
`;
document.head.appendChild(style);