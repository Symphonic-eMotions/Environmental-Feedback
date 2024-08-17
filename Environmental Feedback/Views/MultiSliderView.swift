//
//  MultiSliderView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 16/08/2024.
//

import SwiftUI

struct MultiSliderView: View {
    
    @ObservedObject var audioManager: AudioManager
    @Binding var values: [Float]
    var labels: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading) {
                Text("Volume")
                    .font(.headline)
                
                Slider(value: $audioManager.playbackVolume, in: 0...1, step: 0.01)
                    .onChange(of: audioManager.playbackVolume) {
                        if !audioManager.isRecording {
                            audioManager.setPlaybackVolume(audioManager.playbackVolume)
                        }
                    }
            }
            
            ForEach(0..<values.count, id: \.self) { index in
                VStack(alignment: .leading) {
                    Text(labels[index])
                        .font(.headline)
                    Slider(value: Binding(
                        get: {
                            self.values[index]
                        },
                        set: { newValue in
                            self.values[index] = newValue
                            self.updateAudioEffect(index: index, value: newValue)
                        }
                    ), in: 0...1)
                }
            }
        }
        .padding()
    }
    
    func updateAudioEffect(index: Int, value: Float) {
        switch index {
        case 0:
            audioManager.setFeedback(value) // Feedback
        case 1:
            // Voeg damper toe om delay waarden vloeiender te maken
            let adjustedValue = Float(round(100 * value) / 100)
            audioManager.setDelayTime(adjustedValue) // Delay time
        default:
            break
        }
        print("Updated parameter \(labels[index]) to \(value)")
    }
}
