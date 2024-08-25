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
    
    @State private var leftNoseDistance: CGFloat = 0.0
    @State private var rightNoseDistance: CGFloat = 0.0
    @State private var noseTrailVariation: CGFloat = 0.0
    
    @State private var minLeftNoseDistance: CGFloat = .greatestFiniteMagnitude
    @State private var maxLeftNoseDistance: CGFloat = 0.0
    @State private var minRightNoseDistance: CGFloat = .greatestFiniteMagnitude
    @State private var maxRightNoseDistance: CGFloat = 0.0
    @State private var minNoseTrailVariations: CGFloat = .greatestFiniteMagnitude
    @State private var maxNoseTrailVariations: CGFloat = 0.0
    
    @State private var leftEarPoint: CGPoint = .zero
    @State private var rightEarPoint: CGPoint = .zero
    @State private var nosePoint: CGPoint = .zero
    
    @State private var leftEarTrail: [CGPoint] = []
    @State private var rightEarTrail: [CGPoint] = []
    @State private var noseTrail: [CGPoint] = []
    
    var body: some View {
        VStack(spacing: 20) {
            TransportView(
                audioManager: audioManager,
                isEngineRunning: $isEngineRunning
            )
            
            ScrollView {
                RecordLooperView(audioManager: audioManager)

                ZStack(alignment: .topLeading) {
                    CameraView(earDistanceHandler: { _ in
                        
                        //Hier moeten we de waarden naar de audio enigine sturen:
                        //audioManager.interpolateDelayTime(to: normalizedValue, duration: 1.0)
                        
                    }, earPointsHandler: { leftPoint, rightPoint in
                        updateTrail(&leftEarTrail, with: leftPoint)
                        updateTrail(&rightEarTrail, with: rightPoint)
                        
                        leftEarPoint = leftPoint
                        rightEarPoint = rightPoint
                    }, nosePointHandler: { nosePoint in
                        updateTrail(&noseTrail, with: nosePoint)
                        self.nosePoint = nosePoint
                        
                        // Bereken de afstanden
                        let leftDistance = hypot(nosePoint.x - leftEarPoint.x, nosePoint.y - leftEarPoint.y)
                        let rightDistance = hypot(nosePoint.x - rightEarPoint.x, nosePoint.y - rightEarPoint.y)
                        
                        // Update de afstanden
                        leftNoseDistance = leftDistance
                        rightNoseDistance = rightDistance
                        
                        // Bereken de variatie in de staart van de neus
                        var totalDistance: CGFloat = 0.0
                        for i in 1..<noseTrail.count {
                            let point1 = noseTrail[i - 1]
                            let point2 = noseTrail[i]
                            totalDistance += hypot(point2.x - point1.x, point2.y - point1.y)
                        }
                        noseTrailVariation = noseTrail.count > 1 ? totalDistance / CGFloat(noseTrail.count - 1) : 0.0
                        
                        // Update de minimum- en maximumwaarden
                        minLeftNoseDistance = min(minLeftNoseDistance, leftDistance)
                        maxLeftNoseDistance = max(maxLeftNoseDistance, leftDistance)
                        minRightNoseDistance = min(minRightNoseDistance, rightDistance)
                        maxRightNoseDistance = max(maxRightNoseDistance, rightDistance)
                        minNoseTrailVariations = min(minNoseTrailVariations, noseTrailVariation)
                        maxNoseTrailVariations = max(maxNoseTrailVariations, noseTrailVariation)
                    })
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        DistanceView(label: "Distance", color: Color.purple, current: leftNoseDistance, min: minLeftNoseDistance, max: maxLeftNoseDistance)
                        DistanceView(label: "Distance", color: Color.orange, current: rightNoseDistance, min: minRightNoseDistance, max: maxRightNoseDistance)
                        DistanceView(label: "Variation", color: Color.blue, current: noseTrailVariation, min: minNoseTrailVariations, max: maxNoseTrailVariations)
                    }
//                    .padding()
                    
                    // Display the trailing effect for the left ear
                    ForEach(0..<leftEarTrail.count, id: \.self) { index in
                        Circle()
                            .fill(Color.purple)
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
                    
                    ForEach(0..<noseTrail.count, id: \.self) { index in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                            .position(x: noseTrail[index].x, y: noseTrail[index].y)
                            .opacity(Double(noseTrail.count - index) / Double(noseTrail.count)) // Fade effect
                            .animation(.easeOut(duration: 0.5), value: noseTrail) // Smooth transition
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
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            audioManager.cleanup()
        }
    }
    
    private func updateTrail(_ trail: inout [CGPoint], with newPoint: CGPoint) {
        trail.append(newPoint)
        if trail.count > 10 {
            trail.removeFirst()
        }

        // Bereken de variatie voor de neus
        if trail == noseTrail {
            noseTrailVariation = calculateNoseVariation(trail)
            // Update de minimum- en maximumvariaties
            minNoseTrailVariations = min(minNoseTrailVariations, noseTrailVariation)
            maxNoseTrailVariations = max(maxNoseTrailVariations, noseTrailVariation)
        }
    }

    private func calculateNoseVariation(_ trail: [CGPoint]) -> CGFloat {
        guard trail.count > 1 else { return 0.0 }

        var totalDistance: CGFloat = 0.0
        for i in 1..<trail.count {
            let distance = hypot(trail[i].x - trail[i-1].x, trail[i].y - trail[i-1].y)
            totalDistance += distance
        }

        return totalDistance
    }
}

#Preview {
    ContentView()
}
