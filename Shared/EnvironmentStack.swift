//
//  EnvironmentStack.swift
//  Oatmeal
//
//  Created by Bri on 11/11/21.
//

import SwiftUI

struct EnvironmentStack: View {
    
    @EnvironmentObject private var converter: VideoConverter
    
    var columns: [GridItem] {
        let flexible = GridItem(.flexible(minimum: 320, maximum: 480))
        let adaptive = GridItem(.adaptive(minimum: 160, maximum: 320))
        
        return [flexible, adaptive]
        
//        switch UIDevice.current.userInterfaceIdiom {
//        case .carPlay:
//
//        case .mac:
//
//        case .pad:
//
//        case .phone:
//
//        case .tv:
//
//        case .unspecified:
//
//        @unknown default:
//            return []
//        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, pinnedViews: .sectionHeaders) {
            ForEach(converter.sessions) { session in
                
            }
        }
    }
}

struct EnvironmentStack_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentStack()
    }
}
