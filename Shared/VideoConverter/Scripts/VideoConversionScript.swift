//
//  VideoConversionScript.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import Foundation

public struct VideoConversionScript {
    
    public var inputFile: URL
    public var codec: VideoCodec
    
    public var outputCodec: String { codec.rawValue }
    public var inputExtension: String { inputFile.pathExtension }
    public var outputExtension: String { codec.fileExtension.rawValue }
    public var outputOptions: String { codec.customOptions }
    public var outputFile: URL {
        inputFile.deletingPathExtension().appendingPathExtension(outputExtension)
    }
    
    public var absoluteInputFile: String {
        (inputFile.absoluteString.removingPercentEncoding ?? "")
    }
    
    public var absoluteOutputFile: String {
        (outputFile.absoluteString.removingPercentEncoding ?? "")
    }
    
    public func command() throws -> String {
        return "-i \"\(absoluteInputFile)\" -hide_banner -loglevel error -nostats \(outputOptions)-c:v \(outputCodec) -progress - -y \"\(absoluteOutputFile)\""
    }
}
