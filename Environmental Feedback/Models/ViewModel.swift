import Foundation
import AVFoundation
import CoreMIDI
import MusicKit

class ViewModel: ObservableObject {
    @Published var chords: ChordProgression = []
    @Published var generator = TuringRhythmGenerator()
    @Published var midiFileURL: URL? = nil
    @Published var midiDocument: MIDIFileDocument? = nil

    init() {
        loadChordProgression()
    }
    
    func loadChordProgression() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonURL = documentsURL.appendingPathComponent("chordProgression.json")
        
        guard FileManager.default.fileExists(atPath: jsonURL.path) else {
            print("No chordProgression.json found in Documents directory")
            return
        }
        
        do {
            let data = try Data(contentsOf: jsonURL)
            let chords = try JSONDecoder().decode(ChordProgression.self, from: data)
            self.chords = chords
            print("Successfully loaded chord progression from Documents")
        } catch {
            print("Error loading chords from Documents: \(error)")
        }
    }
    
    func generateNextStep() {
        generator.step()
    }
    
    func lockPatternAndCreateMIDI() {
        generator.lockPattern()
        
        var musicSequence: MusicSequence?
        NewMusicSequence(&musicSequence)
        guard let sequence = musicSequence else { return }
        
        var track: MusicTrack?
        MusicSequenceNewTrack(sequence, &track)
        guard let mainTrack = track else { return }

        var currentBeat: MusicTimeStamp = 0.0
        
        for chord in chords {
            let stepsPerChord = 16
            let stepDuration = Double(chord.duration) / Double(stepsPerChord)
            
            // Haal hier de volledige set noten uit het akkoord
            let chordNotes = chordToMidiNotes(chord.chord)

            for i in 0..<stepsPerChord {
                if generator.pattern[i] == 1 {
                    let startTime = currentBeat + Double(i) * stepDuration
                    // Voeg alle noten van het akkoord toe
                    for noteMidi in chordNotes {
                        var note = MIDINoteMessage(channel: 0,
                                                   note: noteMidi,
                                                   velocity: 64,
                                                   releaseVelocity: 0,
                                                   duration: Float32(stepDuration))
                        MusicTrackNewMIDINoteEvent(mainTrack, startTime, &note)
                    }
                }
            }
            
            currentBeat += Double(chord.duration)
        }
        
        // Sla het MIDI bestand op in Documents
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let midiURL = documentsURL.appendingPathComponent("pattern.mid")
        
        if FileManager.default.fileExists(atPath: midiURL.path) {
            try? FileManager.default.removeItem(at: midiURL)
        }
        
        let status = MusicSequenceFileCreate(sequence, midiURL as CFURL, .midiType, .eraseFile, 480)
        print("MusicSequenceFileCreate status: \(status)")
        
        self.midiFileURL = midiURL
        
        // Lees data in en maak MIDIFileDocument
        if let data = try? Data(contentsOf: midiURL) {
            self.midiDocument = MIDIFileDocument(midiData: data)
        }
    }
    
    func unlockPattern() {
        generator.unlockPattern()
    }
}
