import SwiftUI

struct TuringView: View {
    @StateObject var viewModel = ViewModel()
    @State private var showShareSheet = false
    
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
                
                Text("Feedback: \(viewModel.generator.feedback, specifier: "%.2f")")
                Slider(value: $viewModel.generator.feedback, in: 0...1)
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
                
                Button("Unlock Pattern") {
                    viewModel.unlockPattern()
                }
                .padding()
            }
            
            // Nu delen we midiDocument in plaats van de URL direct.
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
