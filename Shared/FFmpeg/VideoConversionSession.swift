//
//  VideoConversionSession.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import ffmpegkit
import CoreGraphics
import SwiftUI

public class VideoConversionSession: NSObject, ObservableObject, Identifiable {
    
    @AppStorage("overwriteDestinationByDefault") private var overwriteDestinationByDefault: Bool = false
    
    @Published public var script: VideoConversionScript
    
    @Published public var probe: VideoProbe
    
    @Published public var convertedFrames: Double?
    @Published public var convertedTime: Double?
    
    @Published public var statistics: Statistics?
    @Published public var ffSession: Session?
    @Published public var logs: [Log?] = []
    
    @Published public var finished = false
    
    public var id: String = Date().ISO8601Format()
    
    public var progress: Double = 0
    
    public init(script: VideoConversionScript, probe: VideoProbe? = nil) throws {
        self.script = script
        self.probe = try probe ?? VideoProbe(script.inputFile)
        
        super.init()
        
        try convert()
    }
    
    @AppStorage("outputDirectory") private var outputData: Data = Data()
    
    public func moveFile() {
        do {
            guard FileManager.default.isDeletableFile(atPath: script.outputFile.path) else {
                throw VideoConverterError.filePermissionNotAllowed(script.outputFile)
            }
            try FileManager.default.removeItem(at: script.outputFile)
            try FileManager.default.moveItem(at: self.script.temporaryFile, to: self.script.outputFile)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    private func didFinish() async {
        if overwriteDestinationByDefault {
            moveFile()
        }
        DispatchQueue.main.async {
            withAnimation {
                self.finished = true
            }
        }
    }
    
    public func convert() throws {
        guard script.inputFile.startAccessingSecurityScopedResource() else {
            throw VideoConverterError.filePermissionNotAllowed(script.inputFile)
        }
        
        self.ffSession = FFmpegKit.executeAsync(
            try script.command(),
            withExecuteCallback: { session in
                Task {
                    await self.didFinish()
                }
            },
            withLogCallback: { log in
                #if DEBUG
                print("LOG -", "SESSION:", log?.getSessionId() ?? "", "LEVEL:", log?.getLevel() ?? "", "- MESSAGE:", log?.getMessage() ?? "", "- END LOG")
                #endif
            },
            withStatisticsCallback: { statistics in
                
                DispatchQueue.main.async {
                    withAnimation {
                        self.probe.fileSize = statistics?.getSize()
                        self.probe.bitrate = statistics?.getBitrate()
                        if let microsecondsConverted = statistics?.getTime() {
                            let millisecondsConverted = Double(microsecondsConverted) / 1000
                            
                            self.convertedTime = millisecondsConverted
                            self.progress = millisecondsConverted / (self.probe.totalDuration ?? 1)
                        }
                        if let frame = statistics?.getVideoFrameNumber() {
                            self.convertedFrames = Double(frame)
                        }
                    }
                }
            },
            onDispatchQueue: DispatchQueue.global(qos: .utility)
        )
    }
    
    public func cancel() {
        if let session = ffSession {
            session.cancel()
        }
    }
}

extension VideoConversionSession: FileManagerDelegate {
    public func fileManager(_ fileManager: FileManager, shouldMoveItemAt srcURL: URL, to dstURL: URL) -> Bool {
        if fileManager.fileExists(atPath: dstURL.path) {
            return true
        } else {
            return true
        }
    }
}
