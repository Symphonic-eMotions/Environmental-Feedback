//
//  MultiSliderView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 16/08/2024.
//

import SwiftUI

struct MultiSliderView: View {
    
    @Binding var values: [Float]
    var labels: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(0..<values.count, id: \.self) { index in
                VStack(alignment: .leading) {
                    Text(labels[index])
                        .font(.headline)
                    Slider(value: Binding(
                        get: {
                            self.values[index]
                        },
                        set: { newValue in
                            self.values[index] = newValue
                            // Hier kun je de code toevoegen om je audio effect aan te sturen
                            self.updateAudioEffect(index: index, value: newValue)
                        }
                    ), in: 0...1)
                }
            }
        }
        .padding()
    }
    
    func updateAudioEffect(index: Int, value: Float) {
        // Voeg hier de logica toe om de respectieve audio-effectparameter bij te werken
        print("Updated parameter \(labels[index]) to \(value)")
        // Bijvoorbeeld: audioManager.updateEffectParameter(index, value)
    }
}
