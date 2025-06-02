//
//  VideoView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//

import SwiftUI
import AVKit


struct VideoView: View {
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "sample_video",
                                                      withExtension: "mp4")!)
    @State var isPlaying: Bool = false
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)

//            Button {
//                isPlaying ? player.pause() : player.play()
//                isPlaying.toggle()
//                player.seek(to: .zero)
//            } label: {
//                Image(systemName: isPlaying ? "stop" : "play")
//                    .padding()
//            }
        }
    }
}

#Preview {
    VideoView()
}
