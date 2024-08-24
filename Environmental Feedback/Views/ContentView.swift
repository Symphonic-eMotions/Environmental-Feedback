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
    
    @State private var earDistance: CGFloat = 0.0
    
    @State private var effectValues: [Float] = [0.1, 0.1]
    let effectLabels = ["Feedback", "Delay"]
    
    var body: some View {
        VStack(spacing: 20) {
            
            TransportView(
                audioManager: audioManager,
                isEngineRunning: $isEngineRunning
            )
            
            ScrollView {
                
                RecordLooperView(audioManager: audioManager)

                ZStack(alignment: .topLeading) {
                    CameraView(earDistanceHandler: { distance in
                        earDistance = distance
                        let normalizedValue = Float(distance / UIScreen.main.bounds.width)
                        audioManager.interpolateDelayTime(to: normalizedValue, duration: 1.0)
                    })
                    .aspectRatio(4/3, contentMode: .fit) // Aspect ratio ingesteld op 4:3, wat gebruikelijk is voor camera's
                    .frame(maxWidth: .infinity) // Breedte blijft maximaal
                    .background(Color.gray.opacity(0.1))
                    .padding()
                    
                    // Display earDistance as a small overlay in the top-left corner
                    Text(String(format: "Distance: %.2f", earDistance))
                    .font(.caption)
                    .padding(5)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding()
                }
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
