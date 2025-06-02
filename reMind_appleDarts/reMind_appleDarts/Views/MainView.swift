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
            
            VStack(spacing:15){
                //User card
                UserCard(welcomeText: "Welcome User!",
                        descriptionText: "Feel grounded with your loved one",
                        avatarImageName: "sample_avatar")
                
//                add button and heading of List
                HStack{
                    Text("Your support circle")
                        .font(.headline)
                    Spacer()
                    Button(action: {}){
                        Text("Add more +")
                            .font(.caption)
                    }
                    
                }
                .padding(.horizontal)
                
                
                
//                List for supporter
                VStack{
                    
//                    supporter card
                    AvatarCard()
                    AvatarCard()
                    AvatarCard()
                    
                }
                
                
                
                Spacer()
            }
            
        }
    }
}

#Preview {
    MainView()
}



