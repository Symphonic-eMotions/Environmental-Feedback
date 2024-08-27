//
//  DistanceViews.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 26/08/2024.
//

import SwiftUI

struct DistanceViewCollection: View {
    @ObservedObject var noseData: NoseData
    @Binding var isCalibrating: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header Row
            HStack {
                Spacer().frame(width: 120) // Lege ruimte om uitlijning met labels te behouden
                Text("Min")
                    .frame(width: 150)
                    .foregroundColor(.green)
                Text("Max")
                    .frame(width: 90)
                    .foregroundColor(.red)
            }
            .padding(5)
            .background(Color.black.opacity(0.7))
            .cornerRadius(5)
            
            // Distance Rows
            DistanceView(
                label: "Distance",
                color: Color.purple,
                current: noseData.leftNoseDistance,
                min: $noseData.minLeftNoseDistance,
                max: noseData.maxLeftNoseDistance,
                isCalibrating: isCalibrating
            )
            DistanceView(
                label: "Distance",
                color: Color.orange,
                current: noseData.rightNoseDistance,
                min: $noseData.minRightNoseDistance,
                max: noseData.maxRightNoseDistance,
                isCalibrating: isCalibrating
            )
            DistanceView(
                label: "Variation",
                color: Color.blue,
                current: noseData.noseTrailVariation,
                min: $noseData.minNoseTrailVariations,
                max: noseData.maxNoseTrailVariations,
                isCalibrating: isCalibrating
            )
        }
    }
}
