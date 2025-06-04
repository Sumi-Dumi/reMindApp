//
//  SessionView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//


import SwiftUI
import AVKit


struct SessionView: View {
    @State private var currentStep: Int = 0
    @State private var progress: Float = 0.2

    let prompts = [
        "Its OKAY, I Got U",
        "Now, What are 5 things you can SEE?",
        "Now, Tell me 4 things you can TOUCH?",
        "You are doing GREAT!!",
        "Now, Tell me 3 things you HEAR?",
        "Focus on 2 things you can SMELL?",
        "Now, Tell me 1 thing you can TASTE?"
    ]
   

    
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            
            // Update this VideoView for different videos per step
            VideoView()
            
            VStack {
                // Progress Bars
                HStack(spacing: 6) {
                    ForEach(0..<5) { index in
                        Capsule()
                            .frame(height: 4)
                            .foregroundColor(Float(index) < progress * 5 ? .white : .white.opacity(0.3))
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Dynamic Prompt Text
                Text(prompts[currentStep])
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .frame(width: 346, height: 64)
                    .background(.black.opacity(0.4))
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .multilineTextAlignment(.center)
                
                Spacer().frame(height: 80)
                
                // Mic + Controls
                ZStack {
                    Button(action: {
                        // Move to next step
                        if currentStep < prompts.count - 1 {
                            currentStep += 1
                            progress += 0.2
                        }
                    }) {
                        Image(systemName: "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                            .padding(.horizontal, 40)
                            .padding(.vertical, 26.66667)
                            .frame(width: 100, height: 100)
                            .background(.black.opacity(0.4))
                            .background(.ultraThinMaterial)
                            .cornerRadius(100)
                    }
                    
                    HStack {
                        Button(action: {
                            // Keyboard action
                        }) {
                            Image(systemName: "keyboard")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                // Delete action
                            }) {
                                Image(systemName: "delete.left.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                // Next step
                                if prompts[currentStep] != "Its OKAY, I Got U" && prompts[currentStep] != "You are doing GREAT!!" {
                                    progress += 0.2
                                }
                                    currentStep += 1                         }) {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                                        .clipShape(Circle())
                                }
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
    }
}


struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}

