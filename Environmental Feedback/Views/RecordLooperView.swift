//
//  RecordLooper.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 16/08/2024.
//

import SwiftUI
import AudioKit
import AudioKitUI

struct RecordLooperView: View {

    @ObservedObject var audioManager: AudioManager

    var body: some View {

        GroupBox {
            ZStack(alignment: .bottom) {
                NodeOutputView(audioManager.micMixerA, color: .red)
                    .frame(height: 120)

                Text("Microphone")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(0.3)
                    .offset(y: -65)
            }
            .padding(.top, 5)
            .padding(.bottom, 20)
        }
    }
}
