//
//  reMind_appleDartsApp.swift
//  reMind_appleDarts
//
//  Created by Sumi on 30/5/2025.
//


import SwiftUI
import FirebaseCore

@main
struct reMind_appleDartsApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
