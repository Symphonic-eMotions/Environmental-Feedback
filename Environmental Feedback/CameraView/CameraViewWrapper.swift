//
//  CameraViewWrapper.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 26/08/2024.
//
import SwiftUI

struct CameraViewWrapper: View {
    @ObservedObject var noseData: NoseData
    @Binding var isCalibrating: Bool
    
    var body: some View {
        CameraView(earDistanceHandler: { _ in
            // Stuur waarden naar de audio engine
        }, earPointsHandler: { leftPoint, rightPoint in
            noseData.leftEarPoint = leftPoint
            noseData.rightEarPoint = rightPoint
            updateTrail(&noseData.leftEarTrail, with: leftPoint)
            updateTrail(&noseData.rightEarTrail, with: rightPoint)
        }, nosePointHandler: { nosePoint in
            noseData.nosePoint = nosePoint
            updateTrail(&noseData.noseTrail, with: nosePoint)
            updateDistances(noseData: noseData)
        })
        .aspectRatio(3/4, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .padding()
    }
    
    private func updateTrail(_ trail: inout [CGPoint], with newPoint: CGPoint) {
        trail.append(newPoint)
        if trail.count > 10 {
            trail.removeFirst()
        }
    }

    private func updateDistances(noseData: NoseData) {
        let leftDistance = hypot(noseData.nosePoint.x - noseData.leftEarPoint.x, noseData.nosePoint.y - noseData.leftEarPoint.y)
        let rightDistance = hypot(noseData.nosePoint.x - noseData.rightEarPoint.x, noseData.nosePoint.y - noseData.rightEarPoint.y)
        
        noseData.leftNoseDistance = leftDistance
        noseData.rightNoseDistance = rightDistance
        
        let totalDistance: CGFloat = noseData.noseTrail.indices.dropFirst().reduce(0.0) { total, i in
            let point1 = noseData.noseTrail[i - 1]
            let point2 = noseData.noseTrail[i]
            return total + hypot(point2.x - point1.x, point2.y - point1.y)
        }
        noseData.noseTrailVariation = noseData.noseTrail.count > 1 ? totalDistance / CGFloat(noseData.noseTrail.count - 1) : 0.0
        
        // Update min and max values only if DistanceViews is showing
        if isCalibrating {
            noseData.minLeftNoseDistance = min(noseData.minLeftNoseDistance, leftDistance)
            noseData.maxLeftNoseDistance = max(noseData.maxLeftNoseDistance, leftDistance)
            noseData.minRightNoseDistance = min(noseData.minRightNoseDistance, rightDistance)
            noseData.maxRightNoseDistance = max(noseData.maxRightNoseDistance, rightDistance)
            noseData.minNoseTrailVariations = min(noseData.minNoseTrailVariations, noseData.noseTrailVariation)
            noseData.maxNoseTrailVariations = max(noseData.maxNoseTrailVariations, noseData.noseTrailVariation)
        }
    }
}

