//
//  FFTView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 11/08/2024.
//

import SwiftUI
import AudioKit
import AudioKitEX
import AudioKitUI

struct FFTView: View {
    @ObservedObject var fftData: FFTData

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let binWidth = max(1.0, width / CGFloat(fftData.amplitudes.count))

            Path { path in
                for (index, amplitude) in fftData.amplitudes.enumerated() {
                    let x = CGFloat(index) * binWidth
                    let y = height - CGFloat(amplitude) * height
                    path.addRect(CGRect(x: x, y: y, width: binWidth, height: CGFloat(amplitude) * height))
                }
            }
            .fill(Color.blue)
        }
    }
}

class FFTData: ObservableObject {
    @Published var amplitudes: [Float] = Array(repeating: 0.0, count: 512)

    func update(with fftData: [Float]) {
        DispatchQueue.main.async {
            self.amplitudes = fftData
        }
    }
}
