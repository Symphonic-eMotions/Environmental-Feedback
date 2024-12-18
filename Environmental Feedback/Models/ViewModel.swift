import Foundation
import AVFoundation
import MusicKit

class ViewModel: ObservableObject {
    @Published var chords: ChordProgression = []
    @Published var generator = TuringRhythmGenerator()
    @Published var midiFileURL: URL? = nil
    @Published var midiDocument: MIDIFileDocument? = nil
    
    @Published var sequencerManager = SequencerManager()
    @Published var sequencerLoaded = false
    
    init() {
        loadRandomChordProgression()
    }
    
    func loadRandomChordProgression() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonURL = documentsURL.appendingPathComponent("chordProgressions.json")
        
        guard FileManager.default.fileExists(atPath: jsonURL.path) else {
            print("No chordProgressions.json found in Documents directory")
            return
        }
        
        do {
            let data = try Data(contentsOf: jsonURL)
            let allProgressions = try JSONDecoder().decode(ChordProgressions.self, from: data)
            
            if let randomProgression = allProgressions.randomElement() {
                self.chords = randomProgression
                print("Loaded random chord progression")
            } else {
                print("No progressions found in file.")
            }
        } catch {
            print("Error loading chords from Documents: \(error)")
        }
    }
    
    func regeneratePattern() {
        generator.unlockPattern()
        generator.resetPattern()
        for _ in 0..<16 {
            generator.step()
        }
    }

    func generateNextStep() {
        generator.step()
    }
    
    func lockPatternAndCreateMIDI() {
        generator.lockPattern()
        
        guard let data = createMIDIData() else { return }
        
        // Schrijf MIDI naar file
        if let midiURL = saveMIDIToFile(data) {
            self.midiFileURL = midiURL
            self.midiDocument = MIDIFileDocument(midiData: data)
        }
    }
    
    func lockPatternAndLoadIntoSequencer() {
        generator.lockPattern()
        
        guard let data = createMIDIData() else { return }
        
        // Laad in sequencer
        sequencerManager.loadMIDIData(data)
        sequencerLoaded = true
    }
    
    private func createMIDIData() -> Data? {
        var musicSequence: MusicSequence?
        NewMusicSequence(&musicSequence)
        guard let sequence = musicSequence else { return nil }
        
        var track: MusicTrack?
        MusicSequenceNewTrack(sequence, &track)
        guard let mainTrack = track else { return nil }
        
        var currentBeat: MusicTimeStamp = 0.0
        for chord in chords {
            let stepsPerChord = 16
            let stepDuration = Double(chord.duration) / Double(stepsPerChord)
            let chordNotes = chordToMidiNotes(chord.chord)

            for i in 0..<stepsPerChord {
                if generator.pattern[i] == 1 {
                    let startTime = currentBeat + Double(i) * stepDuration
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
        
        // Exporteer naar Data
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.mid")
        MusicSequenceFileCreate(sequence, tempURL as CFURL, .midiType, .eraseFile, 480)
        
        return try? Data(contentsOf: tempURL)
    }
    
    private func saveMIDIToFile(_ data: Data) -> URL? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = formatter.string(from: Date())

        let fileName = "pattern_\(dateString).mid"
        let midiURL = documentsURL.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: midiURL.path) {
            try? FileManager.default.removeItem(at: midiURL)
        }
        
        do {
            try data.write(to: midiURL)
            return midiURL
        } catch {
            print("Error writing MIDI file: \(error)")
            return nil
        }
    }
    
    func playSequencer() {
        sequencerManager.play()
    }
    
    func stopSequencer() {
        sequencerManager.stop()
    }
}
