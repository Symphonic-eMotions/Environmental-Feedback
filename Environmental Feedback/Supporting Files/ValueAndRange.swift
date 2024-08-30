//
//  ValueAndRange.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 30/08/2024.
//

import Foundation
import AudioKit

struct ValueAndRange: Codable {
    
    static var zero: ValueAndRange { .init(value: 0, range: [0, 1]) }
    
    var value: AUValue
    var range: [Double]
}

extension ValueAndRange {
    
    enum CodingKeys: String, CodingKey {
        case value
        case range
    }
}
