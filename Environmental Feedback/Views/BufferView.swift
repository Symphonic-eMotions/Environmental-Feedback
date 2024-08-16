//
//  BufferView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 16/08/2024.
//

import SwiftUI

struct BufferView: View {

    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack {
            ZStack {
                FFTView(fftData: audioManager.fftData)
                    .frame(height: 120)
                    .padding()
                Text("Buffer")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(0.3)
            }
        }
    }
}
