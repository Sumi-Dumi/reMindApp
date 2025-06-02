//
//  VideoView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//


import SwiftUI
import AVKit

struct CustomVideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
}


struct VideoView: View {
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "sample_video", withExtension: "mp4")!)
    
    var body: some View {
        CustomVideoPlayerView(player: player)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                player.play()
            }
    }
}

#Preview {
    VideoView()
}
