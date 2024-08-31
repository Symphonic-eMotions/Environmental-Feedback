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
    @StateObject private var setInfoModel: SetInfoModel
    @StateObject private var noseData = NoseData()
    @State private var isEngineRunning = false
    @State private var currentPosition: Double = 0.0
    @State private var isCalibrating = true
    
    let instrumentSet = AppUtils.loadInstrumentSet(json: "Introductie.json")
    
    init() {
        let conductor = Conductor(set: instrumentSet)
        _setInfoModel = StateObject(wrappedValue: SetInfoModel(
            currentInstrumentsSetIsChanged: { newSet in
                // Logica voor het aanpassen van instrumenten set
            },
            conductor: conductor
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                RecordLooperView(audioManager: audioManager)
                
                ZStack(alignment: .topLeading) {
                    CameraViewWrapper(noseData: noseData, isCalibrating: $isCalibrating)
                    .environmentObject(setInfoModel)
                    DistanceViewCollection(noseData: noseData, isCalibrating: $isCalibrating)
                    MeterView(noseData: noseData)
                    FaceLandmarkTrailView(noseData: noseData)
                }
            }
            TransportView(
                audioManager: audioManager,
                noseData: noseData,
                isEngineRunning: $isEngineRunning,
                isCalibrating: $isCalibrating
            )
            .environmentObject(setInfoModel)
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
