import SwiftUI
import AVKit
import Combine

struct CustomVideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    @Binding var isLoading: Bool
    @Binding var hasError: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player != player {
            uiViewController.player = player
        }
        
        DispatchQueue.main.async {
            guard let superview = uiViewController.view.superview else { return }
            
            uiViewController.view.frame = superview.bounds
            uiViewController.view.contentMode = .scaleAspectFill
        }
    }
}

struct VideoView: View {
    let videoURL: String
    @State var player: AVPlayer?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var cancellables = Set<AnyCancellable>()
    @State private var overlayOpacity: Double = 0.0


    init(videoURL: String = "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_1_ouhhqp.mp4") {
        self.videoURL = videoURL
    }

    var body: some View {
        ZStack {
            if let player = player {
                CustomVideoPlayerView(
                    player: player,
                    isLoading: $isLoading,
                    hasError: $hasError
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            Color.black
                            .opacity(overlayOpacity)
                            .edgesIgnoringSafeArea(.all)
                            .animation(.easeInOut(duration: 0.6), value: overlayOpacity)


            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.3))
            }
            
            if hasError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("ビデオの読み込みに失敗しました")
                        .foregroundColor(.white)
                        .font(.caption)
                    
                    Button("再試行") {
                        retryLoadVideo()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            }
        }
        .onAppear {
            loadVideo()
        }
        .onDisappear {
            cleanupPlayer()
        }
        .onChange(of: videoURL) { newURL in
            print("🔄 Video URL changed to: \(newURL)")
            cleanupPlayer()
            loadVideo()
        }

        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            player?.pause()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if !isLoading && !hasError {
                player?.play()
            }
        }
    }
    
    private func loadVideo() {
        print("🎬 Loading video: \(videoURL)")
        
        guard let url = URL(string: videoURL) else {
            print("❌ Invalid video URL: \(videoURL)")
            hasError = true
            isLoading = false
            return
        }
        
        isLoading = true
        hasError = false
        cancellables.removeAll()
        

        let newPlayer = AVPlayer(url: url)
        self.player = newPlayer
        

        newPlayer.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { status in
                switch status {
                case .readyToPlay:
                    print("✅ Video ready to play")
                    isLoading = false
                    hasError = false
                    newPlayer.play()
                    
                    NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: newPlayer.currentItem)
                        .receive(on: DispatchQueue.main)
                        .sink { _ in
                            print("🛑 Video ended — show grey overlay")
                            withAnimation(.easeInOut(duration: 0.6)) {
                                overlayOpacity = 0.2
                            }
                        }
                        .store(in: &cancellables)

                case .failed:
                    print("❌ Video failed to load: \(newPlayer.error?.localizedDescription ?? "Unknown error")")
                    isLoading = false
                    hasError = true
                case .unknown:
                    print("⏳ Video status unknown")
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        

        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: newPlayer.currentItem)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("❌ Video playback failed")
                hasError = true
                isLoading = false
            }
            .store(in: &cancellables)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if isLoading {
                print("⏰ Video loading timeout")
                hasError = true
                isLoading = false
            }
        }
    }
    
    private func retryLoadVideo() {
        cleanupPlayer()
        loadVideo()
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
        cancellables.removeAll()
    }
}

#Preview {
    VideoView(videoURL: "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294445/Grandma_Idle_ixptkp.mp4")
}
