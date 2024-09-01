//
//  MeterView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 27/08/2024.
//

import SwiftUI

struct MeterView: View {
    @ObservedObject var noseData: NoseData
    
    var body: some View {
        HStack {
            MeterColumnView(
                value: noseData.scaleValue(
                    noseData.leftNoseDistance,
                    foundMin: noseData.minLeftNoseDistance,
                    foundMax: noseData.maxLeftNoseDistance
                ), 
                color: .purple
            )
            MeterColumnView(
                value: noseData.scaleValue(
                    noseData.rightNoseDistance,
                    foundMin: noseData.minRightNoseDistance,
                    foundMax: noseData.maxRightNoseDistance
                ), 
                color: .orange
            )
            MeterColumnView(
                value: noseData.scaleValue(
                    noseData.noseTrailVariation, 
                    foundMin: noseData.minNoseTrailVariations,
                    foundMax: noseData.maxNoseTrailVariations
                ), 
                color: .blue
            )
        }
    }
    
    
}

struct MeterColumnView: View {
    var value: CGFloat
    var color: Color
    
    var body: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(color)
                .frame(width: 30, height: max(0, value.isFinite ? value * 200 : 0))
                .cornerRadius(5)
        }
    }
}

