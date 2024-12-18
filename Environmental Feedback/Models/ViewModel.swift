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
            
            // Kies een willekeurige index
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
                        guard let mainTrack = track else {
                            print("Could not create music track")
                            return
                        }
                        MusicTrackNewMIDINoteEvent(mainTrack, startTime, &note)
                    }
                }
            }
            currentBeat += Double(chord.duration)
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = formatter.string(from: Date())

        let fileName = "pattern_\(dateString).mid"
        let midiURL = documentsURL.appendingPathComponent(fileName)

        
        if FileManager.default.fileExists(atPath: midiURL.path) {
            try? FileManager.default.removeItem(at: midiURL)
        }
        
        MusicSequenceFileCreate(sequence, midiURL as CFURL, .midiType, .eraseFile, 480)
        
        self.midiFileURL = midiURL
        
        if let data = try? Data(contentsOf: midiURL) {
            self.midiDocument = MIDIFileDocument(midiData: data)
        }
    }
    
    func regeneratePattern() {
        // Zorg dat we niet locked zijn
        generator.unlockPattern()
        // Reset pattern zodat we met een schone lei beginnen
        generator.resetPattern()
        // Genereer meteen een paar stappen zodat het effect direct zichtbaar is
        // Hoeveel stappen je zet is arbitrair, hieronder zetten we bijvoorbeeld 16 stappen:
        for _ in 0..<16 {
            generator.step()
        }
    }
}
