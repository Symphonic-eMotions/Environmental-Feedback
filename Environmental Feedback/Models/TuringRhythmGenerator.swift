import Foundation

class TuringRhythmGenerator: ObservableObject {
    @Published var pattern: [Int] = Array(repeating: 0, count: 16)
    @Published var density: Double = 0.5
    @Published var feedback: Double = 0.1

    private var isLocked = false
    
    func resetPattern() {
        pattern = Array(repeating: 0, count: pattern.count)
    }

    func step() {
        guard !isLocked else { return }
        
        pattern.removeLast()
        let newBit = Double.random(in: 0...1) < density ? 1 : 0
        pattern.insert(newBit, at: 0)
        
        if Double.random(in: 0...1) < feedback {
            let randomIndex = Int.random(in: 0..<pattern.count)
            pattern[randomIndex] = pattern[randomIndex] == 1 ? 0 : 1
        }
    }

    func lockPattern() {
        isLocked = true
    }
    
    func unlockPattern() {
        isLocked = false
    }
}

