//
//  AvatarCard.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//

import SwiftUI

struct AvatarCard: View {
    var body: some View {
        
        
        
        ZStack{
//                        border rectange
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
//                            image
                Image("sample_avatar")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(100)
                
//                            text
                VStack(alignment: .leading){
                    HStack{
                        Text("Sumi")
                            .font(.headline)
                        ZStack{
                            Rectangle()
                                .foregroundColor(Color(red: 211 / 255, green: 246 / 255, blue: 242 / 255))
                                .frame(width: 60, height: 30)
                                .cornerRadius(10)
                                Text("default")
                                    .font(.caption)
                                    .foregroundColor(.black)
                        }
                        

                    }
                    Text("English / Slow-paced")
                        .font(.caption)
                }
                
                Spacer()
//                            start session button
                ZStack{
                    Rectangle()
                        .foregroundColor(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                        .frame(width: 90, height: 40)
                        .cornerRadius(10)
                    Button(action: {}){
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
    AvatarCard()
}



