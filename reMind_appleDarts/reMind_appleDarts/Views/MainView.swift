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
            
            VStack{
                //User card
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
                    
                }
                
                HStack{
//                    Spacer(10)
                    
                    Text("Your support circle")
                        .font(.headline)
                    Spacer()
                    Button(action: {}){
                        Text("Add more +")
                            .font(.caption)
                    }
//                    Spacer(10)
                    
                }
                
            }

            
            
 
            
            
            
        }
    }
}

#Preview {
    MainView()
}
