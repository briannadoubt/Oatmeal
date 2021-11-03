//
//  VideoCodec.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import Foundation

public enum VideoCodec: String, Identifiable, CaseIterable {
    
    case h264_x264 = "libx264"
    case h264_openh264 = "libopenh264"
    case h264_videotoolbox
    case x265 = "libx265"
    case xvid = "libxvid"
    case vp8 = "libvpx"
    case vp9 = "libvpx-vp9"
    case aom = "libaom-av1"
    case kvazaar = "libkvazaar"
    case theora = "libtheora"
    case hap
    
    public var id: String { rawValue }
    
    public var label: String {
        switch self {
        case .h264_x264:
            return "h264 (x264)"
        case .h264_openh264:
            return "h264 (open264)"
        case .h264_videotoolbox:
            return "h264 (videotoolbox)"
        case .x265:
            return "x265"
        case .xvid:
            return "xvid"
        case .vp8:
            return "vp8"
        case .vp9:
            return "vp9"
        case .aom:
            return "aom"
        case .kvazaar:
            return "kvazaar"
        case .theora:
            return "theora"
        case .hap:
            return "hap"
        }
    }
    
    public var fileExtension: VideoExtension {
        switch self {
        case .vp8, .vp9:
            return .webm
        case .aom:
            return .mkv
        case .theora:
            return .ogv
        case .hap:
            return .mov
        default:
            return .mp4
        }
    }
    
    public var customOptions: String {
        switch self {
        case .x265:
            return "-crf 28 -preset fast "
        case .vp8:
            return "-b:v 1M -crf 10 "
        case .vp9:
            return "-b:v 2M "
        case .aom:
            return "-crf 30 -strict experimental "
        case .theora:
            return "-qscale:v 7 "
        case .hap:
            return "-format hap_q "
        default:
            return ""
        }
    }
}
