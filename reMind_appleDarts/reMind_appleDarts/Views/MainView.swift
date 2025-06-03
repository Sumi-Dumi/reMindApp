//
//  MainView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack{
//            background
            BackGroundView()
            
            NavigationView {
                
                VStack(spacing:15){
                    //User card
                    UserCard(welcomeText: "Welcome User!",
                            descriptionText: "Feel grounded with your loved one",
                            avatarImageName: "sample_avatar")
                    
    //                add button and heading of List
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
                    
                    
                    
    //                List for supporter
                    VStack{
                        
    //                    supporter card
                        AvatarCard()
                        AvatarCard(
                            avatarImageName: "sample_avatar",
                            name: "Maria",
                            tagText: "", //
                            description: "Spanish / Medium-paced"
                        ) {
                            print("Maria session started!")
                        }
                        AvatarCard(
                            avatarImageName: "sample_avatar",
                            name: "Maria",
                            tagText: "", //
                            description: "Spanish / Medium-paced"
                        ) {
                            print("Maria session started!")
                        }
                        
                    }
                    
                    
                    
                    Spacer()
                }
                
            }
            
            
        }
    }
}

#Preview {
    MainView()
}



