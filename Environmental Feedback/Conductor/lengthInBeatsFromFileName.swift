//
//  lengthInBeatsFromFileName.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 30/08/2024.
//

extension Conductor {
    
    public func lengthInBeatsFromFileName(fileName: String, separators: [Character] = ["_", "-", "/"]) -> Double? {
        
        let components = fileName.split { separators.contains($0) }
        
        guard components.count >= 2 else {
            print("Unable to find length in beats in filename \(fileName).")
            return nil
        }
        
        // Assuming the length in beats is the second component from the end
        let lengthInBeatsString = components[components.count - 2]
        
        if let lengthInBeats = Double(lengthInBeatsString) {
            return lengthInBeats
        } else {
            return nil
        }
    }
}


