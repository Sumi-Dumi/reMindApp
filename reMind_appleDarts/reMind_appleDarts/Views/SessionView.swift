import SwiftUI
import AVKit

struct TagView: View {
    let tags: [String]
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let onRemove: (String) -> Void

    init(tags: [String],
         horizontalSpacing: CGFloat = 8,
         verticalSpacing: CGFloat = 8,
         onRemove: @escaping (String) -> Void) {
        self.tags = tags
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.onRemove = onRemove
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: horizontalSpacing) {
                ForEach(tags, id: \.self) { tag in
                    tagView(for: tag)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 50)
    }

    private func tagView(for text: String) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .foregroundColor(Color.primaryText)

            Button(action: {
                onRemove(text)
            }) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundColor(Color.primaryText)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
    }
}

struct SessionView: View {
    let avatar: Avatar?
    
    @State private var currentStep: Int = 0
    @State private var recorded: Bool = false
    @State private var navigateToBreak = false
    @State private var isKeyboardMode: Bool = false
    @State private var inputText: String = ""
    @State private var tags: [String] = []

    init(avatar: Avatar? = nil) {
        self.avatar = avatar
    }

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
        "Hi pumpkin, I'm here for you",
        "Now, What are 5 things you can SEE?",
        "Now, Tell me 4 things you can TOUCH?",
        "You are doing realy great honey!",
        "Now, Tell me 3 things you HEAR?",
        "Focus on 2 things you can SMELL?",
        "Now, Tell me 1 thing you can TASTE?"
    ]
    
    private var currentVideoURL: String {
        guard let avatar = avatar,
              !avatar.deepfake_video_urls.isEmpty else {
            // デフォルトの動画URL
            return "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_1_ouhhqp.mp4"
        }
        
        let videoIndex = min(currentStep, avatar.deepfake_video_urls.count - 1)
        return avatar.deepfake_video_urls[videoIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VideoView(videoURL: currentVideoURL)
                    .ignoresSafeArea()
                    .id("video_\(currentStep)") //
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
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
                }
                .frame(maxHeight: .infinity, alignment: .top)

                VStack(spacing: 16) {
                    Spacer().frame(height: isKeyboardMode ? 400 : 500)

                    Text(prompts[currentStep])
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .frame(width: 346, height: 64)
                        .background(.black.opacity(0.4))
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)

                    if isKeyboardMode {
                        TextField("Type Here...", text: $inputText, onCommit: {
                            if !inputText.isEmpty && tags.count < 5 {
                                tags.insert(inputText, at: 0)
                                DispatchQueue.main.async {
                                    inputText = ""
                                }
                            }
                        })
                        .padding()
                        .frame(width: 346, height: 64)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.5), lineWidth: 1))
                        .foregroundColor(.black)
                        
                    }

                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)

                if isKeyboardMode {
                    VStack {
                        Spacer().frame(height: 570)

                        TagView(tags: tags, onRemove: { tag in
                            tags.removeAll { $0 == tag }
                        })
                        .frame(width: 346, height: 50)
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                }

                VStack {
                    Spacer()

                    ZStack {
                        if isKeyboardMode {
                            Button(action: {}) {
                                Image(systemName: "keyboard")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 26.66667)
                                    .frame(width: 100, height: 100)
                                    .background(Color.black.opacity(0.4))
                                    .cornerRadius(100)
                            }
                        } else {
                            RecordButton(recorded: $recorded)
                        }

                        HStack {
                            Button(action: {
                                isKeyboardMode.toggle()
                                recorded = false
                                inputText = ""
                                tags.removeAll()
                            }) {
                                Image(systemName: isKeyboardMode ? "mic.fill" : "keyboard")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(15)
                                    .foregroundColor(.white.opacity(0.8))
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                                    .padding(.leading, 20)
                            }

                            Spacer()

                            if recorded || (!tags.isEmpty) || currentStep == 0 || currentStep == 3{
                                HStack(spacing: 30) {
                                    Button(action: {
                                        recorded = false
                                        inputText = ""
                                        tags.removeAll() 
                                    }) {
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                            .padding(10)
                                            .background(Color.black.opacity(0.3))
                                            .clipShape(Circle())
                                            .foregroundColor(.white)
                                    }

                                    Button(action: {
                                        if currentStep < prompts.count - 1 {
                                            currentStep += 1
                                            recorded = false
                                            inputText = ""
                                            tags.removeAll()
                                            print("🎬 Step \(currentStep): Playing video[\(min(currentStep, avatar?.deepfake_video_urls.count ?? 1) - 1)] = \(currentVideoURL)")
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


                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 24)
                }
                

                NavigationLink(destination: Break(), isActive: $navigateToBreak) {
                    EmptyView()
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let avatar = avatar {
                print("✅ SessionView started with avatar: \(avatar.name)")
                print("📹 Available video URLs (\(avatar.deepfake_video_urls.count)): \(avatar.deepfake_video_urls)")
                print("Starting with video: \(currentVideoURL)")
            } else {
                print("SessionView started without avatar data, using default video")
            }
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleAvatar = Avatar(
            id: "sample_avatar",
            name: "Sample Avatar",
            isDefault: true,
            language: "English",
            theme: "Calm",
            voiceTone: "Gentle",
            profileImg: "sample_avatar",
            deepfakeReady: true,
            recipient_name: "User",
            creator_name: "Sample",
            image_urls: [],
            audio_url: "",
            image_count: 0,
            audio_size_mb: "0",
            storage_provider: "cloudinary",
            status: "ready",
            created_at: nil,
            updated_at: nil,
            deepfake_video_urls: [
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294443/Grandma_It_s_Alright_tgrunw.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_1_ouhhqp.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294444/Grandma_part_2_zutpaf.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294442/Grandma_doing_really_great_oaiikw.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_3_x7oud7.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_4_w1ski5.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294447/Grandma_part_5_vva1zv.mp4"
            ]
        )
        
        SessionView(avatar: sampleAvatar)
    }
}
