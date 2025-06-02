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
        
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        DispatchQueue.main.async {
            guard let superview = uiViewController.view.superview else { return }
            
            uiViewController.view.frame = CGRect(
                x: 0,
                y: 0,
                width: superview.bounds.width,
                height: superview.bounds.height
            )
            uiViewController.view.contentMode = .scaleAspectFill
            uiViewController.videoGravity = .resizeAspectFill
        }
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


