//
//  VideoConverter.swift
//  Free Video Converter
//
//  Created by Bri on 10/29/21.
//

import CoreGraphics
import ffmpegkit
import UniformTypeIdentifiers
import Combine

public class VideoConverter: ObservableObject {
    @Published public var sessions: [VideoConversionSession] = []
    
    public var totalProgress: Double {
        sessions.map({ $0.progress }).reduce(0, +) / Double(sessions.count)
    }
    
    public func stop(_ session: VideoConversionSession) {
        session.cancel()
        if let index = sessions.firstIndex(where: { session.script.inputFile == $0.script.inputFile }) {
            sessions.remove(at: index)
        }
    }
}
