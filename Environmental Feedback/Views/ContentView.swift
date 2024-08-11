//
//  ContentView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 04/08/2024.
//

import SwiftUI
import AudioKit

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var isRecording = false
    @State private var micVolume: Float = 0.2
    @State private var playbackVolume: Float = 0.2
    @State private var micAmplitude: Float = 0.0
    @State private var playbackAmplitude: Float = 0.0

    var body: some View {
        VStack {
            Text(isRecording ? "Recording..." : "Tap to Record/Play")
                .font(.headline)
                .padding()

            Button(action: {
                if isRecording {
                    audioManager.stopRecording()
                } else {
                    audioManager.startRecording()
                }
                isRecording.toggle()
            }) {
                Text(isRecording ? "Stop & Loop" : "Record & Loop")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            VStack {
                Text("Mic Volume")
                Slider(value: $micVolume, in: 0...1, step: 0.01)
                    .padding()
                    .onChange(of: micVolume) {
                        audioManager.setMicVolume(micVolume)
                    }
                VUMeterView(amplitude: $micAmplitude)
                    .frame(height: 150)
                    .padding()
            }

            VStack {
                Text("Playback Volume")
                Slider(value: $playbackVolume, in: 0...1, step: 0.01)
                    .padding()
                    .onChange(of: playbackVolume) {
                        audioManager.setPlaybackVolume(playbackVolume)
                    }
                VUMeterView(amplitude: $playbackAmplitude)
                    .frame(height: 150)
                    .padding()
            }
        }
        .onAppear {
            audioManager.setupAudio(micVolume: micVolume, playbackVolume: playbackVolume, micAmplitude: $micAmplitude, playbackAmplitude: $playbackAmplitude)
        }
        .onDisappear {
            audioManager.cleanup()
        }
    }
}

#Preview {
    ContentView()
}
