/**
 * reMind App - Enhanced with Image Upload Functionality
 * Maintains original HTML/CSS structure while adding upload features
 */

// Application state
let appState = {
  isChecked: false,
  hasImages: false,
  hasAudio: false,
  isSubmitting: false,
  images: [],
  maxImages: 3,
  // Audio recording state
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
  initializeApp();
});

/**
 * Initialize all app functionality
 */
function initializeApp() {
  // Get DOM elements
  getDOMElements();
  
  // Setup event listeners
  setupEventListeners();
  
  // Enhance image section for upload
  enhanceImageSection();
  
  // Initialize UI state
  updateSubmitButtonState();
  
  console.log('reMind App with enhanced image upload initialized');
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
    mobileInterface: document.querySelector('.mobile-interface')
  };
  
  // Verify all elements exist
  for (let key in elements) {
    if (!elements[key]) {
      console.warn(`Element not found: ${key}`);
    }
  }
}

/**
 * Enhance the existing image section with upload functionality
 */
function enhanceImageSection() {
  // Create hidden file input
  const fileInput = document.createElement('input');
  fileInput.type = 'file';
  fileInput.accept = 'image/*';
  fileInput.multiple = true;
  fileInput.style.display = 'none';
  fileInput.id = 'imageFileInput';
  document.body.appendChild(fileInput);
  
  // Store original content for reset
  const originalContent = elements.imageSection.innerHTML;
  
  // Add upload functionality to existing image section
  elements.imageSection.style.cursor = 'pointer';
  elements.imageSection.style.transition = 'all 0.3s ease';
  
  // File input change handler
  fileInput.addEventListener('change', function(e) {
    const files = Array.from(e.target.files);
    processImageFiles(files);
    e.target.value = ''; // Reset input
  });
  
  // Click handler for image section
  elements.imageSection.addEventListener('click', function() {
    if (appState.images.length < appState.maxImages) {
      fileInput.click();
    }
  });
  
  // Drag and drop functionality
  setupDragAndDrop(elements.imageSection);
  
  // Store references
  elements.fileInput = fileInput;
  elements.originalImageContent = originalContent;
}

/**
 * Setup drag and drop functionality
 */
function setupDragAndDrop(dropZone) {
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, preventDefaults);
  });
  
  ['dragenter', 'dragover'].forEach(eventName => {
    dropZone.addEventListener(eventName, highlight);
  });
  
  ['dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, unhighlight);
  });
  
  dropZone.addEventListener('drop', handleDrop);
  
  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }
  
  function highlight() {
    dropZone.style.borderColor = '#dcec7d';
    dropZone.style.backgroundColor = '#f8fdf4';
    dropZone.style.transform = 'scale(1.02)';
  }
  
  function unhighlight() {
    dropZone.style.borderColor = 'var(--Neutral-300, #b8c0cc)';
    dropZone.style.backgroundColor = '';
    dropZone.style.transform = 'scale(1)';
  }
  
  function handleDrop(e) {
    const files = Array.from(e.dataTransfer.files);
    const imageFiles = files.filter(file => file.type.startsWith('image/'));
    processImageFiles(imageFiles);
  }
}

/**
 * Process uploaded image files
 */
function processImageFiles(files) {
  files.forEach(file => {
    if (appState.images.length < appState.maxImages) {
      addImageToState(file);
    }
  });
  
  updateImageDisplay();
}

/**
 * Add image to application state
 */
function addImageToState(file) {
  const reader = new FileReader();
  reader.onload = function(e) {
    const imageData = {
      id: Date.now() + Math.random(),
      file: file,
      dataUrl: e.target.result,
      name: file.name
    };
    
    appState.images.push(imageData);
    updateImageDisplay();
  };
  reader.readAsDataURL(file);
}

/**
 * Update image section display based on uploaded images
 */
