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
    @StateObject private var audioManager = AudioManager(
        micVolume: 0.2,
        playbackVolume: 0.2
    )
    @State private var micVolume: Float = 0.2
    @State private var playbackVolume: Float = 0.2
    @State private var loopLength: Double = 5.0 // Default loop length in seconds
    @State private var isEngineRunning = false
    @State private var isRecording = false
    @State private var currentPosition: Double = 0.0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button(action: {
                        if isEngineRunning {
                            audioManager.stopEngine()
                        } else {
                            audioManager.startEngine()
                        }
                        isEngineRunning.toggle()
                    }) {
                        Text(isEngineRunning ? "Stop" : "Activate")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    if isEngineRunning {
                        Button(action: {
                            if isRecording {
                                audioManager.stopRecording()
                                audioManager.setPlaybackVolume(playbackVolume)
                                isRecording = false
                            } else {
                                audioManager.setPlaybackVolume(0)
                                isRecording = true
                                audioManager.startRecording {
                                    isRecording = false
                                    audioManager.setPlaybackVolume(playbackVolume)
                                }
                            }
                        }) {
                            Text(isRecording ? "Stop Recording" : "Record")
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)

                GroupBox {
                    ZStack(alignment: .bottom) {
                        NodeOutputView(audioManager.micMixer, color: .red)
                            .frame(height: 120)
                        
                        Text("Microphone")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(0.3)
                            .offset(y: -65)

                        Slider(value: $micVolume, in: 0...1, step: 0.01)
                            .onChange(of: micVolume) {
                                audioManager.setMicVolume(micVolume)
                            }
                            .offset(y: 32)
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

                        Slider(value: $playbackVolume, in: 0...1, step: 0.01)
                            .onChange(of: playbackVolume) {
                                if !isRecording {
                                    audioManager.setPlaybackVolume(playbackVolume)
                                }
                            }
                            .offset(y: 32) // Slider position adjusted here
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 20)
                }

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
                        Slider(value: $loopLength, in: 0.01...2, step: 0.01)
                            .onChange(of: loopLength) {
                                audioManager.setLoopLength(loopLength)
                            }
                        Text("Buffer Length: \(loopLength, specifier: "%.2f") seconds")
                        
                        Text("Current Position: \(currentPosition, specifier: "%.2f") seconds")
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            audioManager.startEngine()
            audioManager.startLoopTracking { position in
                currentPosition = position
            }
        }
        .onDisappear {
            audioManager.cleanup()
        }
    }
}

#Preview {
    ContentView()
}
