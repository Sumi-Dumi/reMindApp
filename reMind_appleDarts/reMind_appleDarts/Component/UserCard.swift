//
//  UserCard.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//

import SwiftUI

struct UserCard: View {
    
    let welcomeText: String
    let descriptionText: String
    let avatarImageName: String
    
    init(welcomeText: String = "Welcome, User!",
         descriptionText: String = "Feel grounded with your loved one",
         avatarImageName: String = "sample_avatar") {
        self.welcomeText = welcomeText
        self.descriptionText = descriptionText
        self.avatarImageName = avatarImageName
    }
    
    var body: some View {
        HStack{
            Image(avatarImageName)
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(100)
                .padding()
            VStack(alignment: .leading){
                Text(welcomeText)
                    .font(.title)
                Text(descriptionText)
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            Spacer()
            
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        UserCard(welcomeText: "Welcome User!",
                descriptionText: "Feel grounded with your loved one",
                avatarImageName: "sample_avatar")
    }
    
}
