//
//  TransportView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 16/08/2024.
//

import SwiftUI

struct TransportView: View {
    
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var noseData: NoseData
    @Binding var isEngineRunning: Bool
    @Binding var isCalibrating: Bool
    
    var body: some View {
        
        HStack(spacing: 20) {
                        
            if isCalibrating {
                Button(action: {
                    noseData.resetMinMaxValues()
                }) {
                    Image(systemName: "gobackward")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        
                }
            }

            Button(action: {
                isCalibrating.toggle()
            }) {
                Circle()
                    .fill(isCalibrating ? Color.red : Color.white)
                    .frame(width: 50, height: 50)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            }
            
            Button(action: {
                if isEngineRunning {
                    audioManager.stopEngine()
                } else {
                    audioManager.startEngine()
                }
                isEngineRunning.toggle()
            }) {
                Image(systemName: isEngineRunning ? "power.circle.fill" : "power.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(isEngineRunning ? .green : .gray)
            }

            Button(action: {
                if audioManager.isRecording {
                    audioManager.stopRecording()
                    // Zet het volume terug naar de oorspronkelijke waarden of laat het zoals het was.
                    audioManager.setPlaybackVolume(audioManager.playbackVolume)
                } else {
                    // Zet het microfoonvolume op 0 tijdens opname en stel het afspeelvolume in zoals gewenst
                    audioManager.setMicVolume(0)
                    audioManager.setPlaybackVolume(audioManager.playbackVolume)
                    audioManager.startRecording {
                        audioManager.setPlaybackVolume(audioManager.playbackVolume)
                    }
                }
            }) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(audioManager.isRecording ? .red : (isEngineRunning ? .gray : .black))
            }
            .disabled(!isEngineRunning)

            Button(action: {
                if audioManager.isPlaying {
                    audioManager.stopPlayback()
                    audioManager.isPlaying = false
                    isEngineRunning = false
                } else {
                    audioManager.setMicMuted(true)
                    audioManager.startPlayback()
                }
            }) {
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(audioManager.isPlaying ? .green : (isEngineRunning ? .gray : .black))
            }
            .disabled(!isEngineRunning)
        }
        .padding(.horizontal)
    }
}
