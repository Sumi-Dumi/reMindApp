


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
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lastHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                tagView(for: tag)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > UIScreen.main.bounds.width - 48 {
                            width = 0
                            height -= lastHeight + verticalSpacing
                            totalHeight += lastHeight + verticalSpacing
                        }
                        let result = width
                        if tag == tags.last {
                            width = 0
                        } else {
                            width -= d.width + horizontalSpacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { d in
                        let result = height
                        lastHeight = d.height
                        if tag == tags.first {
                            totalHeight = d.height
                        }
                        return result
                    }
            }
        }
        .frame(maxWidth: .infinity, minHeight: totalHeight, alignment: .topLeading)
        .padding(.vertical, 4)
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
        @State private var currentStep: Int = 0
        @State private var progress: Float = 0.2
        @State private var showMicView = false

        let prompts = [
            "It' okay, I got you",
            "Now, What are 5 things you can SEE?",
            "Now, Tell me 4 things you can TOUCH?",
            "You are doing GREAT!!",
            "Now, Tell me 3 things you HEAR?",
            "Focus on 2 things you can SMELL?",
            "Now, Tell me 1 thing you can TASTE?"
        ]

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
                                .foregroundColor(Float(index) < progress * 5 ? .white : .white.opacity(0.3))
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
                    Spacer().frame(height: 400)

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

                    TextField("Type Here...", text: $inputText, onCommit: {
                        if !inputText.isEmpty && tags.count < 5 {
                            tags.append(inputText)
                            inputText = ""
                        }
                    })
                    .padding()
                    .frame(width: 346, height: 64)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.5), lineWidth: 1))
                    .foregroundColor(.black)

                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)

                // Fixed-position TagsView (above mic, below input field)
                VStack {
                    Spacer().frame(height: 580)

                    TagsView(tags: tags)
                        .frame(width: 346, height: 100, alignment: .topLeading)
                        .clipped()
                        .padding(.horizontal, 24)

                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .allowsHitTesting(false)

                // Bottom mic + buttons
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
                            Button(action: {
                                showMicView = true
                            }) {
                                Image(systemName: "mic.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.leading, 24)
                            .fullScreenCover(isPresented: $showMicView) {
                                SessionView()
                            }

                            Spacer()

                            HStack(spacing: 16) {
                                Button(action: {
                                    if !tags.isEmpty {
                                        tags.removeLast()
                                    }
                                }) {
                                    Image(systemName: "delete.left.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.white)
                                }

                                Button(action: {
                                    if currentStep < prompts.count - 1 {
                                        if prompts[currentStep] != "Its OKAY, I Got U" && prompts[currentStep] != "You are doing GREAT!!" {
                                            
                                            progress += 0.2
                                            
                                        }
                                        
                                        currentStep += 1
                                    }
                                    
                                }) {
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
            }
        }
    }

struct SessionViewKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        SessionViewKeyboard()
    }
}
