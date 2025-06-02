
//
//  AvatarCard.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//

import SwiftUI

struct AvatarCard: View {
    let avatarImageName: String
    let name: String
    let tagText: String
    let tagColor: Color
    let description: String
    let isDefault: Bool
    let onStartSession: () -> Void
    
    init(
        avatarImageName: String = "sample_avatar",
        name: String = "Sumi",
        tagText: String = "default",
        tagColor: Color = Color(red: 211 / 255, green: 246 / 255, blue: 242 / 255),
        description: String = "English / Slow-paced",
        isDefault: Bool = true,
        onStartSession: @escaping () -> Void = {}
    ) {
        self.avatarImageName = avatarImageName
        self.name = name
        self.tagText = tagText
        self.tagColor = tagColor
        self.description = description
        self.isDefault = isDefault
        self.onStartSession = onStartSession
    }
    
    var body: some View {
        ZStack{
            // border rectangle
            Rectangle()
                .fill(Color.white)
                .opacity(0.1)
                .frame(width: 380, height: 120)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .opacity(0.5)
                )
            
            HStack{
                // image
                Image(avatarImageName)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(100)
                
                // text
                VStack(alignment: .leading){
                    HStack{
                        Text(name)
                            .font(.headline)
                        
              
                        if !tagText.isEmpty {
                            ZStack{
                                Rectangle()
                                    .foregroundColor(tagColor)
                                    .frame(width: 60, height: 30)
                                    .cornerRadius(10)
                                Text(tagText)
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    Text(description)
                        .font(.caption)
                }
                
                Spacer()
                
                // start session button
                ZStack{
                    Rectangle()
                        .foregroundColor(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                        .frame(width: 90, height: 40)
                        .cornerRadius(10)
                    Button(action: onStartSession){
                        Text("start session")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}


#Preview {
    VStack(spacing: 20) {

        AvatarCard()
        
  
        AvatarCard(
            avatarImageName: "custom_avatar",
            name: "Alex",
            tagText: "premium",
            tagColor: Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255), 
            description: "Japanese / Fast-paced",
            isDefault: false
        ) {
            print("Alex session started!")
        }
        

        AvatarCard(
            avatarImageName: "another_avatar",
            name: "Maria",
            tagText: "", //
            description: "Spanish / Medium-paced"
        ) {
            print("Maria session started!")
        }
    }
}
