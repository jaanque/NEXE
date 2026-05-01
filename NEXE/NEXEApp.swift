//
//  NEXEApp.swift
//  NEXE
//
//  Created by Jan Queralt Posino on 24/04/2026.
//

import SwiftUI

@main
struct NEXEApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
        }
    }
}
