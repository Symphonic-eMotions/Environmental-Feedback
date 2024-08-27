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
        HStack {
            Text("\(label):")
                .foregroundColor(color)
                .frame(width: 90)
            Text("\(formatDistance(current))")
                .foregroundColor(color)
                .frame(width: 40)
            Text("\(formatDistance(min))")
                .foregroundColor(.green)
                .frame(width: 90)
//            if !isCalibrating {
//                Stepper("", value: $min, in: 0...max, step: 1)
//                    .labelsHidden()
//                    .frame(width: 150)
//                    .overlay(
//                        Text("\(formatDistance(min))")
//                            .foregroundColor(.green)
//                    )
//            }
            Text("\(formatDistance(max))")
                .foregroundColor(.red)
                .frame(width: 90)
        }
        .padding(5)
        .background(Color.black.opacity(0.7))
        .cornerRadius(5)
    }
    
    private func formatDistance(_ distance: CGFloat) -> String {
        return String(format: "%.0f", distance)
    }
}
