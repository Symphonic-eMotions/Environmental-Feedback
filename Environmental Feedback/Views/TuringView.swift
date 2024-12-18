import SwiftUI

struct TuringView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Chords: \(viewModel.chords.map {$0.chord}.joined(separator: ", "))")
                .padding()
            
            HStack {
                ForEach(viewModel.generator.pattern.indices, id: \.self) { i in
                    Rectangle()
                        .fill(viewModel.generator.pattern[i] == 1 ? Color.blue : Color.gray)
                        .frame(width: 10, height: 20)
                }
            }
            
            VStack {
                Text("Density: \(viewModel.generator.density, specifier: "%.2f")")
                Slider(value: $viewModel.generator.density, in: 0...1)
                    .onChange(of: viewModel.generator.density) {
                        viewModel.regeneratePattern()
                    }

                Text("Feedback: \(viewModel.generator.feedback, specifier: "%.2f")")
                Slider(value: $viewModel.generator.feedback, in: 0...1)
                    .onChange(of: viewModel.generator.feedback) {
                        viewModel.regeneratePattern()
                    }
            }
            .padding()
            
            HStack {
                Button("Step Pattern") {
                    viewModel.generateNextStep()
                }
                .padding()
                
                Button("Lock & Export MIDI") {
                    viewModel.lockPatternAndCreateMIDI()
                }
                .padding()
                
                Button("Lock & Load") {
                    viewModel.lockPatternAndLoadIntoSequencer()
                }
                .padding()
            }

            // Als er een sequencer geladen is, toon dan Play/Stop knoppen
            if viewModel.sequencerLoaded {
                HStack {
                    if viewModel.sequencerManager.isPlaying {
                        Button("Stop") {
                            viewModel.stopSequencer()
                        }
                    } else {
                        Button("Play") {
                            viewModel.playSequencer()
                        }
                    }
                }
                .padding()
            }

            // Download MIDI knop blijft staan als er een midiDocument is
            if let midiDoc = viewModel.midiDocument {
                ShareLink(item: midiDoc, preview: SharePreview("Pattern.mid")) {
                    Text("Download MIDI")
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}
