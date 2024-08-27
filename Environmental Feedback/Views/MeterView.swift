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
            MeterColumnView(value: scaleValue(noseData.leftNoseDistance, min: noseData.minLeftNoseDistance, max: noseData.maxLeftNoseDistance), color: .purple)
            MeterColumnView(value: scaleValue(noseData.rightNoseDistance, min: noseData.minRightNoseDistance, max: noseData.maxRightNoseDistance), color: .orange)
            MeterColumnView(value: scaleValue(noseData.noseTrailVariation, min: noseData.minNoseTrailVariations, max: noseData.maxNoseTrailVariations), color: .blue)
        }
    }
    
    private func scaleValue(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        guard max != min else { return 0.5 } // Prevent division by zero
        return (value - min) / (max - min)
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
                .frame(width: 30, height: value * 200)
                .cornerRadius(5)
        }
    }
}

