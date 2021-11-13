//
//  VideoConversionScript.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import Foundation

public struct VideoConversionScript {
    
    public var inputFile: URL
    public var outputDirectory: URL
    public var codec: VideoCodec
    
    public var outputCodec: String { codec.rawValue }
    public var inputExtension: String { inputFile.pathExtension }
    public var outputExtension: String { codec.fileExtension.rawValue }
    public var outputOptions: String { codec.customOptions }
    public var outputFile: URL {
        outputDirectory.appendingPathComponent(inputFile.deletingPathExtension().lastPathComponent).appendingPathExtension(codec.fileExtension.rawValue)
    }
    public var filename: String {
        outputFile.lastPathComponent
    }
    public var temporaryFile: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    }
    public var absoluteInputFile: String {
        (inputFile.absoluteString.removingPercentEncoding ?? "")
    }
    public var absoluteTemporaryFile: String {
        (temporaryFile.absoluteString.removingPercentEncoding ?? "")
    }
    public func command() throws -> String {
        return "-i \"\(absoluteInputFile)\" -hide_banner -loglevel error -nostats \(outputOptions)-c:v \(outputCodec) -progress - -y \"\(absoluteTemporaryFile)\""
    }
}
