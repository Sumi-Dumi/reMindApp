import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// 1) MorphingIcon Shape (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
struct MorphingIcon: Shape {
    /// Single “progress” value (0→1) for shape interpolation
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    // Shape A anchors (original MyIcon)
    private static let anchorsA: [CGPoint] = [
        CGPoint(x: 0.50912, y: 0.00266),
        CGPoint(x: 0.86154, y: 0.21254),
        CGPoint(x: 0.98433, y: 0.66705),
        CGPoint(x: 0.64784, y: 0.96298),
        CGPoint(x: 0.25029, y: 0.93679),
        CGPoint(x: 0.00856, y: 0.58169),
        CGPoint(x: 0.11687, y: 0.14176),
        CGPoint(x: 0.50912, y: 0.00266) // same as first to close loop
    ]

    // Shape A controls (14 total)
    private static let controlsA: [CGPoint] = [
        CGPoint(x: 0.74949, y: 0.01600), CGPoint(x: 0.77502, y: 0.09157),
        CGPoint(x: 0.95533, y: 0.34367), CGPoint(x: 1.02952, y: 0.50836),
        CGPoint(x: 0.93943, y: 0.82473), CGPoint(x: 0.79161, y: 0.91015),
        CGPoint(x: 0.51551, y: 1.01161), CGPoint(x: 0.37276, y: 1.00984),
        CGPoint(x: 0.12538, y: 0.86229), CGPoint(x: 0.03415, y: 0.73413),
        CGPoint(x: -0.01780, y: 0.42457), CGPoint(x:  0.01628, y: 0.25812),
        CGPoint(x: 0.21598, y: 0.02711), CGPoint(x: 0.36498, y: -0.01104)
    ]

    // Shape B anchors (the second blob)
    private static let anchorsB: [CGPoint] = [
        CGPoint(x: 0.58204, y: 0.00951),
        CGPoint(x: 0.90653, y: 0.26762),
        CGPoint(x: 0.97516, y: 0.70038),
        CGPoint(x: 0.63762, y: 0.98924),
        CGPoint(x: 0.23541, y: 0.88033),
        CGPoint(x: 0.00432, y: 0.52519),
        CGPoint(x: 0.17543, y: 0.12202),
        CGPoint(x: 0.58204, y: 0.00951) // same as first to close
    ]

    // Shape B controls (14 total)
    private static let controlsB: [CGPoint] = [
        CGPoint(x: 0.72330, y: 0.03765), CGPoint(x: 0.83388, y: 0.13994),
        CGPoint(x: 0.98205, y: 0.40034), CGPoint(x: 1.02867, y: 0.55678),
        CGPoint(x: 0.92005, y: 0.84824), CGPoint(x: 0.78750, y: 0.95278),
        CGPoint(x: 0.49567, y: 1.02377), CGPoint(x: 0.35419, y: 0.96737),
        CGPoint(x: 0.11672, y: 0.79335), CGPoint(x: 0.01613, y: 0.67454),
        CGPoint(x: -0.00785, y: 0.37143), CGPoint(x:  0.06212, y: 0.22315),
        CGPoint(x: 0.28694, y: 0.02248), CGPoint(x: 0.43707, y: -0.01936)
    ]

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        // 2A) Interpolate anchors A → B
        var anchors: [CGPoint] = []
        for i in 0..<MorphingIcon.anchorsA.count {
            let a = MorphingIcon.anchorsA[i]
            let b = MorphingIcon.anchorsB[i]
            let ix = a.x + (b.x - a.x) * progress
            let iy = a.y + (b.y - a.y) * progress
            anchors.append(CGPoint(x: ix * w, y: iy * h))
        }

        // 2B) Interpolate controls A → B
        var controls: [CGPoint] = []
        for i in 0..<MorphingIcon.controlsA.count {
            let a = MorphingIcon.controlsA[i]
            let b = MorphingIcon.controlsB[i]
            let ix = a.x + (b.x - a.x) * progress
            let iy = a.y + (b.y - a.y) * progress
            controls.append(CGPoint(x: ix * w, y: iy * h))
        }

        // 2C) Build Path with 7 curves
        var path = Path()
        path.move(to: anchors[0])
        for i in 0..<7 {
            let next = i + 1
            let c1 = controls[i * 2]
            let c2 = controls[i * 2 + 1]
            path.addCurve(to: anchors[next], control1: c1, control2: c2)
        }
        path.closeSubpath()
        return path
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// 2) BlobView – a reusable view that morphs, scales & rotates continuously
// ─────────────────────────────────────────────────────────────────────────────
struct BlobView: View {
    /// Controls morph progress (0…1)
    @State private var progress: CGFloat = 0
    /// Toggles between small (1.0×) and large (1.1×)
    @State private var scaleFlag: Bool = false
    /// Rotates full 360°
    @State private var rotationAngle: Double = 0

    /// Public properties for customization
    let size: CGFloat
//    let fillColor: Color
    private let fillColor: RadialGradient

    init(size: CGFloat = 100,) {
        self.size = size
//        self.fillColor = fillColor
        self.fillColor = RadialGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 153/255, green: 240/255, blue: 235/255), location: 0.00),
                    .init(color: Color(red: 187/255, green: 238/255, blue: 180/255), location: 0.17),
                    .init(color: Color(red: 220/255, green: 236/255, blue: 125/255), location: 0.38),
                    .init(color: Color(red: 237/255, green: 191/255, blue: 174/255), location: 0.72),
                    .init(color: Color(red: 255/255, green: 147/255, blue: 223/255), location: 1.00)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: size * 0.5
            )
    }
    
    
    var body: some View {
        MorphingIcon(progress: progress)
            .fill(fillColor)
            .frame(width: size, height: size)
            // Soft “breathing” scale between 1.0× and 1.1×
            .scaleEffect(scaleFlag ? 1.1 : 1.0)
            // Continuous rotation
            .rotationEffect(.degrees(rotationAngle))
            .onAppear {
                // 1) Morph from 0→1 over 2s, then back, forever
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    progress = 1
                }
                // 2) Scale from 1.0→1.1 over 1s, then back, forever
                withAnimation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                ) {
                    scaleFlag.toggle()
                }
                // 3) Continuous 0→360° rotation over 3s, then repeat
                withAnimation(
                    Animation.linear(duration: 3.0)
                        .repeatForever(autoreverses: false)
                ) {
                    rotationAngle = 360
                }
            }
    }
}

struct BlobView_Previews: PreviewProvider {
    static var previews: some View {
        BlobView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
