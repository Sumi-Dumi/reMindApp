/**
 * audioHandler.js - 音声処理機能
 */

import { APP_CONFIG } from './config.js';
import { appState } from './state.js';
import { domManager } from './dom.js';
import { showError } from './utils.js';

export class AudioHandler {
  constructor() {
    this.recordingPopup = null;
  }

  // 音声記録の処理
  async handleAudioRecord() {
    if (appState.get('hasAudio')) {
      this.clearAudio();
      return;
    }
    
    if (appState.get('isRecording')) {
      this.stopRecording();
    } else {
      await this.startRecording();
    }
  }

  // 音声データをクリア
  clearAudio() {
    appState.setAudio(false);
    
    const audioURL = appState.get('audioURL');
    if (audioURL) {
      URL.revokeObjectURL(audioURL);
    }
    
    const audioSection = domManager.get('audioSection');
    const indicator = audioSection?.querySelector('.audio-file-indicator');
    if (indicator) {
      indicator.remove();
    }
  }

  // 録音開始
  async startRecording() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ 
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          sampleRate: APP_CONFIG.audioSampleRate
        }
      });
      
      const mediaRecorder = new MediaRecorder(stream, {
        mimeType: APP_CONFIG.audioMimeType
      });
      
      const audioChunks = [];
      
      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          audioChunks.push(event.data);
        }
      };
      
      mediaRecorder.onstop = () => {
        const audioBlob = new Blob(audioChunks, { type: APP_CONFIG.audioMimeType });
        const audioURL = URL.createObjectURL(audioBlob);
        
        appState.setAudio(true, audioBlob, audioURL);
        
        stream.getTracks().forEach(track => track.stop());
        this.closeRecordingPopup();
        this.showAudioFileIndicator();
        
        console.log(`🎵 Audio recorded: ${(audioBlob.size / 1024 / 1024).toFixed(2)}MB`);
      };
      
      mediaRecorder.start();
      appState.setRecording(true, mediaRecorder);
      appState.set('audioChunks', audioChunks);
      
      this.showRecordingPopup();
      console.log('🎤 Recording started');
      
    } catch (error) {
      console.error('🎤 Error accessing microphone:', error);
      showError('Cannot access mic, allow the mic using');
    }
  }

  // 録音停止
  stopRecording() {
    const mediaRecorder = appState.get('mediaRecorder');
    if (mediaRecorder && appState.get('isRecording')) {
      mediaRecorder.stop();
      appState.setRecording(false);
      console.log('🎤 Recording stopped');
    }
  }

  // 録音ポップアップ表示
  showRecordingPopup() {
    this.recordingPopup = document.createElement('div');
    this.recordingPopup.id = 'recordingPopup';
    this.recordingPopup.style.cssText = `
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: rgba(0, 0, 0, 0.8); display: flex; align-items: center;
      justify-content: center; z-index: 10000;
    `;
    
    this.recordingPopup.innerHTML = `
      <div style="background: white; border-radius: 20px; padding: 40px; text-align: center; max-width: 400px;">
        <div style="width: 80px; height: 80px; background: #ef4444; border-radius: 50%; margin: 0 auto 24px; display: flex; align-items: center; justify-content: center; animation: pulse 2s ease-in-out infinite;">
          <div style="width: 16px; height: 16px; background: white; border-radius: 50%;"></div>
        </div>
        <h2 style="color: #1f2937; font-size: 24px; margin: 0 0 8px 0;">Recoding...</h2>
        <p style="color: #6b7280; margin: 0 0 32px 0;">Hi [Your Name], it’s me.<br> I just wanted to say I’m here with you. If you’re feeling overwhelmed or anxious right now, take a deep breath. You're not alone, and you’re going to be okay.<br>

Close your eyes for a second, and remember a moment when you felt safe, warm, or happy. Hold onto that feeling. Let it ground you.<br>

You’ve gotten through hard days before, and I know you’ll get through this too. I’m so proud of you. Whatever you’re facing right now, just know that you matter, and you are deeply loved.
Take your time. There’s no rush. You’ve got this.</p>
        <button onclick="audioHandler.stopRecording()" style="background: #ef4444; color: white; border: none; border-radius: 12px; padding: 16px 32px; font-size: 16px; cursor: pointer;">
          Stop
        </button>
      </div>
    `;
    
    document.body.appendChild(this.recordingPopup);
    
    // CSS アニメーション追加
    if (!document.querySelector('#recordingStyles')) {
      const style = document.createElement('style');
      style.id = 'recordingStyles';
      style.textContent = `
        @keyframes pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.05); } }
      `;
      document.head.appendChild(style);
    }
  }

  // 録音ポップアップを閉じる
  closeRecordingPopup() {
    if (this.recordingPopup) {
      this.recordingPopup.remove();
      this.recordingPopup = null;
    }
  }

  // 音声ファイルインジケーター表示
  showAudioFileIndicator() {
    const audioSection = domManager.get('audioSection');
    if (!audioSection) return;

    const existingIndicator = audioSection.querySelector('.audio-file-indicator');
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
    
    audioSection.style.position = 'relative';
    audioSection.appendChild(indicator);
  }
}

// シングルトンインスタンス
export const audioHandler = new AudioHandler();

// グローバル関数（onclick用）
window.audioHandler = audioHandler;