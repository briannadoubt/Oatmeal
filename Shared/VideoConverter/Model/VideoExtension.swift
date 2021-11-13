//
//  VideoExtension.swift
//  Oatmeal
//
//  Created by Bri on 10/31/21.
//

import Foundation

public enum VideoExtension: String, Identifiable, CaseIterable {
    
    case webm = "webm"
    case mp4 = "mp4"
    case mov = "mov"
    case mkv = "mkv"
    case ogv = "ogv"
    
    public var id: String { rawValue }
    
    public var codecs: [VideoCodec] {
        switch self {
        case .webm:
            return [.vp8, .vp9]
        case .mp4:
            return [.h264_x264, .h264_openh264, .h264_videotoolbox, .x265, .xvid, .kvazaar]
        case .mov:
            return [.hap]
        case .mkv:
            return [.aom]
        case .ogv:
            return [.theora]
        }
    }
}
