//
//  BackGroundView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//

import SwiftUI

struct BackGroundView: View {
    var body: some View {
        
        LinearGradient(gradient: Gradient(colors: [
            Color.white,
            Color.primaryGreen.opacity(0.08),
            Color.pink.opacity(0.05)
        ]),
        startPoint: .top,
        endPoint: .bottom)
        .ignoresSafeArea()
    }
}

#Preview {
    BackGroundView()
}
