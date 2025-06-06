import SwiftUI

struct MainView: View {
    let userName = "Sera"

    var body: some View {
        ZStack {
            BackGroundView()

//            NavigationView {
                VStack(spacing: 15) {
                    
                    UserCard(
                        welcomeText: "Welcome \(userName)!",
                        descriptionText: "Feel grounded with your loved one",
                        avatarImageName: "sample_avatar"
                    )

                    HStack {
                        Text("Your support circle")
                            .font(.headline)
                        Spacer()
                        NavigationLink(destination: TutorialView()) {
                            Text("Add more +")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()

                    VStack {
                        AvatarCard()
                        AvatarCard(
                            avatarImageName: "sample_avatar",
                            name: "Maria",
                            tagText: "",
                            description: "Spanish / Medium-paced"
                        ) {
                            print("Maria session started!")
                        }
                        AvatarCard(
                            avatarImageName: "sample_avatar",
                            name: "Maria",
                            tagText: "",
                            description: "Spanish / Medium-paced"
                        ) {
                            print("Maria session started!")
                        }
                    }

                    Spacer()
                }
//            }
        }
    }
}

#Preview {
    MainView()
}