function updateImageDisplay() {
  const imageCount = appState.images.length;
  
  if (imageCount === 0) {
    // Show original upload prompt
    elements.imageSection.innerHTML = elements.originalImageContent;
    appState.hasImages = false;
  } else {
    // Show thumbnails with original styling
    appState.hasImages = true;
    
    elements.imageSection.innerHTML = `
      <div style="display: flex; align-items: center; gap: 12px; padding: 8px; min-height: 224px;">
        <div style="display: flex; gap: 8px; flex: 1; align-items: center;">
          ${appState.images.map(img => `
            <div style="position: relative; width: 70px; height: 70px; border-radius: 8px; overflow: hidden; border: 2px solid #e2e8f0; flex-shrink: 0;">
              <img src="${img.dataUrl}" alt="${img.name}" style="width: 100%; height: 100%; object-fit: cover;">
              <button onclick="removeImage('${img.id}')" style="
                position: absolute; top: -6px; right: -6px; width: 20px; height: 20px;
                background: #ef4444; border-radius: 50%; color: white; border: none;
                cursor: pointer; display: flex; align-items: center; justify-content: center;
                font-size: 12px; z-index: 10; transition: all 0.2s ease;
              ">×</button>
            </div>
          `).join('')}
          ${imageCount < appState.maxImages ? `
            <button onclick="document.getElementById('imageFileInput').click()" style="
              width: 70px; height: 70px; border: 2px dashed #b8c0cc; border-radius: 8px;
              background: white; cursor: pointer; display: flex; align-items: center;
              justify-content: center; transition: all 0.3s ease; flex-shrink: 0;
            ">
              <span style="font-size: 24px; color: #b8c0cc;">+</span>
            </button>
          ` : ''}
        </div>
        <div style="margin-left: auto; text-align: center; color: #64748b; font-size: 12px;">
          <div style="margin-bottom: 8px;">${imageCount}/${appState.maxImages}</div>
          <div style="width: 60px; height: 4px; background: #e2e8f0; border-radius: 2px; overflow: hidden;">
            <div style="height: 100%; background: ${imageCount >= 1 ? '#dcec7d' : '#e2e8f0'}; width: ${(imageCount / appState.maxImages) * 100}%; transition: width 0.3s ease;"></div>
          </div>
          ${imageCount >= 1 ? '<div style="margin-top: 4px; color: #22c55e; font-size: 10px;">✓ Ready</div>' : '<div style="margin-top: 4px; color: #ef4444; font-size: 10px;">Need 1+</div>'}
        </div>
      </div>

    `;
  }
  
  updateSubmitButtonState();
}

/**
 * Remove image from state and update display
 */
function removeImage(imageId) {
  appState.images = appState.images.filter(img => img.id != imageId);
  updateImageDisplay();
}

/**
 * Setup all event listeners
 */
function setupEventListeners() {
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
  
  // Audio recording functionality
  if (elements.audioSection) {
    elements.audioSection.addEventListener('click', handleAudioRecord);
  }
  
  // Submit button functionality
  if (elements.submitButton) {
    elements.submitButton.addEventListener('click', handleSubmit);
  }
  
  // Keyboard accessibility
  document.addEventListener('keydown', handleKeyboardInput);
}

/**
 * Toggle checkbox state with visual feedback
 */
function toggleCheckbox() {
  appState.isChecked = !appState.isChecked;
  
  if (appState.isChecked) {
    // Add checked state
    elements.checkbox.style.background = '#dcec7d';
    elements.checkbox.style.borderColor = '#dcec7d';
    elements.checkbox.innerHTML = '<span style="color: #000; font-weight: bold; font-size: 12px;">✓</span>';
    
    // Add animation
    elements.checkbox.style.transform = 'scale(1.1)';
    setTimeout(() => {
      elements.checkbox.style.transform = 'scale(1)';
    }, 150);
    
    console.log('Terms accepted');
  } else {
    // Remove checked state
    elements.checkbox.style.background = '#fff';
    elements.checkbox.style.borderColor = '#95929e';
    elements.checkbox.innerHTML = '';
    
    console.log('Terms unchecked');
  }
  
  updateSubmitButtonState();
}

/**
 * Handle audio recording with microphone access
 */
async function handleAudioRecord() {
  // If already has audio, replace it (start new recording)
  if (appState.hasAudio) {
    // Clear existing audio
    appState.hasAudio = false;
    appState.audioBlob = null;
    if (appState.audioURL) {
      URL.revokeObjectURL(appState.audioURL);
      appState.audioURL = null;
    }
    
    // Remove file indicator
    const indicator = elements.audioSection.querySelector('.audio-file-indicator');
    if (indicator) {
      indicator.remove();
    }
  }
  
  if (appState.isRecording) {
    stopRecording();
  } else {
    await startRecording();
  }
}

/**
 * Start audio recording
 */
