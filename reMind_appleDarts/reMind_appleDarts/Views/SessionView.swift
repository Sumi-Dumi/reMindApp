//
//  SessionView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//


import SwiftUI
import AVKit

struct BlobButtonStyle: ButtonStyle {
    @Binding var recorded: Bool
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if configuration.isPressed {
                BlobView(size: 100)

            } else {
                Circle()
                    .fill(Color.black.opacity(0.4))
                    
            }
            if !configuration.isPressed {
                        configuration.label
                            .foregroundColor(Color.primaryGreen)
                                .frame(width: 40, height: 40)
                        }

        }
        .frame(width: 100, height: 100)
    }
}

struct SessionView: View {
    @State private var currentStep: Int = 0
//    @State private var progress: Float = 0.2
    @State private var progress: Float = 0.6
        @State private var recorded: Bool = false

    let prompts = [
        "Its OKAY, I'm here for you",
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
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
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
                    RecordButton(recorded: $recorded)
                    
                    HStack {
                        Button(action: {
                            // Keyboard action
                        }) {
                            Image(systemName: "keyboard")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(15)
                                .foregroundColor(.white.opacity(0.8))
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 30)
                        
                        Spacer()
                        
                        HStack(spacing: 30) {
                            Button(action: {
                                // Delete action
                                recorded = false
                            }) {
//                                Image(systemName: "delete.left.fill")
                                Image("delete")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .padding(10) // Add padding so background looks better
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle()) // Or use .cornerRadius(8) for a rounded rectangle
                                        .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                // Next step
                                if prompts[currentStep] != "Its OKAY, I'm here for you" && prompts[currentStep] != "You are doing GREAT!!" {
                                    progress += 0.2
                                }
                                    currentStep += 1
                                    recorded = false}) {
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
                    .padding(.horizontal, 30)
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

