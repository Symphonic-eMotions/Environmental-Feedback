//
//  TransportView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 16/08/2024.
//

import SwiftUI

struct TransportView: View {
    
    @EnvironmentObject var setInfoModel: SetInfoModel
    @ObservedObject var noseData: NoseData
    @Binding var isCalibrating: Bool
    
    var body: some View {
        
        HStack(spacing: 20) {
            //Callibrating
            Button(action: {
                isCalibrating.toggle()
                if isCalibrating {
                    noseData.resetMinMaxValues()
                }
            }) {
                Circle()
                    .fill(isCalibrating ? Color.red : Color.white)
                    .frame(width: 50, height: 50)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            }
            
            //Track player
            Button(action: {
                
                if !setInfoModel.conductor.isEngineRunning {
                    
                }
                
                if setInfoModel.conductor.isPlaying {
                    setInfoModel.conductor.playEngineAndTracks()
                }
                else {
                    setInfoModel.conductor.stopTracks()
                }
                setInfoModel.conductor.isPlaying.toggle()
            }) {
                Image(systemName: setInfoModel.conductor.isPlaying ? "power.circle.fill" : "power.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(setInfoModel.conductor.isPlaying ? .green : .gray)
            }
            
            //Recorder
//            Button(action: {
//                if audioManager.isRecording {
//                    audioManager.stopRecording()
//                    // Zet het volume terug naar de oorspronkelijke waarden of laat het zoals het was.
//                    audioManager.setPlaybackVolume(audioManager.playbackVolume)
//                } else {
//                    // Zet het microfoonvolume op 0 tijdens opname en stel het afspeelvolume in zoals gewenst
//                    audioManager.setMicVolume(0)
//                    audioManager.setPlaybackVolume(audioManager.playbackVolume)
//                    audioManager.startRecording {
//                        audioManager.setPlaybackVolume(audioManager.playbackVolume)
//                    }
//                }
//            }) {
//                Image(systemName: "circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 50, height: 50)
//                    .foregroundColor(audioManager.isRecording ? .red : (setInfoModel.conductor.isPlaying ? .gray : .black))
//            }
//            .disabled(!setInfoModel.conductor.isPlaying)

            Button(action: {
                if setInfoModel.conductor.isPlaying {
                    setInfoModel.conductor.stopTracks()
                    setInfoModel.conductor.isPlaying = false
                } else {
//                    audioManager.setMicMuted(true)
                    setInfoModel.conductor.playEngineAndTracks()
                }
            }) {
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(setInfoModel.conductor.isPlaying ? .green : (setInfoModel.conductor.isPlaying ? .gray : .black))
            }
            .disabled(!setInfoModel.conductor.isPlaying)
        }
        .padding(.horizontal)
    }
}