async function startRecording() {
  try {
    // Request microphone permission
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    
    // Create MediaRecorder
    appState.mediaRecorder = new MediaRecorder(stream);
    appState.audioChunks = [];
    
    // Setup event handlers
    appState.mediaRecorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        appState.audioChunks.push(event.data);
      }
    };
    
    appState.mediaRecorder.onstop = () => {
      // Create audio blob
      appState.audioBlob = new Blob(appState.audioChunks, { type: 'audio/wav' });
      appState.audioURL = URL.createObjectURL(appState.audioBlob);
      
      // Stop all tracks
      stream.getTracks().forEach(track => track.stop());
      
      // Close recording popup
      closeRecordingPopup();
      
      // Update UI to show file indicator
      showAudioFileIndicator();
    };
    
    // Start recording
    appState.mediaRecorder.start();
    appState.isRecording = true;
    appState.recordingStartTime = Date.now();
    
    // Show recording popup
    showRecordingPopup();
    
    console.log('Recording started');
    
  } catch (error) {
    console.error('Error accessing microphone:', error);
    showMicrophoneError();
  }
}

/**
 * Stop audio recording
 */
function stopRecording() {
  if (appState.mediaRecorder && appState.isRecording) {
    appState.mediaRecorder.stop();
    appState.isRecording = false;
    
    console.log('Recording stopped');
  }
}

/**
 * Show recording popup
 */
function showRecordingPopup() {
  // Create popup overlay
  const popup = document.createElement('div');
  popup.id = 'recordingPopup';
  popup.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.8);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10000;
    animation: fadeIn 0.3s ease;
  `;
  
  // Create popup content
  popup.innerHTML = `
    <div style="
      background: white;
      border-radius: 20px;
      padding: 40px;
      text-align: center;
      min-width: 180px;
      max-width: 400px;
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
      animation: slideUp 0.3s ease;
    ">
      <div style="
        width: 80px;
        height: 80px;
        background: #ef4444;
        border-radius: 50%;
        margin: 0 auto 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        animation: pulse 2s ease-in-out infinite;
      ">
        <div style="
          width: 16px;
          height: 16px;
          background: white;
          border-radius: 50%;
        "></div>
      </div>
      
      <h2 style="
        color: #1f2937;
        font-size: 24px;
        font-weight: 600;
        margin: 0 0 8px 0;
        font-family: 'Inter', sans-serif;
      ">Recording...</h2>
      
      <p style="
        color: #6b7280;
        font-size: 16px;
        margin: 0 0 32px 0;
        font-family: 'Inter', sans-serif;
      ">Speak clearly into your microphone</p>

            <h2 style="
        color: #1f2937;
        font-size: 24px;
        font-weight: 600;
        margin: 0 0 8px 0;
        font-family: 'Inter', sans-serif;
      ">Script</h2>
      
      <p style="
        color: #6b7280;
        font-size: 16px;
        margin: 0 0 32px 0;
        font-family: 'Inter', sans-serif;
      ">“Hi [Name], it’s me.<br> I just wanted to say I’m here with you. If you’re feeling overwhelmed or anxious right now, take a deep breath. You're not alone, and you’re going to be okay.<br>

Close your eyes for a second, and remember a moment when you felt safe, warm, or happy. Hold onto that feeling. Let it ground you.<br>

