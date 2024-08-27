//
//  DistanceViews.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 26/08/2024.
//

import SwiftUI

struct DistanceViews: View {
    @ObservedObject var noseData: NoseData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DistanceView(label: "Distance", color: Color.purple, current: noseData.leftNoseDistance, min: noseData.minLeftNoseDistance, max: noseData.maxLeftNoseDistance)
            DistanceView(label: "Distance", color: Color.orange, current: noseData.rightNoseDistance, min: noseData.minRightNoseDistance, max: noseData.maxRightNoseDistance)
            DistanceView(label: "Variation", color: Color.blue, current: noseData.noseTrailVariation, min: noseData.minNoseTrailVariations, max: noseData.maxNoseTrailVariations)
        }
    }
}

