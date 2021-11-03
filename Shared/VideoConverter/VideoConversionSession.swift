//
//  VideoConversionSession.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import ffmpegkit
import CoreGraphics
import SwiftUI

public class VideoConversionSession: ObservableObject, Identifiable {
    
    @Published public var script: VideoConversionScript
    
    @Published public var probe: VideoProbe
    
    @Published public var convertedFrames: Double?
    
    @Published public var statistics: Statistics?
    @Published public var session: Session?
    @Published public var logs: [Log?] = []
    
    public var id: String = Date().ISO8601Format()
    
    public var progress: Double = 0
    
    public init(script: VideoConversionScript, probe: VideoProbe? = nil) throws {
        self.script = script
        self.probe = try probe ?? VideoProbe(script.inputFile)
        try convert(script)
    }
    
    public func convert(_ script: VideoConversionScript) throws {
        guard script.inputFile.startAccessingSecurityScopedResource() else {
            throw VideoConverterError.filePermissionNotAllowed(script.inputFile)
        }
        guard script.outputFile.startAccessingSecurityScopedResource() else {
            throw VideoConverterError.filePermissionNotAllowed(script.outputFile)
        }
        self.session = FFmpegKit.executeAsync(
            try script.command(),
            withExecuteCallback: { session in },
            withLogCallback: { log in },
            withStatisticsCallback: { statistics in
                DispatchQueue.main.async {
                    withAnimation {
                        self.probe.fileSize = statistics?.getSize()
                        self.probe.bitrate = statistics?.getBitrate()
                        if let frame = statistics?.getVideoFrameNumber() {
                            self.convertedFrames = Double(frame)
                            self.progress = Double(frame) / (self.probe.totalPackets ?? 1)
                            print(self.progress)
                        }
                    }
                }
            },
            onDispatchQueue: DispatchQueue.global(qos: .utility)
        )
    }
    
    public func cancel() {
        if let session = session {
            session.cancel()
        }
    }
}
