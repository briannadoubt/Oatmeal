//
//  Dinos.swift
//  Oatmeal
//
//  Created by Bri on 11/11/21.
//

import SwiftUI

enum Dino: String, Codable, Identifiable {
    
    case oatmeal
    case kiwi
    
    var id: String { rawValue }
    
    var story: String {
        switch self {
        case .oatmeal:
            return ""
        case .kiwi:
            return ""
        }
    }
    
    var image: Image { Image(rawValue) }
}

struct Dialogue: Codable {
    var dino: Dino
    
    
}
