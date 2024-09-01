//
//  DamperTarget.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 20/07/2023.
//

import Foundation

extension InstrumentsSet.Track.Part {
    
    struct DamperTarget: Decodable, Equatable {
        
        internal enum TargetKeys: String, CodingKey {
            case trackId
            case nodeType
            case nodeName
            case parameter
            //Copy effect range to DamperTarget if it conserns an effect
            case parameterRange
            case parameterInversed
        }
        
        var trackId: String
        var nodeType: NodeType
        var nodeName: String
        var parameter: String
        var parameterRange: [Double]
        var parameterInversed: Bool
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: TargetKeys.self)
            trackId = try container.decode(String.self, forKey: .trackId)
            nodeType = try container.decode(NodeType.self, forKey: .nodeType)
            nodeName = try container.decode(String.self, forKey: .nodeName)
            parameter = try container.decode(String.self, forKey: .parameter)
            parameterRange = [0,1]
            parameterInversed = try container.decodeIfPresent(Bool.self, forKey: .parameterInversed) ?? false
        }
        
        //Master track controller init
        init(
            trackIdString: String,
            nodeNameString: String,
            parameterString: String,
            parameterRangeArray: [Double],
            parameterInversedBool: Bool
        ) {
            trackId = trackIdString
            nodeName = nodeNameString
            parameter = parameterString
            parameterRange = parameterRangeArray
            nodeType = .master
            parameterInversed = parameterInversedBool
        }
        
        //Store to file init
        init(
            trackId: String,
            nodeType: NodeType,         //targetType
            nodeName: String,           //targetNameEffect
            parameter: String,          //parameter
            parameterRange: [Double],
            parameterInversed: Bool
        ) {
            self.trackId = trackId
            self.nodeType = nodeType
            self.nodeName = nodeName
            self.parameter = parameter
            self.parameterRange = parameterRange
            self.parameterInversed = parameterInversed
        }
        
        //Place holder for ranges from track effects towards controlling part effects
        func getParameterRange() -> [Double] {
            
            return [0,100]
        }
    }
}

extension InstrumentsSet.Track.Part.DamperTarget: Encodable{
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TargetKeys.self)
        try container.encode(trackId, forKey: .trackId)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encode(nodeName, forKey: .nodeName)
        try container.encode(parameter, forKey: .parameter)
        try container.encode(parameterRange, forKey: .parameterRange)
        try container.encode(parameterInversed, forKey: .parameterInversed)
    }
}

extension InstrumentsSet.Track.Part.DamperTarget {
    
    enum NodeType: String, Codable, CaseIterable {
        case sequencer
        case effect
        case instrument
        case master
        
        var description: String {
            switch self{
            case .sequencer:
                return "Sequencer"
            case .effect:
                return "Effect"
            case .instrument:
                return "Instrument"
            case .master:
                return "Master"
            }
        }
    }
}
