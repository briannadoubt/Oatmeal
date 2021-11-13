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
    
    /// When a session is initialized it creates a FFprobe that attempts to get the total duration of the input video file. The calculation of  progress of the session relies on this total duration for the given video file. If FFprobe fails to retrieve a total duration field then it is not included in the calculation of the total progress.
    public var totalProgress: Double {
        let sessionsConvertingVideoFilesWithProbedTotalDuration = sessions.filter({ $0.probe.totalDuration != nil })
        return sessionsConvertingVideoFilesWithProbedTotalDuration.map({ $0.progress }).reduce(0, +) / Double(sessionsConvertingVideoFilesWithProbedTotalDuration.count)
    }
    
    public func stop(_ session: VideoConversionSession) {
        session.cancel()
        if let index = sessions.firstIndex(where: { session.script.inputFile == $0.script.inputFile }) {
            sessions.remove(at: index)
        }
    }
    
    public func convert(inputFile: URL, to videoCodec: VideoCodec, outputDirectory: URL, probe: VideoProbe? = nil) throws {
        let script = VideoConversionScript(inputFile: inputFile, outputDirectory: outputDirectory, codec: videoCodec)
        sessions.append(try VideoConversionSession(script: script, probe: probe) )
    }
}
