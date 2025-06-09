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
    let videoURL: String
    @State var player: AVPlayer?

    init(videoURL: String = "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_1_ouhhqp.mp4") {
        self.videoURL = videoURL
    }

    var body: some View {
        CustomVideoPlayerView(player: player ?? AVPlayer())
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                player = AVPlayer(url: URL(string: videoURL)!)
                player?.play()
            }
    }
}

#Preview {
    VideoView(videoURL:"https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294447/Grandma_part_5_vva1zv.mp4")
}
