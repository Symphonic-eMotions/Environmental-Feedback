//
//  ContentView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 04/08/2024.
//

import SwiftUI
import AudioKit
import AudioKitUI
import AVFoundation

import SwiftUI
import AudioKit

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var isRecording = false

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
        }
        .onAppear {
            audioManager.setupAudio()
        }
        .onDisappear {
            audioManager.cleanup()
        }
    }
}

#Preview {
    ContentView()
}
