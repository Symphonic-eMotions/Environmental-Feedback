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

//                Slider(value: $audioManager.micVolume, in: 0...1, step: 0.01)
//                    .onChange(of: audioManager.micVolume) { newValue in
//                        audioManager.setMicVolume(newValue)
//                    }
//                    .offset(y: 32)
            }
            .padding(.top, 5)
            .padding(.bottom, 20)
        }

        GroupBox {
            ZStack(alignment: .bottom) {
                NodeOutputView(audioManager.playbackMixer, color: .green)
                    .frame(height: 120)

                Text("Playback")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(0.3)
                    .offset(y: -65)

//                Slider(value: $audioManager.playbackVolume, in: 0...1, step: 0.01)
//                .onChange(of: audioManager.playbackVolume) { newValue in
//                    if !audioManager.isRecording {
//                        audioManager.setPlaybackVolume(newValue)
//                    }
//                }
//                .offset(y: 32) // Slider position adjusted here
            }
            .padding(.top, 5)
            .padding(.bottom, 20)
        }
    }
}
