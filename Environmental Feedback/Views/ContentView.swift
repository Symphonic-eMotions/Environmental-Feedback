//
//  ContentView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 04/08/2024.
//

import SwiftUI
import AudioKit
import AudioKitUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var micVolume: Float = 0.2
    @State private var playbackVolume: Float = 0.2
    @State private var isEngineRunning = false
    @State private var isRecording = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if isEngineRunning {
                        audioManager.stopEngine()
                    } else {
                        audioManager.startEngine()
                    }
                    isEngineRunning.toggle()
                }) {
                    Text(isEngineRunning ? "Stop Engine" : "Start Engine")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if isEngineRunning {
                    Button(action: {
                        if isRecording {
                            audioManager.stopRecording()
                            audioManager.setPlaybackVolume(playbackVolume) // Restore playback volume
                        } else {
                            audioManager.setPlaybackVolume(0) // Mute playback during recording
                            audioManager.startRecording()
                        }
                        isRecording.toggle()
                    }) {
                        Text(isRecording ? "Stop Recording" : "Record")
                            .font(.title)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()

            VStack {
                Text("Mic Volume")
                Slider(value: $micVolume, in: 0...1, step: 0.01)
                    .padding()
                    .onChange(of: micVolume) {
                        audioManager.setMicVolume(micVolume)
                    }

                NodeOutputView(audioManager.micMixer, color: .blue)
                    .frame(height: 150)
                    .padding()
            }

            VStack {
                Text("Playback Volume")
                Slider(value: $playbackVolume, in: 0...1, step: 0.01)
                    .padding()
                    .onChange(of: playbackVolume) {
                        if !isRecording {
                            audioManager.setPlaybackVolume(playbackVolume)
                        }
                    }

                NodeOutputView(audioManager.playbackMixer, color: .green)
                    .frame(height: 150)
                    .padding()
            }
        }
        .onAppear {
            audioManager.setupAudio(micVolume: micVolume, playbackVolume: playbackVolume)
        }
        .onDisappear {
            audioManager.cleanup()
        }
    }
}

#Preview {
    ContentView()
}
