//
//  Conductor.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 29/08/2024.
//

import SwiftUI
import AudioKit
import SoundpipeAudioKit

@MainActor
final class Conductor {
    
    //MARK: Var declarations
    @Published var isEngineRunning: Bool = false
    @Published var isPlaying: Bool = false
    
    //Audiokit AudioEngine. One engine is running at all times
    //Gets pauzed on set change
    internal var audioEngine: AudioEngine
    //First mixer mixes the output of the effect chains per instrument
    internal var mixer: Mixer
    //Second mixer is the output of the first mixer's effect chain output
    private var mixerMaster: Mixer
    
    //trackMaxers for recording tracks
    internal var trackMixers: [String: Mixer] = [:]
    internal var trackRecorders: [String: NodeRecorder] = [:]
    
    //trackSequencers holds MIDI file information
    //Is the play head in the score
    //Controls speed, loop (length)
    //The playhead only moves lineair
    internal var trackSequencers: [String: AppleSequencer] = [:]
    
    //EXS Sampler AND Buffer sampler container
    internal var trackSamplers: [String: MIDISampler] = [:]
    
    //The main instrument set structure. A Musical set is loaded into this struct
    internal var set: InstrumentsSet
    
    //MARK: Init
    init(
        set: InstrumentsSet
    ) {
        self.set = set
        
        audioEngine = AudioEngine()
        mixer = Mixer()
        mixerMaster = Mixer()
        loadMaster(mixer: mixer)
        audioEngine.output = mixerMaster
        loadTracks(currentSetLevel: 0)
    }
    
    //MARK: Load Master Track
    private func loadMaster(mixer: Node) {
//        mixerMaster.addInput(mixer)  // Directly connect without effects

        mixerMaster.addInput(chainMasterEffects(for: set.masterTrackEffects, startingNode: mixer))
    }
    
    // MARK: Load tracks
    private func loadTracks(currentSetLevel: Double ){
        
        //Create tupple with midichannel per midi only instrument (Deprecate?)
        var midiChannels = collectMidiChannels()
        
        set.tracks.forEach { track in
            
            trackMixers[track.id] = Mixer()
            
            //Load sequencers
            //Within this function the EXS is also loaded
            guard let sequencer = midiSequencerBuffersAndSamplersWithNestedEffects(
                for: track,
                length: "loopSequenceFromMIDIfile",
                currentSetLevel: currentSetLevel,
                midiChannels: &midiChannels,
                samplePath: set.filesPath
            ) else {
                print("Error loading sequencer for track: \(track.id)")
                return
            }
            
            trackSequencers[track.id] = sequencer
        }
    }
    
    func startEngine() {
        do {
            let osc = Oscillator()
            mixerMaster.addInput(osc)
            
            try audioEngine.start()
            
            // Kies een willekeurige frequentie tussen 110 en 220 Hz, voor variatie in de print
            osc.frequency = AUValue(Double.random(in: 110...220))
            osc.amplitude = 0.0 //Trigger Audio Chain Hack
            osc.play()
            
            isEngineRunning = true
            print("--> Audio engine and osc \(osc.frequency) Hz are running <--")
            
        } catch {
            print("Error starting AudioEngine: \(error)")
        }
    }
    
    func cleanup() {
        self.audioEngine.pause()
        isEngineRunning = false
        //        self.fftTap.stop()
        //        self.stopLoopTracking()
    }
    
    public func playEngineAndTracks() {
        trackSequencers.forEach { track in
            track.value.play()
            print("Start track \(track.key)")
        }
        isPlaying = true
    }
    
    public func stopTracks() {
        trackSequencers.forEach { track in
            track.value.stop()
            track.value.rewind()
            track.value.preroll()
            print("Stop track \(track.key)")
        }
        isPlaying = false
    }
    
    
    //MARK: Chain effects per track
    internal func chainEffects(
        for track: InstrumentsSet.Track,
        startingNode: Node
    ) -> Node {
        guard let effects = track.effects else { return startingNode }
        var finalNode = startingNode
        effects.forEach { effect in
            
            finalNode = effect.chain(to: finalNode)
        }
        return finalNode as Node
    }
    
    //MARK: Chain master track
    private func chainMasterEffects(
        for effects: [InstrumentsSet.Track.Effect],
        startingNode: Node
    ) -> Node {
        var finalNode = startingNode
        effects.forEach { effect in
            finalNode = effect.chain(to: finalNode)
        }
        return finalNode as Node
    }
    
    private func collectMidiChannels() -> [String: Int] {
        var midiTargetChannels: [String: Int] = [:]
        var i: Int = 1
        set.tracks.forEach { track in
            midiTargetChannels[track.id] = i
            i += 1
        }
        return midiTargetChannels
    }
    
    internal func forwardEffect(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget) 
    {
        
        //            print("start forwardEffect \(damperTarget.trackId) \(damperTarget.nodeName) \(damperTarget.parameter)")
        
        guard let track = set.track(for: damperTarget.trackId) else { return }
        
        guard let effectType = InstrumentsSet.Track.Effect.EffectType(rawValue: damperTarget.nodeName) else { return }
        
        guard let effect = track.effect(for: effectType) else { return }
        
        //inverse value if requested in dampertarget
        let valueToApply = damperTarget.parameterInversed ? 1 - value : value
        
        //            print("APPLY \(valueToApply) to \(damperTarget.trackId) \(damperTarget.nodeName) \(damperTarget.parameter)")
        
        effect.apply(value: valueToApply, with: damperTarget)
    }
}
