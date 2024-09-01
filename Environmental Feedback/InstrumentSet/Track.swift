//
//  Track.swift
//  Track
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI
import Accelerate
import AudioToolbox

extension InstrumentsSet {
    
    struct Track: Identifiable, Decodable {
        
        static func withJSON(_ fileName: String) -> InstrumentsSet.Track? {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Sets") else { return nil }
            guard let data = try? Data(contentsOf: url) else { return nil }
            return try! JSONDecoder().decode(InstrumentsSet.Track.self, from: data)
        }
        
        private enum TrackKeys: String, CodingKey {
            case id
            case trackId
            case muted
            case instrumentType
            case noteSource
            case chordEntries
            case variationType = "trackType"
            case instrumentName
            case instrumentColor
            case volume = "instrumentVolume"
            case midiFiles
            case midiGroup
            case notesToGrid
            case notesToLevel
            case noteNumbersClips
            case notesSequenceType
            case exsFiles
            case audioFiles
            case effects
            case parts = "instrumentParts"
            case levels
        }
        
        var id: String
        var trackId: String
        var muted: Bool? = true
        //Sound source / generator
        let instrumentType: InstrumentType
        
        var instrumentName: String
        let instrumentColor: Color
        var volume: Float
        
        var midiFiles: [MidiFile]?
                
        let exsFiles: [ExsFile]?
        let audioFiles: [AudioFile]?
        var effects: [Effect]?
        
        let levels: [Int]
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: TrackKeys.self)
            id = try container.decode(String.self, forKey: .trackId)
            trackId = try container.decode(String.self, forKey: .trackId)
            instrumentType = try container.decode(InstrumentType.self, forKey: .instrumentType)
            
            muted = try container.decodeIfPresent(Bool.self, forKey: .muted)
            instrumentName = try container.decode(String.self, forKey: .instrumentName)
            
            let instrumentColorString = try container.decodeIfPresent(String.self, forKey: .instrumentColor)
            instrumentColor = Color(instrumentColorString ?? "InstrumentColor000")
            
            volume = try container.decode(Float.self, forKey: .volume)
            midiFiles = try container.decodeIfPresent([MidiFile].self, forKey: .midiFiles)
            
            exsFiles = try container.decodeIfPresent([ExsFile].self, forKey: .exsFiles)
            audioFiles = try container.decodeIfPresent([AudioFile].self, forKey: .audioFiles)
            
            //Have effectsRaw raw present to use as data struct
            let effectsRaw = try container.decodeIfPresent([Effect].self, forKey: .effects)
            effects = effectsRaw
            
            levels = try container.decode([Int].self, forKey: .levels)
        }
        
        init(
            id: String,
            trackId: String,
            muted: Bool?,
            instrumentType: InstrumentType,
            instrumentName: String,
            instrumentColor: Color,
            volume: Float,
            midiFiles: [MidiFile]?,
            midiGroup: [Int]?,
            notesToGrid: [Int]?,
            notesToLevel: [Int]?,
            noteNumbersClips: [Int]?,
            exsFiles: [ExsFile]?,
            audioFiles: [AudioFile]?,
            effects: [Effect]?,
            parts: [Part],
            levels: [Int]
        ) {
            self.id = id
            self.trackId = trackId
            self.muted = muted
            self.instrumentType = instrumentType
            self.instrumentName = instrumentName
            self.instrumentColor = instrumentColor
            self.volume = volume
            self.midiFiles = midiFiles
            self.exsFiles = exsFiles
            self.audioFiles = audioFiles
            self.effects = effects
            self.levels = levels
        }
        
        func effect(for effectType: Effect.EffectType) -> Effect? {
            effects?.first { $0.effectType == effectType }
        }
    }
}

extension InstrumentsSet.Track: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TrackKeys.self)
        try container.encode(trackId, forKey: .trackId)
        try container.encode(muted, forKey: .muted)
        try container.encode(instrumentType, forKey: .instrumentType)
        try container.encode(instrumentName, forKey: .instrumentName)
        let codableColor = CodableColor(color: instrumentColor)
        try container.encode(codableColor, forKey: .instrumentColor)
        try container.encode(volume, forKey: .volume)
        try container.encode(midiFiles, forKey: .midiFiles)
        try container.encode(exsFiles, forKey: .exsFiles)
        try container.encode(audioFiles, forKey: .audioFiles)
        try container.encode(effects, forKey: .effects)
        try container.encode(levels, forKey: .levels)
    }
}

extension InstrumentsSet.Track {
    
    enum InstrumentType: String, Codable, CaseIterable {
        case exsSampler
        case audioBuffer
        case audioBufferTimed
        case SemOne
        case pulseWidthSynth
        case phaseSynth
        
        var description: String {
            switch self{
            case .exsSampler:
                return "EXS sampler"
            case .audioBuffer:
                return "Buffer sampler"
            case .audioBufferTimed:
                return "Stretched buffer sampler"
            case .SemOne:
                return "SeMOne Synth"
            case .pulseWidthSynth:
                return "Pulse Width Modulation Synth"
            case .phaseSynth:
                return "Phase Synth"
            }
        }
    }
}

extension InstrumentsSet.Track {
    
    struct ExsFile: Decodable {
        
        private enum ExsKeys: String, CodingKey {
            case fileName = "exsFileName"
            case fileExtension = "exsFileExt"
        }
        
        let fileName: String
        let fileExtension: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: ExsKeys.self)
            fileName = try container.decode(String.self, forKey: .fileName)
            fileExtension = try container.decode(String.self, forKey: .fileExtension)
        }
        
        init(fileName: String){
            self.fileName = fileName
            self.fileExtension = "exs"
        }
    }
}

extension InstrumentsSet.Track.ExsFile: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ExsKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileExtension, forKey: .fileExtension)
    }
}

extension InstrumentsSet.Track {

    struct AudioFile: Decodable, Identifiable {
        private enum AudioFileKeys: String, CodingKey {
            case id
            case fileName
            case fileExtension
            case lengthInBeats
            case source
        }
        
        let id: UUID
        let fileName: String
        let fileExtension: String
        var lengthInBeats: Double
        let source: InstrumentsSet.FileSource

        init(from decoder: Decoder) throws {
            self.id = UUID()
            let container = try decoder.container(keyedBy: AudioFileKeys.self)
            fileName = try container.decode(String.self, forKey: .fileName)
            fileExtension = try container.decode(String.self, forKey: .fileExtension)
            lengthInBeats = try container.decode(Double.self, forKey: .lengthInBeats)
            source = try container.decodeIfPresent(InstrumentsSet.FileSource.self, forKey: .source) ?? .user
        }

        init(
            fileName: String,
            fileExtension: String,
            lengthInBeats: Double,
            source: InstrumentsSet.FileSource
        ){
            self.id = UUID()
            self.fileName = fileName
            self.fileExtension = fileExtension
            self.lengthInBeats = lengthInBeats
            self.source = source
        }
    }
}

extension InstrumentsSet.Track.AudioFile: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AudioFileKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileExtension, forKey: .fileExtension)
        try container.encode(lengthInBeats, forKey: .lengthInBeats)
        try container.encode(source, forKey: .source)
    }
}

