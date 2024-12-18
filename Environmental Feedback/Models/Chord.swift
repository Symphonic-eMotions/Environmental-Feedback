//
//  Chord.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 17/12/2024.
//

import Foundation

struct Chord: Decodable {
    let chord: String
    let duration: Int
}

typealias ChordProgression = [Chord]
typealias ChordProgressions = [ChordProgression]
