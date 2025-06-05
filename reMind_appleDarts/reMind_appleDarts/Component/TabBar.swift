import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Main content
            TabView(selection: $selectedTab) {
                MainView()
                    .tag(0)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                PulsingView()
                    .tag(1)
                    .tabItem {
                        Image(systemName: "face.smiling.fill")
                        Text("Avatars")
                    }
                ContentView()
                    .tag(3)
                    .tabItem {
//                        Image(systemName: "questionmark.circle")
//                        Text("Help")
                    }

                MainView()
                    .tag(2)
                    .tabItem {
                        // Dummy tab for center button
                        Image(systemName: "person.fill").opacity(0)
                        Text("Profile").opacity(0)
                    }
               
                ContentView()
                    .tag(3)
                    .tabItem {
                        Image(systemName: "questionmark.circle")
                        Text("Help")
                    }
            }

            // Floating center button
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    // Add more space before and after the button
                    HStack {
                        Spacer().frame(width: UIScreen.main.bounds.width / 4.2) // ⬅️ More spacing before button

                        Button(action: {
                            selectedTab = 2
                        }) {
                            Image("Breathe")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                        .offset(y: -20)

                        Spacer().frame(width: UIScreen.main.bounds.width / 4.2) // ⬅️ More spacing after button
                    }

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
