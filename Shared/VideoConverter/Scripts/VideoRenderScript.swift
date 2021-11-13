//
//  VideoRenderScript.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import Foundation

public struct VideoRenderScript: VideoScript {
    
    public var inputFile: URL
    public var overlay: URL?
    public var codec: VideoCodec
    public var fps: Int
    
    public var command: String {
        """
            -i \(inputFile.path) \
            \(overlay != nil ? "-i \(overlay!.path) " : "")\
            \(codec.customOptions) \
            -c:v \(codec.rawValue) \
            -r \(fps) \
            -c:a copy \
            \(overlay != nil ? "-filter_complex \"[0:v][1:v] overlay=W-w-20:H-h-20:enable='between(t,0,4)'\" " : "")\
            \(inputFile.path.replacingOccurrences(of: inputFile.pathExtension, with: codec.fileExtension.rawValue))
        """
    }
}
