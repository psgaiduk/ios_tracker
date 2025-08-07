//
//  trackerApp.swift
//  tracker
//
//  Created by Work on 8/5/25.
//

import SwiftUI

@main
struct trackerApp: App {
    @StateObject private var store = ChainStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
