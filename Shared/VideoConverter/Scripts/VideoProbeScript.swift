//
//  VideoProbeScript.swift
//  Oatmeal
//
//  Created by Bri on 11/2/21.
//

import Foundation

public struct VideoProbeScript: VideoScript {
    
    public init(_ inputFile: URL) {
        self.inputFile = inputFile
    }
    
    public var inputFile: URL
    
    public var absoluteInputFile: String { inputFile.absoluteString.removingPercentEncoding ?? "" }
    public var command: String { "-v error -hide_banner -print_format json -show_format -show_streams -i \"\(absoluteInputFile)\"" }
}

public struct VideoProbePacketCountScript: VideoScript {
    
    public init(_ inputFile: URL) {
        self.inputFile = inputFile
    }
    
    public var inputFile: URL
    
    public var absoluteInputFile: String { inputFile.absoluteString.removingPercentEncoding ?? "" }
    public var command: String { "-v quiet -hide_banner -print_format json -select_streams v:0 -count_packets -show_entries stream=nb_read_packets \"\(absoluteInputFile)\"" }
}
