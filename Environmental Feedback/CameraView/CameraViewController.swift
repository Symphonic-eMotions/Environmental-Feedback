//
//  CameraViewController.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 24/08/2024.
//  Copied from:
/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.

import UIKit
import Vision
import AVFoundation

final class CameraViewController: UIViewController {
    private var cameraView: CameraPreview { view as! CameraPreview }
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private let earPoseRequest = VNDetectFaceLandmarksRequest()
    
    var earDistanceHandler: ((CGFloat) -> Void)?
    var earPointsHandler: ((CGPoint, CGPoint) -> Void)?
    var nosePointHandler: ((CGPoint) -> Void)?

    override func loadView() {
        view = CameraPreview()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
                cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            cameraFeedSession?.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }

    private func setupAVSession() throws {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }

        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high

        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)

        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }

    private func processFaceLandmarks(_ landmarks: VNFaceLandmarks2D) {
        guard let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye else {
            return
        }

        // Converteer en corrigeer de Y-coördinaat
        let leftEyePoint = cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: leftEye.normalizedPoints.first!.x, y: 1 - leftEye.normalizedPoints.first!.y))
        let rightEyePoint = cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: rightEye.normalizedPoints.first!.x, y: 1 - rightEye.normalizedPoints.first!.y))

        // Bereken de afstand tussen de ogen
        let distance = hypot(leftEyePoint.x - rightEyePoint.x, leftEyePoint.y - rightEyePoint.y)
        earDistanceHandler?(distance)
        
        // Oogcorrectie toevoegen (optioneel, vergelijkbaar met de neus)
        let eyeOffsetY: CGFloat = distance * 0.1 // Kleine verticale aanpassing voor de ogen

        let correctedLeftEyePoint = CGPoint(x: leftEyePoint.x, y: leftEyePoint.y + eyeOffsetY)
        let correctedRightEyePoint = CGPoint(x: rightEyePoint.x, y: rightEyePoint.y + eyeOffsetY)

        earPointsHandler?(correctedLeftEyePoint, correctedRightEyePoint)
        
        // Neuspositie berekenen en corrigeren
        if let nose = landmarks.nose {
            let nosePoint = cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: nose.normalizedPoints.first!.x, y: 1 - nose.normalizedPoints.first!.y))

            // Voeg een correctie toe om de neus lager te plaatsen
            let noseOffsetY: CGFloat = distance * 0.45 // Kleine verticale aanpassing voor de neus
            let correctedNosePoint = CGPoint(x: nosePoint.x, y: nosePoint.y + noseOffsetY)
            
            nosePointHandler?(correctedNosePoint)
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([earPoseRequest])
            guard let results = earPoseRequest.results, let face = results.first else {
                return
            }
            if let landmarks = face.landmarks {
                processFaceLandmarks(landmarks)
            }
        } catch {
            cameraFeedSession?.stopRunning()
            print(error.localizedDescription)
        }
    }
}
