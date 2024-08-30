//
//  Conductor.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 29/08/2024.
//

import AudioKit

final class Conductor {
    
    //MARK: Var declarations
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
            trackSequencers[track.id] = midiSequencerBuffersAndSamplersWithNestedEffects(
                for: track,
                length: "loopSequenceFromMIDIfile",
                currentSetLevel: currentSetLevel,
                midiChannels: &midiChannels,
                samplePath: set.filesPath
            )
        }
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
}
