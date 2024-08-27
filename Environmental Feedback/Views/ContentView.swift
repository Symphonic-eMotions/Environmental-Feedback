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
        micVolume: 0.01,
        playbackVolume: 1.0
    )
    @State private var isEngineRunning = false
    @State private var currentPosition: Double = 0.0
    @StateObject private var noseData = NoseData()
    
    var body: some View {
        VStack(spacing: 20) {
            TransportView(
                audioManager: audioManager,
                isEngineRunning: $isEngineRunning
            )
            
            ScrollView {
                RecordLooperView(audioManager: audioManager)
                
                ZStack(alignment: .topLeading) {
                    CameraViewWrapper(noseData: noseData)
                    DistanceViews(noseData: noseData)
                    FaceLandmarkTrailView(noseData: noseData)
                    ResetButton(noseData: noseData)
                }
            }
        }
        .padding(.vertical)
        .onAppear {
            audioManager.startEngine()
            audioManager.startLoopTracking { position in
                currentPosition = position
            }
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            audioManager.cleanup()
        }
    }
}

#Preview {
    ContentView()
}
