


import SwiftUI
import AVKit

struct TagsView: View {
    let tags: [String]
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    
    init(tags: [String], horizontalSpacing: CGFloat = 8, verticalSpacing: CGFloat = 8) {
        self.tags = tags
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    var body: some View {
        
        return ScrollView(.horizontal) {
            HStack {
                ForEach(tags.reversed(), id: \.self) { tag in
                    tagView(for: tag)
                }
            }
        }
    }
    
    private func tagView(for text: String) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .foregroundColor(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundColor(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
    }
}

struct SessionViewKeyboard: View {
    @State private var inputText: String = ""
    @State private var tags: [String] = []
    
    var body: some View {
        ZStack {
            // Background
            VideoView()
                .ignoresSafeArea()
            
            // Top progress bar
            VStack {
                HStack(spacing: 6) {
                    ForEach(0..<5) { index in
                        Capsule()
                            .frame(height: 4)
                            .foregroundColor(index < 1 ? .white : .white.opacity(0.3))
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)
                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .allowsHitTesting(false)
            
            // Middle prompt + input
            VStack(spacing: 16) {
                Spacer().frame(height: 400) // Adjust this for vertical position
                
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
                
                TextField("Type Here...", text: $inputText, onCommit: {
                    if !inputText.isEmpty && tags.count < 5 {
                        tags.append(inputText)
                        inputText = ""
                    }
                })
                .padding()
                .frame(width: 346, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .foregroundColor(.black)
                TagsView(tags: tags)
                    .contentMargins(.horizontal, 24)
                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            

            VStack {
                Spacer()
                
                ZStack {
                    Button(action: {}) {
                        Image(systemName: "keyboard")
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
                        Button(action: {}) {
                            Image(systemName: "mic.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
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
                .padding(.bottom, 16)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .allowsHitTesting(false)
        }
    }
}

struct SessionViewKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        SessionViewKeyboard()
    }
}