You’ve gotten through hard days before, and I know you’ll get through this too. I’m so proud of you. Whatever you’re facing right now, just know that you matter, and you are deeply loved.
Take your time. There’s no rush. You’ve got this.”</p>

      
      <button onclick="window.stopRecording()" style="
        background: #ef4444;
        color: white;
        border: none;
        border-radius: 12px;
        padding: 16px 32px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        font-family: 'Inter', sans-serif;
      " onmouseover="this.style.background='#dc2626'" onmouseout="this.style.background='#ef4444'">
        Stop Recording
      </button>
    </div>
  `;
  
  document.body.appendChild(popup);
  
  // Add styles for animations
  const style = document.createElement('style');
  style.textContent = `
    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
    @keyframes slideUp {
      from { opacity: 0; transform: translateY(50px); }
      to { opacity: 1; transform: translateY(0); }
    }
    @keyframes pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.05); }
    }
  `;
  if (!document.querySelector('#recordingStyles')) {
    style.id = 'recordingStyles';
    document.head.appendChild(style);
  }
}

/**
 * Close recording popup
 */
function closeRecordingPopup() {
  const popup = document.getElementById('recordingPopup');
  if (popup) {
    popup.style.animation = 'fadeOut 0.3s ease';
    setTimeout(() => {
      popup.remove();
    }, 300);
  }
  
  // Add fadeOut animation if not exists
  const existingStyle = document.getElementById('recordingStyles');
  if (existingStyle && !existingStyle.textContent.includes('fadeOut')) {
    existingStyle.textContent += `
      @keyframes fadeOut {
        from { opacity: 1; }
        to { opacity: 0; }
      }
    `;
  }
}

/**
 * Show audio file indicator next to mic button
 */
function showAudioFileIndicator() {
  appState.hasAudio = true;
  
  // Remove existing indicator if any
  const existingIndicator = elements.audioSection.querySelector('.audio-file-indicator');
  if (existingIndicator) {
    existingIndicator.remove();
  }
  
  // Add file indicator
  const indicator = document.createElement('div');
  indicator.className = 'audio-file-indicator';
  indicator.style.cssText = `
    position: absolute;
    top: -8px;
    right: -8px;
    width: 24px;
    height: 24px;
    background: #22c55e;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 12px;
    font-weight: bold;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    z-index: 5;
    animation: bounce 0.5s ease;
  `;
  indicator.innerHTML = '🎵';
  
  // Make audio section relative positioned
  elements.audioSection.style.position = 'relative';
  elements.audioSection.appendChild(indicator);
  
  // Add bounce animation
  const style = document.createElement('style');
  style.textContent = `
    @keyframes bounce {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.2); }
    }
  `;
  if (!document.querySelector('#audioIndicatorStyles')) {
    style.id = 'audioIndicatorStyles';
    document.head.appendChild(style);
  }
  
  updateSubmitButtonState();
  console.log('Audio file indicator shown');
}

/**
 * Show microphone error
 */
function showMicrophoneError() {
  elements.audioSection.style.backgroundColor = '#fef2f2';
  elements.audioSection.style.borderColor = '#fca5a5';
  elements.audioSection.style.border = '2px solid #fca5a5';
  
  elements.audioSection.innerHTML = `
    <div style="display: flex; align-items: center; gap: 16px; width: 100%;">
      <div style="color: #dc2626; font-size: 24px;">❌</div>
      <div style="flex: 1;">
        <div style="color: #dc2626; font-size: 16px; font-weight: 590; margin-bottom: 4px;">
          Microphone access denied
        </div>
        <div style="color: #b91c1c; font-size: 14px;">
          Please allow microphone access and try again
        </div>
      </div>
      <button onclick="window.retryMicrophone()" style="
        background: #dc2626; 
        color: white; 
        border: none; 
        border-radius: 8px; 
        padding: 8px 16px; 
        cursor: pointer; 
        font-size: 14px; 
        font-weight: 600;
      ">
        Retry
      </button>
    </div>
  `;
}

/**
 * Play recorded audio
 */
function playRecording() {
  if (appState.audioURL) {
    const audio = new Audio(appState.audioURL);
    audio.play().catch(error => {
      console.error('Error playing audio:', error);
    });
  }
}

/**
 * Retake recording
 */
function retakeRecording() {
  // Reset audio state
  appState.hasAudio = false;
  appState.audioBlob = null;
  if (appState.audioURL) {
    URL.revokeObjectURL(appState.audioURL);
    appState.audioURL = null;
  }
  
  // Remove file indicator
  const indicator = elements.audioSection.querySelector('.audio-file-indicator');
  if (indicator) {
    indicator.remove();
  }
  
  // Reset audio section style
  elements.audioSection.style.position = '';
  
  updateSubmitButtonState();
}

/**
 * Retry microphone access
 */
function retryMicrophone() {
  // Reset error state
  elements.audioSection.style.backgroundColor = '';
  elements.audioSection.style.borderColor = '';
  elements.audioSection.style.border = '';
  
  elements.audioSection.innerHTML = `
    <img src="./src/image/Mic.png" alt="audio" />
    <span>Tap to record audio</span>
  `;
  
  // Try recording again
  handleAudioRecord();
}

/**
 * Update submit button state based on form completion
 */
function updateSubmitButtonState() {
  const canSubmit = appState.isChecked && 
                   appState.images.length >= 1 && 
                   appState.hasAudio;
  
  if (canSubmit) {
    // Enable button
    elements.submitButton.style.background = '#dcec7d';
    elements.submitButton.style.color = '#000';
    elements.submitButton.style.cursor = 'pointer';
    elements.submitButton.style.opacity = '1';
    elements.submitButton.disabled = false;
    
    // Add hover effect
    elements.submitButton.onmouseenter = function() {
      this.style.background = '#d4e56d';
      this.style.transform = 'translateY(-2px)';
    };
    
    elements.submitButton.onmouseleave = function() {
      this.style.background = '#dcec7d';
      this.style.transform = 'translateY(0)';
    };
    
  } else {
    // Disable button
    elements.submitButton.style.background = '#e5e5e5';
    elements.submitButton.style.color = '#999';
    elements.submitButton.style.cursor = 'not-allowed';
    elements.submitButton.style.opacity = '0.6';
    elements.submitButton.disabled = true;
    
    // Remove hover effect
    elements.submitButton.onmouseenter = null;
    elements.submitButton.onmouseleave = null;
  }
  
  // Add transition effect
  elements.submitButton.style.transition = 'all 0.3s ease';
}

/**
 * Handle form submission with loading and navigation
 */
function handleSubmit() {
  if (elements.submitButton.disabled || appState.isSubmitting) return;
  
  appState.isSubmitting = true;
  
  // Show loading state
  const originalText = elements.submitButton.innerHTML;
  elements.submitButton.innerHTML = `
    <span>Submitting...</span>
    <div style="
      width: 16px; 
      height: 16px; 
      border: 2px solid #fff; 
      border-top: 2px solid #000; 
      border-radius: 50%; 
      animation: spin 1s linear infinite;
      margin-left: 8px;
    "></div>
  `;
  
  // Add spinning animation
  const style = document.createElement('style');
  style.textContent = `
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  `;
  document.head.appendChild(style);
  
  elements.submitButton.disabled = true;
  elements.submitButton.style.cursor = 'not-allowed';
  
  // Simulate processing time then navigate
  setTimeout(() => {
    console.log(`Form submitted successfully with ${appState.images.length} image(s)`);
    navigateToThankYou();
  }, 2000);
}

/**
 * Navigate to thank you page
 */
function navigateToThankYou() {
  // Redirect to thank you page if it exists, otherwise show in-app message
  if (document.querySelector('link[href*="thankyou"]') || window.location.href.includes('thankyou.html')) {
    window.location.href = 'thankyou.html';
  } else {
    // Create thank you page content
    const thankYouHTML = `
      <div class="thanykou-section">
        <div class="thankyou">
          <div style="
            width: 80px; 
            height: 80px; 
            background: #dcec7d; 
            border-radius: 50%; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 40px; 
            color: #000; 
            margin-bottom: 20px;
          ">✓</div>
          <div class="thankyou-text">
            <p class="header-text" style="text-align: center;">Thank you</p>
            <p class="subheader-text" style="text-align: center;">
              You've helped create a moment of calm and connection for someone you love.
              <br><br>
              ${appState.images.length} image(s) and audio have been successfully uploaded.
            </p>
          </div>
        </div>
      </div>
    `;
    
    // Replace main content with thank you page
    elements.mainContainer.style.opacity = '0';
    elements.mainContainer.style.transition = 'opacity 0.5s ease';
    
    setTimeout(() => {
      elements.mainContainer.innerHTML = thankYouHTML;
      elements.mainContainer.style.opacity = '1';
      
      console.log('Navigated to thank you page');
    }, 500);
  }
}

/**
 * Add success animation to element
 */
function animateSuccess(element) {
  element.style.transform = 'scale(0.95)';
  element.style.transition = 'transform 0.3s ease';
  
  setTimeout(() => {
    element.style.transform = 'scale(1)';
  }, 150);
}

/**
 * Handle keyboard input for accessibility
 */
function handleKeyboardInput(event) {
  // Enter or Space on checkbox
  if ((event.key === 'Enter' || event.key === ' ') && 
      event.target === elements.checkbox) {
    event.preventDefault();
    toggleCheckbox();
  }
  
  // Enter on submit button
  if (event.key === 'Enter' && event.target === elements.submitButton) {
    handleSubmit();
  }
}

/**
 * Reset app state (useful for testing)
 */
function resetApp() {
  appState = {
    isChecked: false,
    hasImages: false,
    hasAudio: false,
    isSubmitting: false,
    images: [],
    maxImages: 3
  };
  
  // Reload page to reset UI
  location.reload();
}

/**
 * Get current app state (for debugging)
 */
function getAppState() {
  return appState;
}

// Make functions global for inline onclick handlers
window.removeImage = removeImage;
window.stopRecording = stopRecording;
window.playRecording = playRecording;
window.retakeRecording = retakeRecording;
window.retryMicrophone = retryMicrophone;

// Expose utility functions to global scope for debugging
window.resetApp = resetApp;
window.getAppState = getAppState;

// Add some basic error handling
window.addEventListener('error', function(e) {
  console.error('Application error:', e.error);
});

// Log when script is loaded
console.log('Enhanced reMind App script loaded successfully');