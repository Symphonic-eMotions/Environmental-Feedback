//
//  DistanceView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 25/08/2024.
//

import SwiftUI

struct DistanceView: View {
    var label: String
    var color: Color
    var current: CGFloat
    @Binding var min: CGFloat
    var max: CGFloat
    var isCalibrating: Bool
    
    var body: some View {
        VStack(spacing: 5) { // Gebruik een VStack om de rijen onder elkaar te plaatsen
            HStack {
                Text("\(label):")
                    .foregroundColor(color)
                    .frame(width: 90, alignment: .leading)
                Text("\(formatDistance(current))")
                    .foregroundColor(color)
                    .frame(width: 40, alignment: .trailing)
                Text("\(formatDistance(min))")
                    .foregroundColor(.green)
                    .frame(width: 90, alignment: .trailing)
                Text("\(formatDistance(max))")
                    .foregroundColor(.red)
                    .frame(width: 90, alignment: .trailing)
            }
            .padding(5)
            .background(Color.black.opacity(0.7))
            .cornerRadius(5)

//            // Alleen de stepper in een aparte HStack
//            if !isCalibrating {
//                HStack {
//                    Spacer()
//                    Stepper("", value: $min, in: 0...max, step: 1)
//                        .labelsHidden()
//                        .frame(width: 90)
//                    Spacer()
//                }
//                .padding(5)
//            }
        }
    }
    
    private func formatDistance(_ distance: CGFloat) -> String {
        return String(format: "%.0f", distance)
    }
}
