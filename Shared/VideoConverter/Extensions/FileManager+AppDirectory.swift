//
//  AllTheFiles.swift
//  Oatmeal
//
//  Created by Bri on 11/4/21.
//

import Foundation

extension FileManager {
    
    func setUpAppDirectory() throws {
        if !FileManager.default.fileExists(atPath: appDirectory.absoluteString) {
            try FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
    }
    
    var appDirectoryName: String {
        Bundle.main.bundleIdentifier ?? "Converted\\ Videos"
    }
    
    var appDirectory: URL {
        let documentDirectories = urls(for: .documentDirectory, in: .userDomainMask)
        let firstDocumentDirectory = documentDirectories[0]
        return firstDocumentDirectory.appendingPathComponent(appDirectoryName)
    }
}
