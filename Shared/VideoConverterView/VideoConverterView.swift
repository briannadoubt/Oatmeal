//
//  VideoConverterView.swift
//  Free Video Converter
//
//  Created by Bri on 10/31/21.
//

import SwiftUI

public struct VideoConverterView: View {
    
    @StateObject private var converter = VideoConverter()
    
    public var body: some View {
        let scrollView = ScrollView {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                
                HStack {
                    
                }
                
                Section(header: VideoConversionPicker(converter: converter).background(.bar)) {
                    if converter.totalProgress > 0 {
                        ProgressView(value: converter.totalProgress, total: 1)
                    }
                    ForEach(converter.sessions) { session in
                        VideoConversionSessionView(session: session, stop: converter.stop)
                        Divider()
                    }
                }
            }
        }
        .navigationTitle(Text("Oatmeal"))
        .background(Color("BackgroundColor"))
        
        #if os(iOS)
        NavigationView {
            scrollView
        }
        #elseif os(macOS)
        scrollView
        #endif
    }
}

struct VideoConverterView_Previews: PreviewProvider {
    static var previews: some View {
        VideoConverterView()
    }
}