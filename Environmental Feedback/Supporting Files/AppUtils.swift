//
//  AppUtils.swift
//  Environmental Feedback
//
//  Created by Frans-Jan Wind on 30/08/2024.
//

import AVFAudio

final class AppUtils {
    
    //MARK: crate folder for track recording
    static func createAvAudioFile (
        set: InstrumentsSet,
        trackName: String
    ) throws -> AVAudioFile {
        
        let fileManager = FileManager.default
        
        // Base documents path
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Create subfolders
        let setName = ( set.customName != "" ) ? set.customName : set.name
        let mainFolderName = "Recordings"
        let subFolderName = "\(setName)"
        
        // Full folder path
        let mainFolderPath = documentsPath.appendingPathComponent(mainFolderName)
        let subFolderPath = mainFolderPath.appendingPathComponent(subFolderName)
        
        // Create main folder if it doesn't exist
        if !fileManager.fileExists(atPath: mainFolderPath.path) {
            try fileManager.createDirectory(at: mainFolderPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Create subfolder if it doesn't exist
        if !fileManager.fileExists(atPath: subFolderPath.path) {
            try fileManager.createDirectory(at: subFolderPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Output file within the subfolder
        let outputFile = subFolderPath.appendingPathComponent("\(trackName).aac")
        
        // File settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16
        ]
        
        do {
            // File to write recording to
            let avAudioFile = try AVAudioFile(forWriting: outputFile, settings: settings)
            return avAudioFile
            
        } catch {
            print("Error creating record file \(trackName)")
            throw error // Propagate the error upwards
        }
    }
    
}
