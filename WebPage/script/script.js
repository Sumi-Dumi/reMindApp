/**
 * reMind App - Interactive Functionality
 * Script for existing HTML and CSS structure
 */

// Application state
let appState = {
  isChecked: false,
  hasImages: false,
  hasAudio: false,
  isSubmitting: false
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
  
  // Initialize UI state
  updateSubmitButtonState();
  
  console.log('reMind App initialized');
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
  
  // Image upload functionality
  if (elements.imageSection) {
    elements.imageSection.addEventListener('click', handleImageUpload);
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
 * Handle image upload simulation
 */
function handleImageUpload() {
  if (appState.hasImages) return; // Prevent multiple uploads
  
  appState.hasImages = true;
  
  // Update visual state
  elements.imageSection.style.borderColor = '#dcec7d';
  elements.imageSection.style.backgroundColor = '#f8fdf4';
  
  // Replace content
  elements.imageSection.innerHTML = `
    <div style="text-align: center; color: #dcec7d;">
      <div style="font-size: 48px; margin-bottom: 8px;">✓</div>
      <div style="font-size: 16px; font-weight: 590;">3 images uploaded</div>
    </div>
  `;
  
  // Add success animation
  animateSuccess(elements.imageSection);
  
  console.log('Images uploaded');
  updateSubmitButtonState();
}

/**
 * Handle audio recording simulation
 */
function handleAudioRecord() {
  if (appState.hasAudio) return; // Prevent multiple recordings
  
  appState.hasAudio = true;
  
  // Update visual state
  elements.audioSection.style.backgroundColor = '#f8fdf4';
  elements.audioSection.style.borderRadius = '8px';
  elements.audioSection.style.padding = '16px';
  
  // Replace content
  elements.audioSection.innerHTML = `
    <div style="color: #dcec7d; font-size: 24px;">🎵</div>
    <div style="color: #dcec7d; font-size: 16px; font-weight: 590;">Audio recorded (1:00)</div>
  `;
  
  // Add success animation
  animateSuccess(elements.audioSection);
  
  console.log('Audio recorded');
  updateSubmitButtonState();
}

/**
 * Update submit button state based on form completion
 */
function updateSubmitButtonState() {
  const canSubmit = appState.isChecked && appState.hasImages && appState.hasAudio;
  
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
    console.log('Form submitted successfully');
    navigateToThankYou();
  }, 2000);
}

/**
 * Navigate to thank you page
 */
function navigateToThankYou() {
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
    
    // Add success animation to thank you page
    const thankYouSection = elements.mainContainer.querySelector('.thanykou-section');
    animateSuccess(thankYouSection);
    
    console.log('Navigated to thank you page');
  }, 500);
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
    isSubmitting: false
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

// Expose utility functions to global scope for debugging
window.resetApp = resetApp;
window.getAppState = getAppState;

// Add some basic error handling
window.addEventListener('error', function(e) {
  console.error('Application error:', e.error);
});

// Log when script is loaded
console.log('reMind App script loaded successfully');