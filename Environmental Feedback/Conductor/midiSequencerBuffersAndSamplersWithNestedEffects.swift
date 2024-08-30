//
//  midiSequencerBuffersAndSamplersWithNestedEffects.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 29/08/2024.
//

import AudioKit
import AVFAudio

extension Conductor {
    
    internal func midiSequencerBuffersAndSamplersWithNestedEffects(
        for track: InstrumentsSet.Track,
        length: String,
        currentSetLevel: Double,
        midiChannels: inout [String: Int],
        samplePath: String) -> AppleSequencer? {
            
            // Use the 1st midi file defined.
            guard let midiFile = track.midiFiles?.first else {
                print("No MIDI file for track id: \(track.id)")
                return nil
            }
            
            //What is everyting running on?
            let sequencer = AppleSequencer()
            
            // Try loading MIDI file from the app bundle first
            if let bundlePath = Bundle.main.path(forResource: "Sounds/MIDI/\(midiFile.fileName)", ofType: "mid"),
               FileManager.default.fileExists(atPath: bundlePath) {
                sequencer.loadMIDIFile("Sounds/MIDI/\(midiFile.fileName)")
            }
            
            // If the file does not exist in the app bundle, try loading it from the documents directory
            else {
                
                let documentsDirectory = try? FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false)
                if let documentsDirectory = documentsDirectory {
                    
                    let fileURL = documentsDirectory.appendingPathComponent("\(set.filesPath)/\(midiFile.fileName).\(midiFile.fileExtension)")
                    
                    // Check if file exists at the destination URL
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        sequencer.loadMIDIFile(fromURL: fileURL)
                    } else {
                        print("MIDI file \(midiFile.fileName) does not exist at expected location: \(fileURL.path)")
                        return nil
                    }
                } else {
                    print("Couldn't find the documents directory.")
                    return nil
                }
            }
            
            sequencer.setTempo(set.bpm)
            
            //Default length of 1 loop, for midi memory we need the length of "completeSequenceFromMIDIfile" (the sum of loops)
            var duration = Duration(beats: midiFile.loopLength.first ?? 0)
            
            //MARK: Actual instruments are loaded in loopSequenceFromMIDIfile
            
            sequencer.setLength(duration)
            sequencer.setLoopInfo(duration, loopCount: 0)
            sequencer.enableLooping()
            
            trackSamplers[track.id] = createAudioBufferSamplerChainEffects(
                for: track,
                and: sequencer,
                currentSetLevel: currentSetLevel,
                samplePath: samplePath
            )
            
            
            return sequencer
        }
    
    internal func createExsSamplerChainEffects(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer) -> MIDISampler? {
            
            // Use the 1st exs file defined.
            guard let exsFile = track.exsFiles?.first else {
                print("No EXS file for track id: \(track.id)")
                return nil
            }
            
            let sampler = MIDISampler(name: track.instrumentName)
            sampler.amplitude = track.volume
            
            let chainEffects: Node = chainEffects(for: track, startingNode: sampler)
//            let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
            
            //Have an extra mixer to record
            trackMixers[track.id]?.addInput(chainEffects)
            
            //Send the record signal to the main out
            mixer.addInput(trackMixers[track.id]!)
            //mixer.addInput(ampEnv)
            
            do {
                // Recorder
                let avAudioFile = try AppUtils.createAvAudioFile(set: set, trackName: track.instrumentName)

                // Use trackMixers to record, you can also hear this signal
                let recorder = try NodeRecorder(node: trackMixers[track.id]!)
                recorder.createNewFile() // Maak een nieuw bestand aan

                // Bewaar de recorder
                trackRecorders[track.id] = recorder

                // Load EXS from File
                try sampler.loadEXS24("Sounds/Sampler Instruments/\(exsFile.fileName)")

            } catch {
                print("Error loading EXS: \(exsFile.fileName)")
            }
            
            return sampler
        }
    
}
