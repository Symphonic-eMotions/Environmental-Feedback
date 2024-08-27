//
//  NoseData.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 26/08/2024.
//
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
    
    func resetMinMaxValues() {
        minLeftNoseDistance = leftNoseDistance
        maxLeftNoseDistance = leftNoseDistance
        
        minRightNoseDistance = rightNoseDistance
        maxRightNoseDistance = rightNoseDistance
        
        minNoseTrailVariations = noseTrailVariation
        maxNoseTrailVariations = noseTrailVariation
    }
}
