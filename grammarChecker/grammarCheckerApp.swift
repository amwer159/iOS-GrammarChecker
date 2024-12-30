//
//  grammarCheckerApp.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import SwiftUI

@main
struct grammarCheckerApp: App {
    var body: some Scene {
        WindowGroup {
            GrammarView()
                .environment(\.colorScheme, .light)
        }
    }
}
