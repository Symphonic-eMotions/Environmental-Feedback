//
//  ResetButton.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 26/08/2024.
//

import SwiftUI

struct ResetButton: View {
    @ObservedObject var noseData: NoseData
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    noseData.resetMinMaxValues()
                }) {
                    Image(systemName: "gobackward")
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 20)
        }
    }
}
