//
//  relate_appApp.swift
//  relate-app
//
//  Created by wangwenfei on 2026/4/17.
//

import SwiftUI

@main
struct relate_appApp: App {
    @StateObject private var store = AppStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
