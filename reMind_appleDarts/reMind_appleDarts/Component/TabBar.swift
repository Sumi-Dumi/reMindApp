import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var navigateToSession = false

    init() {
        // Set default tab bar appearance background to white (for fallback)
        UITabBar.appearance().backgroundColor = UIColor.white
    }

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

                    // Dummy middle tab to preserve spacing
                    Text("").tag(2)

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

                // Overlay: white background with padding effect
                VStack(spacing: 0) {
                    Spacer()

                    // Simulated top padding for the tab bar
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(height: 12)

                    // Actual tab bar background
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(height: 88)
                }
                .edgesIgnoringSafeArea(.bottom)

                // Floating center button + triangle pointer
                VStack(spacing: 0) {
                    Spacer()

                    // Optional triangle visual (comment if not needed)
                    Triangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 20, height: 10)
                        .rotationEffect(.degrees(180))
                        .offset(y: -10)

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

// Custom triangle shape (for pointer effect above the tab bar)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))       // Top center
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))   // Bottom right
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))   // Bottom left
            path.closeSubpath()
        }
    }
}

#Preview {
    MainTabView()
}
