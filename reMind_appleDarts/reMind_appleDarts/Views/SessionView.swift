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
                    .foregroundColor(.green)
                    .frame(width: 40, height: 40)
            }
        }
        .frame(width: 100, height: 100)
    }
}

struct SessionView: View {
    @State private var currentStep: Int = 0
    @State private var recorded: Bool = false
    @State private var navigateToBreak = false

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
        "Its OKAY, I'm here for you",
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
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()

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

                    // Prompt Text
                    Text(prompts[currentStep])
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .frame(width: 346, height: 64)
                        .background(Color.black.opacity(0.4))
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)

                    Spacer().frame(height: 80)

                    // Mic + Controls
                    ZStack {
                        RecordButton(recorded: $recorded)

                        HStack {
                            // Keyboard Button
                            Button(action: {
                                // Handle keyboard tap
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

                            HStack(spacing: 16) {
                                // Delete Button
                                Button(action: {
                                    recorded = false
                                }) {
                                    Image("delete")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                        .padding(10)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                }

                                // Next Step Button
                                Button(action: {
                                    if currentStep < prompts.count - 1 {
                                        currentStep += 1
                                        recorded = false
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
                        .padding(.horizontal, 30)
                    }
                }

                // Navigation Trigger
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
