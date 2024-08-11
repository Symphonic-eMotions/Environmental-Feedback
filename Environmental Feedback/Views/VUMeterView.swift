//
//  VUMeterView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 11/08/2024.
//

import SwiftUI

struct VUMeterView: View {
    @Binding var amplitude: Float
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let meterHeight = CGFloat(min(max(self.amplitude, 0.0), 1.0)) * height
            
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.green)
                    .frame(height: meterHeight)
            }
            .background(Color.gray)
            .cornerRadius(5)
        }
    }
}
