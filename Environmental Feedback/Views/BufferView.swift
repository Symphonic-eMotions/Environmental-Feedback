//
//  BufferView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 16/08/2024.
//

import SwiftUI

struct BufferView: View {

    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack {
            ZStack {
                FFTView(fftData: audioManager.fftData)
                    .frame(height: 120)
                    .padding()
                Text("Buffer")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(0.3)
            }

            GroupBox {
                VStack(spacing: 5) {
                    Slider(value: $audioManager.loopLength, in: 0.01...2, step: 0.01)
                        .onChange(of: audioManager.loopLength) { newValue in
                            audioManager.setLoopLength(newValue)
                        }
                    Text("Buffer Length: \(audioManager.loopLength, specifier: "%.2f") seconds")

                    Text("Current Position: \(audioManager.isPlaying ? "Playing" : "Stopped")")
                }
                .padding()
            }
        }
    }
}
