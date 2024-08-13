//
//  AudioLoopingManager.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 11/08/2024.
//

import SwiftUI
import AudioKit
import AVFoundation

@MainActor
class AudioManager: ObservableObject {
    private var engine = AudioEngine()
    private(set) var micMixer = Mixer()
    private(set) var playbackMixer = Mixer()
    private var player = AudioPlayer()
    private var mic: AudioEngine.InputNode?
    private var recorder: NodeRecorder?
    private var fftTap: FFTTap!
    @Published var fftData = FFTData()

    init(micVolume: Float, playbackVolume: Float) {
        setupAudio(micVolume: micVolume, playbackVolume: playbackVolume)
    }

    private func setupAudio(micVolume: Float, playbackVolume: Float) {
        
        // Configure AVAudioSession for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category.")
        }

        
        guard let mic = engine.input else {
            print("Microphone input is not available.")
            return
        }

        self.mic = mic

        micMixer.volume = AUValue(micVolume)
        playbackMixer.volume = AUValue(playbackVolume)

        micMixer.addInput(mic)
        player.isLooping = true
        playbackMixer.addInput(player)

        let mainMixer = Mixer(micMixer, playbackMixer)
        engine.output = mainMixer

        // Setup FFT Tap
        fftTap = FFTTap(micMixer) { fftData in
            self.fftData.update(with: fftData)
        }

        do {
            recorder = try NodeRecorder(node: mic)
        } catch {
            print("Error setting up NodeRecorder: \(error)")
        }

        do {
            try engine.start()
            fftTap.start()
        } catch {
            print("Error starting AudioEngine: \(error)")
        }
    }

    func startEngine() {
        do {
            try engine.start()
            fftTap.start()
        } catch {
            print("Error starting AudioEngine: \(error)")
        }
    }

    func stopEngine() {
        engine.stop()
        player.stop()
        fftTap.stop()
    }

    func startRecording(onComplete: @escaping () -> Void) {
        do {
            try recorder?.record()
            print("Recording started")
            
            // Schedule the stop of recording after the buffer duration (default is 5 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                self?.stopRecording()
                onComplete()
            }
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
                    player.scheduleBuffer(buffer, at: nil, options: .loops)
                    player.play()
                    print("Playback started")
                }
            } catch {
                print("Error scheduling buffer for playback: \(error)")
            }
        }
    }
    
    func startPlayback() {
        player.play()
    }

    func stopPlayback() {
        player.stop()
    }

    func setMicMuted(_ muted: Bool) {
        micMixer.volume = muted ? 0 : 1.0
    }
    
    func setMicVolume(_ volume: Float) {
        micMixer.volume = AUValue(volume)
    }

    func setPlaybackVolume(_ volume: Float) {
        playbackMixer.volume = AUValue(volume)
    }

    func setLoopLength(_ length: Double) {
        if let recordedFile = recorder?.audioFile {
            let sampleRate = recordedFile.processingFormat.sampleRate
            let frameCount = AVAudioFrameCount(length * sampleRate)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: recordedFile.processingFormat, frameCapacity: frameCount) else {
                print("Failed to create AVAudioPCMBuffer")
                return
            }
            
            do {
                try recordedFile.read(into: buffer)
                player.scheduleBuffer(buffer, at: nil, options: .loops)
                player.play()
            } catch {
                print("Error reading into buffer or scheduling playback: \(error)")
            }
        }
    }

    func startLoopTracking(onUpdate: @escaping (Double) -> Void) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                let currentTime = self.player.currentTime
                if let buffer = self.player.buffer {
                    let bufferDuration = Double(buffer.frameLength) / buffer.format.sampleRate
                    onUpdate(currentTime.truncatingRemainder(dividingBy: bufferDuration))
                }
            }
        }
    }

    func stopLoopTracking() {
        // Implement logic to stop loop tracking
    }

    func cleanup() {
        engine.stop()
        fftTap.stop()
        stopLoopTracking()
    }
}
