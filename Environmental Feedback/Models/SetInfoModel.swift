//
//  SetInfoModel.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 30/08/2024.
//

import Foundation

final class SetInfoModel: ObservableObject {
    
    let currentInstrumentsSetIsChanged: (InstrumentsSet) -> ()
    var conductor: Conductor
        
    init(
        currentInstrumentsSetIsChanged: @escaping (InstrumentsSet) -> Void,
        conductor: Conductor
    ) {
        self.currentInstrumentsSetIsChanged = currentInstrumentsSetIsChanged
        self.conductor = conductor
    }
}
