//
//  midiNoteNumberFromFileName.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 30/08/2024.
//

import Foundation

extension Conductor {
    
    public func midiNoteNumberFromFileName(_ fileName: String, separators: [Character] = ["_", "-", "/"]) -> Int? {
        
        let noteNameToMidi: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5,
            "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11
        ]
        let baseMidiNoteNumberForC0 = 12
        
        // Split the string into components using "_" as the separator
        let components = fileName.split{ separators.contains($0) }
        guard let lastComponent = components.last else { return nil }
        
        // Get the note and octave parts
        var note = ""
        var octave = ""
        for char in lastComponent {
            if char.isLetter || char == "#" {
                note.append(char)
            } else if char.isNumber {
                octave.append(char)
            }
        }
        
        guard let noteValue = noteNameToMidi[note] else { return nil }
        guard let octaveValue = Int(octave) else { return nil }
        
        return baseMidiNoteNumberForC0 + (octaveValue * 12) + noteValue
    }
}

