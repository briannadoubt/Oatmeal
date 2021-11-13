//
//  VideoConversionSession.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import ffmpegkit
import CoreGraphics
import SwiftUI

/// This class is designed to be observed on a `View` and provides an interface for monitoring the total progress of the conversion session (based on the total duration of the video input video).
///
/// Both a visual progress indicator and cancel button are provided on the `VideoConversionSessionView`, which can be displayed via the `VideoConversionView`.
///
/// See the documentation for `VideoConversionSession.progress` for more information on maually monitoring conversion progress.
public class VideoConversionSession: NSObject, ObservableObject, Identifiable {
    
    /// A `VideoConversionScript` object is a required object at initialization. This object contains and calculates all the necessary fields to start converting a video file. From those fields it then generates a script for the command-line interface of `ffmpeg`. The script you provide can be generated via custom user input or magically if you implement the  `VideoConversionPicker` view via the `VideoConverterView`.
    @Published public var script: VideoConversionScript
    
    /// An optional parameter. If this parameter is nil a new `VideoProbe` class will be created via using the inputFile from the `script` parameter. If this input parameter is manually provided it expects the probe to have accessed the same file it is expecting to convert. If the probe has accessed a different file it will throw a fatal error.
    @Published public var probe: VideoProbe
    
    /// The number of frames the current conversion session has successfully converted to the new file format.
    @Published public var convertedFrames: Double?
    
    /// The number of milliseconds (when played back at x1) that the current conversion session has successfully converted to the new file format.
    @Published public var convertedTime: Double?
    
    /// The `FFmpeg` conversion session instance.
    ///
    /// This is where the magic happens.
    private var ffSession: Session?
    
    /// A flag indicating whether or not this session is currently executing a video conversion.
    ///
    /// It is highly encouraged to observe this value from a `View` to change the state of the UI when the current session has finished converting.
    @Published public var finished = false
    
    /// Auto generated id based on the current date for conforming to `Identifiable`
    public let id: String = Date().ISO8601Format()
    
    /// The progress of the current session's conversion.
    ///
    /// This value is designed to be observed from a `View` to indicate to a user the state of the current conversion.
    ///
    /// When a session is initialized it creates a FFprobe that attempts to get the total duration of the input video file. The calculation of progress of the session relies on this total duration for the given video file. If FFprobe fails to retrieve a total duration field then it is not included in the calculation of this session's progress.
    ///
    /// - Initial Value: 0.0
    /// - Finished Value: 1.0
    public var progress: Double = 0
    
    /// Initialize a new `VideoConversionSession`.
    ///
    /// This class is designed to be observed on a `View` and provides an interface for monitoring the total progress of the conversion session (based on the total duration of the video input video). Both a visual progress indicator and cancel button are provided on the `VideoConversionSessionView`, which can be displayed via the `VideoConversionView`.
    ///
    /// See the documentation for `VideoConversionSession.progress` for more information on maually monitoring conversion progress.
    ///
    /// - Parameters:
    ///   - script: A `VideoConversionScript` object is required. This object contains and calculates all the necessary fields to start converting a video file. From those fields it then generates a script for the command-line interface of `ffmpeg`. The script you provide can be generated via custom user input or magically if you implement the  `VideoConversionPicker` view via the `VideoConverterView`.
    ///   - probe: An optional parameter. If this parameter is nil a new `VideoProbe` class will be created via using the inputFile from the `script` parameter. If this input parameter is manually provided it expects the probe to have accessed the same file it is expecting to convert. If the probe has accessed a different file it will throw a fatal error.
    public init(script: VideoConversionScript, probe: VideoProbe? = nil) throws {
        self.script = script
        self.probe = try probe ?? VideoProbe(script.inputFile)
        
        super.init()
        
        try convert()
    }
    
    public func moveFile() {
        do {
            if FileManager.default.fileExists(atPath: script.outputFile.path) {
                try FileManager.default.removeItem(at: script.outputFile)
            }
            var isDirectory = ObjCBool(true)
            if FileManager.default.fileExists(atPath: script.outputDirectory.path, isDirectory: &isDirectory) {
                try FileManager.default.createDirectory(at: script.outputDirectory, withIntermediateDirectories: true)
            }
            try FileManager.default.moveItem(at: script.temporaryFile, to: script.outputFile)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// At some point the  `VideoConverterView` will prompt the user if they want to always overwrite the destination file. If they do their preference will appear here.
    ///
    /// - Default Value: `false`
    ///
    /// Set this value to true via the `@AppStorage` interface if you want to overwrite files by default.
    @AppStorage("overwriteDestinationByDefault") private var overwriteDestinationByDefault: Bool = false
    
    /// The directory (usually chosen by the user) that is encoded with a permission safe url.
    @AppStorage("outputDirectory") private var outputData: Data = Data()
    
    /// This is called when `VideoConversionSession.convert()` completes.
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
            withLogCallback: { _ in },
            withStatisticsCallback: { statistics in
                DispatchQueue.main.async {
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
