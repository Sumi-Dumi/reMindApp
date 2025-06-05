import SwiftUI
import AVKit

struct SessionView: View {
    @State private var currentStep: Int = 0
    @State private var recorded: Bool = false
    @State private var navigateToBreak = false
    @State private var isKeyboardMode: Bool = false
    @State private var inputText: String = ""
    @State private var tags: [String] = []

    private var progress: Float {
        switch currentStep {
        case 0: return 0.0
        case 1: return 0.2
        case 2: return 0.2
        case 3: return 0.4
        case 4: return 0.6
        case 5: return 0.8
        case 6: return 1.0
        default: return 1.0
        }
    }

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
        NavigationStack {
            ZStack {
                Color.gray.ignoresSafeArea()
                VideoView().ignoresSafeArea()

                VStack {
                    // Top Progress
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

                    // Prompt
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

                    Spacer()

                    if isKeyboardMode {
                        VStack(spacing: 16) {
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
                        }
                    }

                    Spacer()

                    // Bottom Controls including Mic or Keyboard in same row
                    HStack(spacing: 40) {
    if isKeyboardMode {
        // Left: white mic icon
        Button(action: {
            isKeyboardMode.toggle()
        }) {
            Image(systemName: "mic.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(.white.opacity(0.8))
        }

        // Center: black background keyboard icon
        Button(action: {
            // Do nothing
        }) {
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
    } else {
        // Left: white keyboard icon
        Button(action: {
            isKeyboardMode.toggle()
        }) {
            Image(systemName: "keyboard")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(.white.opacity(0.8))
        }

        // Center: black background mic icon (RecordButton)
        RecordButton(recorded: $recorded)
    }

    // Right controls (delete + check)
    HStack(spacing: 16) {
        Button(action: {
            recorded = false
            inputText = ""
            tags.removeAll()
        }) {
            Image(systemName: "delete.left.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
        }

        Button(action: {
            if currentStep < prompts.count - 1 {
                currentStep += 1
                recorded = false
                inputText = ""
                tags.removeAll()
            } else {
                navigateToBreak = true
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
.frame(height: 60)
.frame(maxWidth: .infinity)
.padding(.bottom, 24)
                }

                NavigationLink(destination: Break(), isActive: $navigateToBreak) {
                    EmptyView()
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
