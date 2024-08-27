//
//  EarTrailView.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 26/08/2024.
//
import SwiftUI

struct FaceLandmarkTrailView: View {
    @ObservedObject var noseData: NoseData
    
    var body: some View {
        ZStack {
            ForEach(0..<noseData.leftEarTrail.count, id: \.self) { index in
                Circle()
                    .fill(Color.purple)
                    .frame(width: 10, height: 10)
                    .position(x: noseData.leftEarTrail[index].x, y: noseData.leftEarTrail[index].y)
                    .opacity(Double(noseData.leftEarTrail.count - index) / Double(noseData.leftEarTrail.count))
                    .animation(.easeOut(duration: 0.5), value: noseData.leftEarTrail)
            }
            
            ForEach(0..<noseData.rightEarTrail.count, id: \.self) { index in
                Circle()
                    .fill(Color.orange)
                    .frame(width: 10, height: 10)
                    .position(x: noseData.rightEarTrail[index].x, y: noseData.rightEarTrail[index].y)
                    .opacity(Double(noseData.rightEarTrail.count - index) / Double(noseData.rightEarTrail.count))
                    .animation(.easeOut(duration: 0.5), value: noseData.rightEarTrail)
            }
            
            ForEach(0..<noseData.noseTrail.count, id: \.self) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .position(x: noseData.noseTrail[index].x, y: noseData.noseTrail[index].y)
                    .opacity(Double(noseData.noseTrail.count - index) / Double(noseData.noseTrail.count))
                    .animation(.easeOut(duration: 0.5), value: noseData.noseTrail)
            }
        }
    }
}
