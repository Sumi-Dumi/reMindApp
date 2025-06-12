import SwiftUI
import AVKit
import Combine

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
    @State private var isShowingIdlingVideo: Bool = false
    @State private var isPressing: Bool = false
    @StateObject private var keyboard = KeyboardResponder()

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
    let prompts_jap = [
        "愛しのあなた、私はここにいるよ",
        "さて、あなたの周りに見える５つのものは？",
        "いま、触れている４つのものは？",
        "本当に素晴らしいです!",
        "少し聞いて、あなたが聞こえる３つの音はなんですか？",
        "ゆっくり吸って、２つの香りを感じますか？",
        "少し時間をとって、今あなたが感じている１つの味を教えて？"
    ]
    

    private var currentPrompts: [String] {
        guard let avatar = avatar else { return prompts }
        
        if avatar.language.lowercased() == "japanese" {
            return prompts_jap
        } else {
            return prompts
        }
    }
    

    private var defaultVideoURL: String {
        return "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_1_ouhhqp.mp4"
    }
    

    private var idlingVideoURL: String {
        guard let avatar = avatar else {
            return "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294445/Grandma_Idle_ixptkp.mp4"
        }
        
        switch avatar.theme.lowercased() {
        case "human":
            return "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294445/Grandma_Idle_ixptkp.mp4"
            
        case "ghibli":
            return "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749609944/Ghibli_idle_oabbhn.mp4"
            
        default:
            print("⚠️ Unknown theme '\(avatar.theme)', using default idling video")
            return "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294445/Grandma_Idle_ixptkp.mp4"
        }
    }

    private var videoURLsForCurrentTheme: [String] {
        guard let avatar = avatar else {
            print("⚠️ No avatar data available, using default video")
            return [defaultVideoURL]
        }
        
        switch avatar.theme.lowercased() {
        case "human":
            if !avatar.deepfake_video_urls.isEmpty {
                print("🎬 Using Human theme videos: \(avatar.deepfake_video_urls.count) videos")
                return avatar.deepfake_video_urls
            } else {
                print("⚠️ No Human theme videos available, using default")
                return [defaultVideoURL]
            }
            
        case "ghibli":
            if avatar.language.lowercased() == "japanese" {
                if let japaneseGhibliVideos = getJapaneseGhibliVideos(from: avatar), !japaneseGhibliVideos.isEmpty {
                    print("🎬 Using Ghibli Japanese theme videos: \(japaneseGhibliVideos.count) videos")
                    return japaneseGhibliVideos
                } else {
                    print("⚠️ No Ghibli Japanese videos available, falling back to regular Ghibli videos")
                    if let ghibliVideos = getGhibliVideos(from: avatar), !ghibliVideos.isEmpty {
                        return ghibliVideos
                    }
                }
            } else {
                if let ghibliVideos = getGhibliVideos(from: avatar), !ghibliVideos.isEmpty {
                    print("🎬 Using Ghibli theme videos: \(ghibliVideos.count) videos")
                    return ghibliVideos
                } else {
                    print("⚠️ No Ghibli theme videos available, falling back to Human videos")
                }
            }
            
            return avatar.deepfake_video_urls.isEmpty ? [defaultVideoURL] : avatar.deepfake_video_urls
            
        default:
            print("⚠️ Unknown theme '\(avatar.theme)', using default videos")
            return avatar.deepfake_video_urls.isEmpty ? [defaultVideoURL] : avatar.deepfake_video_urls
        }
    }
    

    private func getJapaneseGhibliVideos(from avatar: Avatar) -> [String]? {

        return avatar.deep_fake_video_url_ghibli_jap.isEmpty ? nil : avatar.deep_fake_video_url_ghibli_jap
    }
    
    private func getGhibliVideos(from avatar: Avatar) -> [String]? {
        return avatar.deep_fake_video_url_ghibli.isEmpty ? nil : avatar.deep_fake_video_url_ghibli
    }


    private var currentVideoURL: String {
        if isPressing {
            return idlingVideoURL
        } else {
            let videos = videoURLsForCurrentTheme
            let videoIndex = min(currentStep, videos.count - 1)
            let selectedURL = videos[videoIndex]
            
            print("🎬 Current step: \(currentStep), Theme: \(avatar?.theme ?? "unknown"), Video: \(selectedURL)")
            return selectedURL
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VideoView(videoURL: currentVideoURL, shouldAutoPlay: !recorded)
                    .ignoresSafeArea()
                    .id("video_\(currentStep)_\(isPressing)_\(recorded)_\(avatar?.theme ?? "default")")
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

                    Text(currentPrompts[currentStep])
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

//                    Spacer()
                }
                .padding(.bottom, max(keyboard.currentHeight - 20, 0))
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
                            RecordButton(
                                recorded: $recorded,
                                onPressStart: {
                                    print("🎬 Mic press started")
                                },
                                onPressEnd: {
                                    print("🎬 Mic released: Pausing video")
                                    recorded = true
                                },
                                onPressingChanged: { pressing in
                                    isPressing = pressing
                                    if pressing {
                                        print("🎬 Pressing: Switching to idling video")
                                    } else {
                                        print("🎬 Not pressing: Back to normal video")
                                    }
                                }
                            )
                        }

                        HStack {
                            Button(action: {
                                isKeyboardMode.toggle()
                                recorded = false
                                isPressing = false
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

                            if recorded || (!tags.isEmpty) || currentStep == 0 || currentStep == 3 {
                                HStack(spacing: 30) {

                                    if currentStep != 0 && currentStep != 3 && (recorded || !tags.isEmpty) {
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
                                    }

                                    Button(action: {
                                        if currentStep < prompts.count - 1 {
                                            currentStep += 1
                                            recorded = false
                                            inputText = ""
                                            tags.removeAll()
                                            
                                            let videos = videoURLsForCurrentTheme
                                            let videoIndex = min(currentStep, videos.count - 1)
                                            print("🎬 Step \(currentStep): Theme \(avatar?.theme ?? "unknown"), Playing video[\(videoIndex)] = \(videos[videoIndex])")
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
                print("🎨 Avatar theme: \(avatar.theme)")
                
                let videos = videoURLsForCurrentTheme
                print("📹 Available videos for theme '\(avatar.theme)' (\(videos.count)): \(videos)")
                print("🎬 Starting with video: \(currentVideoURL)")
            } else {
                print("⚠️ SessionView started without avatar data, using default video")
            }
        }
    }
}



final class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
   
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
     
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
     
        Publishers.Merge(willShow, willHide)
            .assign(to: \.currentHeight, on: self)
            .store(in: &cancellables)
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleHumanAvatar = Avatar(
            id: "sample_avatar_human",
            name: "Human Avatar",
            isDefault: true,
            language: "English",
            theme: "Human",
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
        
        let sampleGhibliAvatar = Avatar(
            id: "sample_avatar_ghibli",
            name: "Ghibli Avatar",
            isDefault: false,
            language: "Japanese",
            theme: "Ghibli",
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
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_1_ouhhqp.mp4"
            ],
            deep_fake_video_url_ghibli: [
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749605094/Ghibli_pumpkin_kpihrr.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749605093/Ghibli_part_1_pmdxjt.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749605093/Ghibli_part_2_mwckxf.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749605092/Ghibli_Its_Alright_sdlbym.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749605094/Ghibli_part_3_irthug.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749605093/Ghibli_part_4_oewuyw.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749605728/Ghibli_Part_5_ol2te0.mp4"
            ]
        )
        
        let sampleGhibliJapAvatar = Avatar(
            id: "sample_avatar_ghibli_jap",
            name: "Ghibli Avatar",
            isDefault: false,
            language: "Japanese",
            theme: "Ghibli",
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
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749294446/Grandma_part_1_ouhhqp.mp4"
            ],
            deep_fake_video_url_ghibli: [
            ],
            deep_fake_video_url_ghibli_jap: [
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749686985/Ghibli_Jap_pumpkin_hr6vve.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749686985/Ghibli_Japanese_part_1_z7ohu7.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749686985/Ghibli_Japanese_part_2_lsg9s3.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749686985/Ghibli_Japanese_doing_really_great_ikmfth.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749686985/Ghibli_Japanese_part_3_gszydf.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749686985/Ghibli_Japanese_part_4_epkv2q.mp4",
                "https://res.cloudinary.com/dvyjkf3xq/video/upload/v1749687210/Ghibli_Jap_Part_5_bap526.mp4"
            ]
        )
        
        Group {
            SessionView(avatar: sampleHumanAvatar)
                .previewDisplayName("Human Theme")
            
            SessionView(avatar: sampleGhibliAvatar)
                .previewDisplayName("Ghibli Theme")
            SessionView(avatar: sampleGhibliJapAvatar)
                .previewDisplayName("Ghibli Jap Theme")
        }
    }
}
