//
//  EmptyAvatarStateView.swift
//  reMind_appleDarts
//
//  Created by user on 2025/06/03.
//

import SwiftUI


struct EmptyAvatarStateView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Support Companions Yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text("Create your first avatar to begin your personalized support journey")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
        }
        .padding(.vertical, 40)
    }
}



#Preview {
    EmptyAvatarStateView()
}
