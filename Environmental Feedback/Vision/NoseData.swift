//
//  NoseData.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 26/08/2024.
//
import Foundation
import SwiftUI

class NoseData: ObservableObject {
    @Published var leftNoseDistance: CGFloat = 0.0
    @Published var rightNoseDistance: CGFloat = 0.0
    @Published var noseTrailVariation: CGFloat = 0.0
    
    @Published var minLeftNoseDistance: CGFloat = 999
    @Published var maxLeftNoseDistance: CGFloat = 0.0
    @Published var minRightNoseDistance: CGFloat = 999
    @Published var maxRightNoseDistance: CGFloat = 0.0
    @Published var minNoseTrailVariations: CGFloat = 999
    @Published var maxNoseTrailVariations: CGFloat = 0.0
    
    @Published var leftEarPoint: CGPoint = .zero
    @Published var rightEarPoint: CGPoint = .zero
    @Published var nosePoint: CGPoint = .zero
    
    @Published var leftEarTrail: [CGPoint] = []
    @Published var rightEarTrail: [CGPoint] = []
    @Published var noseTrail: [CGPoint] = []
    
    public func resetMinMaxValues() {
        minLeftNoseDistance = leftNoseDistance
        maxLeftNoseDistance = leftNoseDistance
        
        minRightNoseDistance = rightNoseDistance
        maxRightNoseDistance = rightNoseDistance
        
        minNoseTrailVariations = noseTrailVariation
        maxNoseTrailVariations = noseTrailVariation
    }
    
    public func scaleValue(_ value: CGFloat, foundMin: CGFloat, foundMax: CGFloat) -> CGFloat {
        guard foundMax != foundMin else { return 0.5 } // Prevent division by zero
        let scaledValue = (value - foundMin) / (foundMax - foundMin)
        return max(0, min(1, scaledValue)) // Beperkt de output van 0 tot 1
    }

}
