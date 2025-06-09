//
//  LoadingView.swift
//  reMind_appleDarts
//
//  Created by user on 2025/06/08.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            BackGroundView()
            
            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .frame(width: 120, height: 120)
                
                Text("reMind")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.primaryText)
                
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.primaryGreen)
                
                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
        }
    }
}

#Preview {
    LoadingView()
}
