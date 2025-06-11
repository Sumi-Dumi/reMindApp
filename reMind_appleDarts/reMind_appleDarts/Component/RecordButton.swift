import SwiftUI

/// A three‐state “record” button:
/// 1) Idle: plain, opaque circle with a mic icon.
/// 2) Press & hold: show the animated pastel blob (BlobView).
/// 3) On release: show a circle with a radial‐gradient stroke outline.
struct RecordButton: View {
    // MARK: State & Gesture flags

    /// Tracks whether the button is currently being pressed (finger is down).
    @State private var isPressing: Bool = false
    /// Tracks whether the user has just released (recording is done).
//    @State private var recorded: Bool = false
    @Binding var recorded: Bool
    
    
    let onPressStart: (() -> Void)?
    let onPressEnd: (() -> Void)?
    let onPressingChanged: ((Bool) -> Void)?
    init(recorded: Binding<Bool>,
         onPressStart: (() -> Void)? = nil,
         onPressEnd: (() -> Void)? = nil,
         onPressingChanged: ((Bool) -> Void)? = nil) {
        self._recorded = recorded
        self.onPressStart = onPressStart
        self.onPressEnd = onPressEnd
        self.onPressingChanged = onPressingChanged
    }

    var body: some View {
        ZStack {
            // ─── 1) Press & Hold: Show the animated blob ───
            if isPressing {
                BlobView(size: 100)
            }
            // ─── 2) After user releases: show gradient outline circle ───
            else if recorded {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 85, height: 85)
                Circle()
                    .stroke(
                                            // Replace the RadialGradient with a LinearGradient:
                                    LinearGradient(
                                                gradient: Gradient(stops: [
                                                    // 0%   → #99F0EB (light aqua)
                                                    .init(
                                                        color: Color(
                                                            red: 153/255,
                                                            green: 240/255,
                                                            blue: 235/255
                                                        ),
                                                        location: 0.00
                                                    ),
                                                    // 17%  → #BBEEB4 (pale green)
                                                    .init(
                                                        color: Color(
                                                            red: 187/255,
                                                            green: 238/255,
                                                            blue: 180/255
                                                        ),
                                                        location: 0.17
                                                    ),
                                                    // 38%  → #DCEC7D (soft yellow)
                                                    .init(
                                                        color: Color(
                                                            red: 220/255,
                                                            green: 236/255,
                                                            blue: 125/255
                                                        ),
                                                        location: 0.38
                                                    ),
                                                    // 72%  → #EDBFAE (peach)
                                                    .init(
                                                        color: Color(
                                                            red: 237/255,
                                                            green: 191/255,
                                                            blue: 174/255
                                                        ),
                                                        location: 0.72
                                                    ),
                                                    // 100% → #FF93DF (pink)
                                                    .init(
                                                        color: Color(
                                                            red: 255/255,
                                                            green: 147/255,
                                                            blue: 223/255
                                                        ),
                                                        location: 1.00
                                                    )
                                                ]),
                                                // Feel free to adjust start/end points if you like a different direction.
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 5
                                        )

                    .frame(width: 100, height: 100)
            }
            // ─── 3) Idle (not pressing, not recorded yet): show plain circle ───
            else {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 100, height: 100)
            }

            // ─── Mic icon overlay ───
            // In this version, we only show the mic when we're _not_ currently pressing.
            if !isPressing {
                Image(systemName: "mic.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.primaryGreen)

            }
        }
        .contentShape(Circle()) // Make the entire 100×100 tappable
        .frame(width: 100, height: 100)
        // Attach a LongPressGesture(minimumDuration: 0) for immediate press detection:
        .onLongPressGesture(minimumDuration: 0,
                            pressing: { inProgress in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressing = inProgress
                

                onPressingChanged?(inProgress)
                
                if inProgress {
                    onPressStart?()
                } else {
                    recorded = true
                    onPressEnd?()
                }
            }
        }) {
        }
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        RecordButton(recorded: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

