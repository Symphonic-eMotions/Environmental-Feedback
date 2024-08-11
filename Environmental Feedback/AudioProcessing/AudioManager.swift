//
//  AudioLoopingManager.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 11/08/2024.
//

import SwiftUI
import AudioKit
import AVFoundation

class AudioManager: ObservableObject {
    private var engine = AudioEngine()
    private var mixer = Mixer()
    private var player = AudioPlayer()
    private var mic: AudioEngine.InputNode?
    private var recorder: NodeRecorder?
    private var micMixer = Mixer()
    private var playbackMixer = Mixer()
    
    func setupAudio(micVolume: Float, playbackVolume: Float) {
        guard let mic = engine.input else {
            print("Microphone input is not available.")
            return
        }
        
        self.mic = mic

        // Set up the mic and playback mixers
        micMixer.volume = AUValue(micVolume)
        playbackMixer.volume = AUValue(playbackVolume)

        // Connect the microphone to the mic mixer
        micMixer.addInput(mic)
        
        // Connect the player to the playback mixer
        player.isLooping = true
        playbackMixer.addInput(player)
        
        // Connect both mixers to the main mixer
        mixer.addInput(micMixer)
        mixer.addInput(playbackMixer)
        
        // Set the mixer as the output of the engine
        engine.output = mixer
        
        // Setup the recorder
        do {
            recorder = try NodeRecorder(node: mic)
        } catch {
            print("Error setting up NodeRecorder: \(error)")
        }

        // Start the AudioEngine
        do {
            try engine.start()
        } catch {
            print("Error starting AudioEngine: \(error)")
        }
    }
    
    func startRecording() {
        do {
            try recorder?.record()
        } catch {
            print("Error starting recording: \(error)")
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        
        if let recordedFile = recorder?.audioFile {
            do {
                let buffer = AVAudioPCMBuffer(pcmFormat: recordedFile.processingFormat, frameCapacity: AVAudioFrameCount(recordedFile.length))
                try recordedFile.read(into: buffer!)
                
                if let buffer = buffer {
                    // Plan het afspelen van de buffer
                    player.scheduleBuffer(buffer, at: nil, options: .loops)
                    player.play()
                }
            } catch {
                print("Error scheduling buffer for playback: \(error)")
            }
        }
    }
    
    func setMicVolume(_ volume: Float) {
        micMixer.volume = AUValue(volume)
    }
    
    func setPlaybackVolume(_ volume: Float) {
        playbackMixer.volume = AUValue(volume)
    }
    
    func cleanup() {
        engine.stop()
    }
}
