//
//  Environmental_FeedbackApp.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 04/08/2024.
//

import SwiftUI

@main
struct Environmental_FeedbackApp: App {
    
    init() {
        // Schakel automatisch vergrendelen van het scherm uit
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
