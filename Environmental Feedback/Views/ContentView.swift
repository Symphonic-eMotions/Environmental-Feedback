//
//  ContentView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 04/08/2024.
//

import SwiftUI
import AudioKit
import AudioKitUI

struct ContentView: View {

    @StateObject private var audioManager = AudioManager(
        micVolume: 0.0,
        playbackVolume: 1.0
    )
    @State private var isEngineRunning = false
    @State private var currentPosition: Double = 0.0

    var body: some View {
        VStack(spacing: 20) {
            
            TransportView(
                audioManager: audioManager,
                isEngineRunning: $isEngineRunning
            )
            
            ScrollView {
                
                RecordLooperView(audioManager: audioManager)
                
                BufferView(audioManager: audioManager)
            }
        }
        .padding(.vertical)
        .onAppear {
            audioManager.startEngine()
            audioManager.startLoopTracking { position in
                currentPosition = position
            }
        }
        .onDisappear {
            audioManager.cleanup()
        }
    }
}
#Preview {
    ContentView()
}
