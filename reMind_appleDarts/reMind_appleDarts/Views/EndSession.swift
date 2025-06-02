//
//  ContentView.swift
//  reMind
//
//  Created by Ansha on 30/5/2025.
//

import SwiftUI

struct EndSessionView: View {
    var body: some View {
        VStack(spacing: 22){
            Text("✔️")
            Text("End of Session")
                .font(.title)
            
            HStack{
                ZStack{
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 100, height: 30)
                        .cornerRadius(10)
                    Button(action: {
                        // action here
                    }) {
                        Text("Finish")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                ZStack{
                    Rectangle()
                        .fill(Color.primaryGreen)
                        .frame(width: 100, height: 30)
                        .cornerRadius(10)
                    Button(action: {
                        // action here
                    }) {
                        Text("Resume")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                //Button(action: signIn) {
                //    Text("Sign In")
                // }
                
            }
        
        }
        .padding()
    }
}

#Preview {
    EndSessionView()
}
