//
//  CSVDocument.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Utils/CSVDocument.swift  // <-- [ADDED]
import SwiftUI
import UniformTypeIdentifiers

struct CSVDocument: FileDocument {                     // <-- [ADDED]
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    static var writableContentTypes: [UTType] { [.commaSeparatedText] }

    var text: String

    init(text: String) { self.text = text }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let str = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = str
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return .init(regularFileWithContents: data)
    }
}
