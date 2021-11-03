//
//  VideoConverterError.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import Foundation

public enum VideoConverterError: Error {
    
    case fileNotSpecified
    case fileExtensionNotSupported(_ fileExtension: String?)
    case filePermissionNotAllowed(_ url: URL)
    case failedToRemovePercentEncoding(_ url: URL)
    case failedToEncodeStringToData(_ string: String, _ script: VideoScript)
    case failedToParseProbeOutput(_ output: String, _ script: VideoScript)
    case noKeyFound(_ key: String, _ script: VideoScript)
    
    public var localizedDescription: String {
        switch self {
        case .fileNotSpecified:
            return "File not specified. Please choose a file."
        case .fileExtensionNotSupported(let fileExtension):
            return "Uh oh, we don't support \(fileExtension ?? "those") files yet! Sorry!"
        case .filePermissionNotAllowed:
            return "Oops! Looks like we don't have permissions to access this file. Please try again."
        case .failedToRemovePercentEncoding:
            return "Failed to remove percent encoding from absolute Url"
        case .failedToEncodeStringToData(let string, let script):
            return "Failed to encode string to data.\nString: \(string)\nCommand: \(script.command)"
        case .failedToParseProbeOutput(let output, let script):
            return "Failed to parse probe output of \(script.inputFile) with command: \(script.command)\nOutput: \(output)"
        case .noKeyFound(let key, let stream):
            return "No key found: \(key) while parsing result from command: \(stream.command)"
        }
    }
}
