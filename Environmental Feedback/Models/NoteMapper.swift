//
//  NoteMapper.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 17/12/2024.
//

import Foundation

// Mapping van notennamen naar halfstep offset vanaf C
let noteBase: [String: Int] = [
    "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3,
    "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8,
    "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11
]

// Intervallen voor veel voorkomende akkoorden.
// Grondtoon = 0. Intervallen in halve toonstappen.
let chordFormulas: [String: [Int]] = [
    "maj7":      [0, 4, 7, 11],
    "m7":        [0, 3, 7, 10],
    "7":         [0, 4, 7, 10],
    "dim":       [0, 3, 6, 9],
    "aug":       [0, 4, 8],
    "sus2":      [0, 2, 7],
    "sus4":      [0, 5, 7],
    "6":         [0, 4, 7, 9],
    "m6":        [0, 3, 7, 9],
    "maj9":      [0, 4, 7, 11, 14],
    "m9":        [0, 3, 7, 10, 14],
    "add9":      [0, 4, 7, 14],
    "7b9":       [0, 4, 7, 10, 13],
    "7#9":       [0, 4, 7, 10, 15],
    "7b5":       [0, 4, 6, 10],
    "7#5":       [0, 4, 8, 10],
    "mmaj7":     [0, 3, 7, 11],
    "maj7#5":    [0, 4, 8, 11],
    "m7b5":      [0, 3, 6, 10],   // Half diminished
    "7#11":      [0, 4, 7, 10, 18],
    "maj7#11":   [0, 4, 7, 11, 18],
    "13":        [0, 4, 7, 10, 14, 17, 21],
    "m11":       [0, 3, 7, 10, 14, 17],
    "maj11":     [0, 4, 7, 11, 14, 17],
    "m13":       [0, 3, 7, 10, 14, 17, 21],
    "maj13":     [0, 4, 7, 11, 14, 17, 21],
    "dim7":      [0, 3, 6, 9],   // zelfde als "dim"
    "aug7":      [0, 4, 8, 10],
    "5":         [0, 7],         // Power chord
    "add11":     [0, 4, 7, 17],
    "add13":     [0, 4, 7, 21],
    "sus2add11": [0, 2, 7, 17]
]

// Standaardgrondtoon C3 = MIDI 48
let defaultBaseMidiForC = 48
