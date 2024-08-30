//
//  Environmental_FeedbackApp.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 04/08/2024.
//

import SwiftUI

@main
struct Environmental_FeedbackApp: App {
    
    let instrumentSet = AppUtils.loadInstrumentSet(json: "Introductie.json")
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
