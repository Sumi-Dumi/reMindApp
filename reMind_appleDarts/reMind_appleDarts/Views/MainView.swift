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
                UserCard()
                
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
