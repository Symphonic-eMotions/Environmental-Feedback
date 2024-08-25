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
        
        NodeOutputView(audioManager.micMixerA, color: .red)
            .frame(height: 120)
    }
}
