//
//  TabBar2.swift
//  reMind_appleDarts
//
//  Created by Ansha on 2/6/2025.
//

//
//  NavBar.swift
//  reMind_appleDarts
//
//  Created by Ansha on 2/6/2025.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        
        TabView() {
            // Home
           MainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            // Avatars
           PulsingView()
                .tabItem {
                    Image(systemName: "face.smiling") // Smiley icon
                    Text("Avatars")
                }


            // Start Session
           SessionView()
                .tabItem {
                    Image("Breathe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 2, height: 2)
                    Text("Start Session")
                }

            // My Profile
           EditProfile()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("My Profile")
                }

            // Help
            ContentView()
                .tabItem {
                    Image(systemName: "questionmark.circle")
                    Text("Help")
                }
        }
    }
}
#Preview {
    MainTabView()
}
