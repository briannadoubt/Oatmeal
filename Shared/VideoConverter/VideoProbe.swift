//
//  VideoProber.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import ffmpegkit
import CoreGraphics

public class VideoProbe: ObservableObject {
    
    public var file: URL
    @Published public var fileExtension: VideoExtension
    
    public var id: String = Date().ISO8601Format()
    
    @Published public var title: String?
    @Published public var filename: String?
    
    @Published public var codec: VideoCodec?
    @Published public var totalDuration: Double?
    @Published public var totalPackets: Double?
    
    @Published public var fileSize: Int?
    @Published public var bitrate: Double?
    
    @Published public var properties: [AnyHashable: Any] = [:]
    @Published public var size: CGSize?
    @Published public var aspectRatio: CGFloat?
    
    public init(_ file: URL) throws {
        self.file = file
        
        guard let videoExtension = VideoExtension(rawValue: file.pathExtension) else {
            throw VideoConverterError.fileExtensionNotSupported(file.pathExtension)
        }
        
        self.fileExtension = videoExtension
        
        try execute()
    }
    
    public func execute() throws {
        guard file.startAccessingSecurityScopedResource() else {
            throw VideoConverterError.filePermissionNotAllowed(file)
        }
        
        let mediaInformationScript = VideoProbeScript(file)
        getMediaInformation(mediaInformationScript)
        
        let packetCountScript = VideoProbePacketCountScript(file)
        try getPacketCount(packetCountScript)
        
        file.stopAccessingSecurityScopedResource()
    }
    
    func getMediaInformation(_ script: VideoProbeScript) {
        let mediaInformationSession = FFprobeKit.getMediaInformation(fromCommand: script.command)
        
        let mediaInformation = mediaInformationSession?.getMediaInformation()
        
        if let tags = mediaInformation?.getTags() {
            if let title = tags["title"] as? String {
                self.title = title
            } else if let title = tags["com.apple.quicktime.title"] as? String {
                self.title = title
            }
        }
        
        if let duration = mediaInformation?.getDuration() {
            self.totalDuration = Double(duration)
        }
        
        if let size = mediaInformation?.getSize() {
            self.fileSize = Int(size)
        }
        
        if let bitrate = mediaInformation?.getBitrate() {
            self.bitrate = Double(bitrate)
        }
        
        if let properties = mediaInformation?.getAllProperties() {
            
            self.properties = properties
            
            print(properties)
            
            if let streams = properties["streams"] as? [[AnyHashable: Any]] {
                for stream in streams {
                    if let type = stream["codec_type"] as? String {
                        if type == "video" {
                            guard let height = stream["height"] as? CGFloat else {
                                continue
                            }
                            guard let width = stream["width"] as? CGFloat else {
                                continue
                            }
                            self.size = CGSize(width: width, height: height)
                            self.aspectRatio = CGFloat(width / height)
                        }
                    }
                }
            }
        }
    }
    
    func getPacketCount(_ script: VideoProbePacketCountScript) throws {
        let packetCountMediaInformationSession = FFprobeKit.getMediaInformation(fromCommand: script.command)
        let output = packetCountMediaInformationSession?.getOutput() ?? "Nope"
        guard let data = output.data(using: .utf8) else {
            throw VideoConverterError.failedToEncodeStringToData(output, script)
        }
        guard let probeMap = try JSONSerialization.jsonObject(with: data, options: .json5Allowed) as? [String: Any] else {
            throw VideoConverterError.failedToParseProbeOutput(output, script)
        }
        guard let streams = probeMap["streams"] as? [Any] else {
            throw VideoConverterError.noKeyFound("streams", script)
        }
        guard let stream = streams[0] as? [String: Any] else {
            throw VideoConverterError.noKeyFound("streams[0]", script)
        }
        for i in stream { // Why this is an array, I do not know...
            if i.key == "nb_read_packets" {
                if let string = i.value as? String, let value = Double(string) {
                    self.totalPackets = value
                }
                break
            }
        }
    }
}
