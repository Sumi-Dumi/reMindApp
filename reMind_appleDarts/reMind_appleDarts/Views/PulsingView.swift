import SwiftUI

// ───────────────────────────────────────────
// MARK: ── Irregular Blob Shape Definition ──
// ───────────────────────────────────────────
struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        return Path { p in
            p.move(to: CGPoint(x: 0.5 * w, y: 0.05 * h))
            p.addCurve(
                to: CGPoint(x: 0.95 * w, y: 0.5 * h),
                control1: CGPoint(x: 0.8 * w, y: 0.0),
                control2: CGPoint(x: 1.0 * w, y: 0.3 * h)
            )
            p.addCurve(
                to: CGPoint(x: 0.5 * w, y: 0.95 * h),
                control1: CGPoint(x: 0.9 * w, y: 0.7 * h),
                control2: CGPoint(x: 0.6 * w, y: 1.0 * h)
            )
            p.addCurve(
                to: CGPoint(x: 0.05 * w, y: 0.5 * h),
                control1: CGPoint(x: 0.4 * w, y: 0.9 * h),
                control2: CGPoint(x: 0.0,     y: 0.7 * h)
            )
            p.addCurve(
                to: CGPoint(x: 0.5 * w, y: 0.05 * h),
                control1: CGPoint(x: 0.0,     y: 0.3 * h),
                control2: CGPoint(x: 0.2 * w, y: 0.0)
            )
            p.closeSubpath()
        }
    }
}

// ───────────────────────────────────────────
// MARK: ── Single Background Blob Layer ──
// ───────────────────────────────────────────
struct BackgroundBlob: View {
    let id: Int
    let size: CGFloat

    @State private var animatePhase = false

    // Transparent pastel color per layer
    private var color: Color {
        switch id {
        case 0: return Color(red: 1.0, green: 0.8, blue: 0.9).opacity(0.3)   // pastel pink
        case 1: return Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.3)   // pastel blue
        case 2: return Color(red: 0.8, green: 1.0, blue: 0.8).opacity(0.3)   // pastel green
        default: return Color(red: 0.9, green: 0.8, blue: 1.0).opacity(0.3)  // pastel lavender
        }
    }

    // Each blob animates at a slightly different speed
    private var animation: Animation {
        Animation.easeInOut(duration: Double(5 + id))
            .repeatForever(autoreverses: true)
    }

    var body: some View {
        BlobShape()
            .fill(color)
            .frame(
                width: size * (0.6 + 0.1 * sin(Double(id) + 1)),
                height: size * (0.6 + 0.1 * cos(Double(id) + 1))
            )
            .scaleEffect(animatePhase ? 1.05 : 0.95)
            .rotationEffect(.degrees(animatePhase ? Double(id * 20 + 10) : Double(id * 20 - 10)))
            .offset(
                x: animatePhase
                    ? CGFloat.random(in: -size * 0.05...size * 0.05)
                    : CGFloat.random(in: -size * 0.05...size * 0.05),
                y: animatePhase
                    ? CGFloat.random(in: -size * 0.05...size * 0.05)
                    : CGFloat.random(in: -size * 0.05...size * 0.05)
            )
            .animation(animation, value: animatePhase)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(id) * 0.3) {
                    animatePhase = true
                }
            }
    }
}

// ───────────────────────────────────────────
// MARK: ── Main PulsingView ──
// ───────────────────────────────────────────
struct PulsingView: View {
    @State private var isPulsing = false
    @State private var currentAffirmation = 0
    @State private var animateAffirmation = false

    // Updated affirmations
    private let affirmations = [
        "You’re doing great.",
        "You are not alone.",
        "Feel the calm within.",
        "Everything is okay.",
        "One breath at a time."
    ]

    var body: some View {
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)

            ZStack {
                // 1) White background
                Color.white.ignoresSafeArea()

                // 2) Place blobs+image in a VStack aligned to top
                VStack {
                    // Blob container
                    ZStack {
                        // Background blob layers
                        ForEach(0..<4, id: \.self) { index in
                            BackgroundBlob(id: index, size: minSide * 0.9)
                        }

                        // Foreground “Breathe” SVG
                        Image("Breath")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(isPulsing ? 2 : -2))
                            .scaleEffect(isPulsing ? 1.2 : 1.0)
                            .shadow(
                                color: Color.primaryGreen.opacity(isPulsing ? 0.6 : 0.2),
                                radius: isPulsing ? 30 : 10
                            )
                            .animation(
                                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                value: isPulsing
                            )
                            .onAppear { isPulsing = true }
                    }
                    .frame(width: minSide * 0.9, height: minSide * 0.9)
                    // Push the blob container up a bit from the top
                    .padding(.top, 40)

                    Spacer() // pushes the text/button lower
                }
                // Make the VStack fill vertically and align its content at the top
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)

                // 3) Text & Button VStack sits over everything, near bottom
                VStack(spacing: 30) {
                    // Floating affirmation text
                    Text(affirmations[currentAffirmation])
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .opacity(animateAffirmation ? 1 : 0)
                        .offset(y: animateAffirmation ? -20 : 0)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: animateAffirmation
                        )

                    // Prompt text
                    Text("Now, Relax and Breathe with me...")
                        .font(.headline)
                        .foregroundColor(.black)

                    // Spacer to give breathing room above the button
                    Spacer().frame(height: 40)

                    // Finish button
                    Button(action: {
                        // Add your finish action here
                    }) {
                        Text("Finish")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.primaryGreen)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 40)
                }
                // Position this VStack near the bottom half
                .position(x: geo.size.width / 2, y: geo.size.height * 0.75)
                .onAppear {
                    animateAffirmation = true
                    Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                        currentAffirmation = (currentAffirmation + 1) % affirmations.count
                    }
                }
            }
        }
    }
}

struct PulsingView_Previews: PreviewProvider {
    static var previews: some View {
        PulsingView()
    }
}
