import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var midi: UTType {
        // Indien public.midi-audio niet bestaat, fallback op .data of gebruik een ander passend type.
        UTType("public.midi-audio") ?? .data
    }
}

struct MIDIFileDocument: FileDocument, Transferable {
    static var readableContentTypes: [UTType] = [.midi]
    
    var midiData: Data
    
    init(midiData: Data) {
        self.midiData = midiData
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw URLError(.badServerResponse)
        }
        self.midiData = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: midiData)
    }
    
    // MARK: - Transferable conformiteit
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .midi) { file in
            // Hoe we het bestand exporteren: hier is dat gewoon de data
            file.midiData
        } importing: { data in
            // Hoe we het bestand importeren: hier maken we een nieuw MIDIFileDocument aan
            MIDIFileDocument(midiData: data)
        }
    }
}
