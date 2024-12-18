import AVFoundation

class SequencerManager: ObservableObject {
    private var engine = AVAudioEngine()
    private var sequencer: AVAudioSequencer?
    private var sampler = AVAudioUnitSampler()
    
    @Published var isPlaying = false
    
    init() {
        // Audio setup
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        // Eventueel een soundfont laden als je die hebt
        // let soundFontURL = Bundle.main.url(forResource: "YourSoundFont", withExtension: "sf2")!
        // try? sampler.loadSoundBankInstrument(at: soundFontURL, program: 0, bankMSB: 0x79, bankLSB: 0x00)
        
        sequencer = AVAudioSequencer(audioEngine: engine)
    }
    
    func loadMIDIData(_ midiData: Data) {
        guard let seq = sequencer else { return }
        do {
            try seq.load(from: midiData, options: .smf_ChannelsToTracks)
            seq.prepareToPlay()
        } catch {
            print("Error loading MIDI: \(error)")
        }
    }
    
    func play() {
        guard let seq = sequencer else { return }
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                print("Could not start engine: \(error)")
            }
        }
        seq.currentPositionInBeats = 0
        do {
            try seq.start()
            isPlaying = true
        } catch {
            print("Could not start sequencer: \(error)")
        }
    }
    
    func stop() {
        sequencer?.stop()
        isPlaying = false
    }
}
