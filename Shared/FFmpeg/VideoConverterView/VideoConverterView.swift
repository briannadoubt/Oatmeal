//
//  VideoConverterView.swift
//  Free Video Converter
//
//  Created by Bri on 10/31/21.
//

import SwiftUI

#if os(macOS)
func showInFinder(url: URL?) {
    guard let url = url else { return }
    
    if url.hasDirectoryPath {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }
    else {
        showInFinderAndSelectLastComponent(of: url)
    }
}

fileprivate func showInFinderAndSelectLastComponent(of url: URL) {
    NSWorkspace.shared.activateFileViewerSelecting([url])
}
#endif

public struct VideoConverterView: View {
    
    @StateObject private var converter = VideoConverter()
    
    public var body: some View {
        let vstack = LazyVStack(pinnedViews: [.sectionHeaders]) {
            Section(header: VideoConversionPicker(converter: converter).background(.ultraThinMaterial)) {
                ForEach(converter.sessions) { session in
                    VideoConversionView(inputFile: session.script.inputFile, stop: converter.stop)
                        .environmentObject(session)
                    Divider()
                }
            }
        }
        .environmentObject(converter)
        .navigationTitle(Text("Oatmeal"))
        
        let scrollView = ScrollView {
            vstack
        }
        
        #if os(iOS)
        NavigationView {
            scrollView
        }
        #elseif os(macOS)
        vstack.frame(minWidth: 364)
        #endif
    }
}

struct VideoConverterView_Previews: PreviewProvider {
    static var previews: some View {
        VideoConverterView()
    }
}
