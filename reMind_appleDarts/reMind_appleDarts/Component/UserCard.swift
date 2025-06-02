//
//  UserCard.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//

import SwiftUI

struct UserCard: View {
    var body: some View {
        HStack{
            Image("sample_avatar")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(100)
                .padding()
            VStack(alignment: .leading){
                Text("Welcome, User!")
                    .font(.title)
                Text("Feel grounded with your loved one")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            Spacer()
            
        }
    }
}

#Preview {
    UserCard()
}
