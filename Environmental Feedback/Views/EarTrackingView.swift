////
////  EarTrackingView.swift
////  Environmental Feedback
////
////  Created by Frans-Jan Wind on 24/08/2024.
////
//
//import SwiftUI
//
//struct EarTrackingView: UIViewControllerRepresentable {
//    @Binding var earDistance: CGFloat
//    
//    func makeUIViewController(context: Context) -> CameraViewController {
//        let cvc = CameraViewController()
//        cvc.earDistanceHandler = { distance in
//            DispatchQueue.main.async {
//                self.earDistance = distance
//            }
//        }
//        return cvc
//    }
//
//    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
//}
