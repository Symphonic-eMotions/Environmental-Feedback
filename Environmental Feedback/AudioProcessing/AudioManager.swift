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
    
    @Published var micVolume: Float
    @Published var playbackVolume: Float
    @Published var isRecording: Bool = false
    @Published var loopLength: Double = 5.0 // Default loop length in seconds
    @Published var isPlaying: Bool = false
    @Published var fftData = FFTData()
    
    private var engine = AudioEngine()
    private(set) var micMixer = Mixer()
    private(set) var playbackMixer = Mixer()
    private var player = AudioPlayer()
    private var mic: AudioEngine.InputNode?
    private var recorder: NodeRecorder?
    private var fftTap: FFTTap!
    
    class EventScheduler {
        static let shared = EventScheduler()
        
        private init() {}
        
        func scheduleEvent(after delay: TimeInterval, event: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                event()
            }
        }
    }
    
    init(micVolume: Float, playbackVolume: Float) {
        self.micVolume = micVolume
        self.playbackVolume = playbackVolume
        setupAudio(micVolume: micVolume, playbackVolume: playbackVolume)
    }

    // Update the volume methods to use the properties
    func setMicVolume(_ volume: Float) {
        self.micVolume = volume
        self.micMixer.volume = AUValue(volume)
    }

    func setPlaybackVolume(_ volume: Float) {
        self.playbackVolume = volume
        self.playbackMixer.volume = AUValue(volume)
    }

    private func setupAudio(micVolume: Float, playbackVolume: Float) {
        
        do {
            // Configure AVAudioSession for playback and recording
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP, .allowAirPlay]
            )
            // Override the output audio port to use the speaker
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            // Activate the audio session
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
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
            try self.recorder?.record()
            self.isRecording = true
            print("Recording started")
            
            // Gebruik de EventScheduler om de opname te stoppen na 5 seconden
            EventScheduler.shared.scheduleEvent(after: loopLength) { [weak self] in
                self?.stopRecording()
                self?.isRecording = false
                onComplete()
            }
        } catch {
            print("Error starting recording: \(error)")
        }
    }

    func stopRecording() {
        self.recorder?.stop()
        self.isRecording = false

        if let recordedFile = recorder?.audioFile {
            do {
                let buffer = AVAudioPCMBuffer(pcmFormat: recordedFile.processingFormat, frameCapacity: AVAudioFrameCount(recordedFile.length))
                try recordedFile.read(into: buffer!)

                if let buffer = buffer {
                    self.player.scheduleBuffer(buffer, at: nil, options: .loops)
                    self.player.play()
                    self.isPlaying = true
                    print("Playback started")
                }
            } catch {
                print("Error scheduling buffer for playback: \(error)")
            }
        }
    }
    
    func startPlayback() {
        EventScheduler.shared.scheduleEvent(after: 0.01) {
            self.player.play()
            self.isPlaying = true
            print("Playback started")
        }
    }

    func stopPlayback() {
        EventScheduler.shared.scheduleEvent(after: 0.01) {
            self.player.stop()
            self.isPlaying = false
            print("Playback stopped")
        }
    }

    func setMicMuted(_ muted: Bool) {
        // Gebruik de volume-instelling van de microfoonmixer om de microfoon te dempen
        self.micMixer.volume = muted ? 0 : 1.0
        print("Mic is \(muted ? "muted" : "unmuted")")
        
        // Controleer of de sessie correct is ingesteld en actief is
        if muted {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
            } catch {
                print("Failed to mute microphone: \(error.localizedDescription)")
            }
        } else {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to unmute microphone: \(error.localizedDescription)")
            }
        }
    }
    
    func setLoopLength(_ length: Double) {
        self.loopLength = length
        if let recordedFile = recorder?.audioFile {
            let sampleRate = recordedFile.processingFormat.sampleRate
            let frameCount = AVAudioFrameCount(length * sampleRate)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: recordedFile.processingFormat, frameCapacity: frameCount) else {
                print("Failed to create AVAudioPCMBuffer")
                return
            }
            
            do {
                try recordedFile.read(into: buffer)
                self.player.scheduleBuffer(buffer, at: nil, options: .loops)
                self.player.play()
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
        self.engine.stop()
        self.fftTap.stop()
        self.stopLoopTracking()
    }
}
