import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var navigateToSession = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                TabView(selection: $selectedTab) {
                    MainView_Firebase()
                        .environmentObject(AppViewModel())
                        .tag(0)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }

                    MainView_Firebase()
                        .environmentObject(AppViewModel())
                        .tag(1)
                        .tabItem {
                            Image(systemName: "face.smiling.fill")
                            Text("Avatars")
                        }

                    // Dummy tab for center button – hidden but needed to preserve spacing
                    Text("") // Or use EmptyView() if preferred
                        .tag(2)
                        
                        

                    EditUserView()
                        .tag(3)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }

                    ContentView()
                        .tag(4)
                        .tabItem {
                            Image(systemName: "questionmark.circle")
                            Text("Help")
                        }
                }

                // Floating center button (over tab 2)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        Button(action: {
                            navigateToSession = true
                        }) {
                            Image("Breathe")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                                .shadow(radius: 5)
                        }
                        .offset(y: -20)

                        Spacer()
                    }
                }

                // Navigation to SessionView
                NavigationLink(destination: SessionView(), isActive: $navigateToSession) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
}

#Preview {
    MainTabView()
}
