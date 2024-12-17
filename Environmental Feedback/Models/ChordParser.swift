//
//  ChordParser.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 17/12/2024.
//

import Foundation

func parseChordName(_ chordName: String) -> (root: String, type: String)? {
    let possibleRoots = ["C", "C#", "Db", "D", "D#", "Eb", "E",
                         "F", "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B"]
    
    for rootCandidate in possibleRoots {
        if chordName.hasPrefix(rootCandidate) {
            let type = String(chordName.dropFirst(rootCandidate.count))
            return (root: rootCandidate, type: type)
        }
    }
    return nil
}

func chordToMidiNotes(_ chordName: String, baseMidiForC: Int = defaultBaseMidiForC) -> [UInt8] {
    guard let parsed = parseChordName(chordName),
          let rootOffset = noteBase[parsed.root.capitalized] else {
        return []
    }
    
    let rootMidi = baseMidiForC + rootOffset
    let intervals = chordFormulas[parsed.type] ?? [0, 4, 7] // default naar majeur drieklank
    let notes = intervals.map { interval in
        UInt8(rootMidi + interval)
    }
    return notes
}
