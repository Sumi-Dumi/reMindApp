//
//  ContentView.swift
//  reMind_appleDarts
//
//  Created by Sumi on 30/5/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        MainView_ryosuke_ver()
            .environmentObject(appViewModel)
    }
}

#Preview {
    ContentView()
}
