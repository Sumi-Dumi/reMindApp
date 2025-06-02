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
                            .foregroundColor(index < 1 ? .white : .black.opacity(0.3)) // adjust based on progress
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Subtitle
                Text("Now. Tell me 3 things you hear")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 80)
                
                // Button Allignment
                HStack {
                    // keyboard
                    Button(action: {}) {
                        Image(systemName: "keyboard")
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // mic
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                            .frame(width: 50, height: 50)
                            .background(.black)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    HStack{
                        // close
                        Button(action: {}) {
                            Image(systemName: "delete.left.fill")
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                        }
                        
                        // check
                        Button(action: {}) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                                .frame(width: 28, height: 28)
                                .background(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                                .clipShape(Circle())
                        }
                        
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
    
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}
