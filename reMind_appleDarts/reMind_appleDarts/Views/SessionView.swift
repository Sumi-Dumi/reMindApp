//
//  SessionView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//


import SwiftUI
import AVKit


struct SessionView: View {
    @State private var progress: Float = 0.6
    
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            
            VideoView()
            
            
            
            // UI
            VStack {
                // Progress Bars
                HStack(spacing: 6) {
                    ForEach(0..<5) { index in
                        Capsule()
                            .frame(height: 4)
                            .foregroundColor(index < 1 ? .white : .white.opacity(0.3)) // adjust based on progress
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Subtitle
                Text("Now. Tell me 3 things you hear")
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
                
                ZStack {
                    // Mic button
                    Button(action: {}) {
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
                    
                    // Buttons around mic
                    HStack {
                        // Left: Keyboard
                        Button(action: {}) {
                            Image(systemName: "keyboard")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.leading, 24) // Adjusted from 12 to 24 for balance
                        
                        Spacer()
                        
                        // Right: Delete + Check
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "delete.left.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {}) {
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

