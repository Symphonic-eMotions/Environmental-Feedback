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
    @State private var leftEarPoint: CGPoint = .zero
    @State private var rightEarPoint: CGPoint = .zero
    
    // Arrays to hold the previous positions for the trailing effect
    @State private var leftEarTrail: [CGPoint] = []
    @State private var rightEarTrail: [CGPoint] = []
    
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
                    }, earPointsHandler: { leftPoint, rightPoint in
                        // Update trails
                        updateTrail(&leftEarTrail, with: leftPoint)
                        updateTrail(&rightEarTrail, with: rightPoint)
                        
                        leftEarPoint = leftPoint
                        rightEarPoint = rightPoint
                    })
                    .aspectRatio(3/4, contentMode: .fit) // Correcte aspect ratio voor de front-facing camera in portrait
                    .frame(maxWidth: .infinity)
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
                    
                    // Display the trailing effect for the left ear
                    ForEach(0..<leftEarTrail.count, id: \.self) { index in
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .position(x: leftEarTrail[index].x, y: leftEarTrail[index].y)
                            .opacity(Double(leftEarTrail.count - index) / Double(leftEarTrail.count)) // Fade effect
                            .animation(.easeOut(duration: 0.5), value: leftEarTrail) // Smooth transition
                    }
                    
                    // Display the trailing effect for the right ear
                    ForEach(0..<rightEarTrail.count, id: \.self) { index in
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 10, height: 10)
                            .position(x: rightEarTrail[index].x, y: rightEarTrail[index].y)
                            .opacity(Double(rightEarTrail.count - index) / Double(rightEarTrail.count)) // Fade effect
                            .animation(.easeOut(duration: 0.5), value: rightEarTrail) // Smooth transition
                    }
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
    
    // Helper function to update the trail
    private func updateTrail(_ trail: inout [CGPoint], with newPoint: CGPoint) {
        trail.append(newPoint)
        if trail.count > 10 { // Limit the trail length
            trail.removeFirst()
        }
    }
}

#Preview {
    ContentView()
}
