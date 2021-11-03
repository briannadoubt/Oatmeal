//
//  VideoConversionSessionView.swift
//  Oatmeal
//
//  Created by Bri on 11/3/21.
//

import SwiftUI

public struct VideoConversionSessionView: View {
    
    @ObservedObject public var session: VideoConversionSession
    public var stop: (_ session: VideoConversionSession) -> ()
    
    public init(session: VideoConversionSession, stop: @escaping (_ session: VideoConversionSession) -> ()) {
        self.session = session
        self.stop = stop
    }
    
    @State private var finished = false
    @State private var showShareSheet = false
    
    public var body: some View {
        VStack {
            HStack {
                if !finished {
                    Text("Converting " + (session.probe.title ?? session.probe.filename ?? "Video") + "...")
                } else {
                    Text((session.probe.title ?? session.probe.filename ?? "Video")) + Text("(Complete)")
                }
                Spacer()
                
                if finished {
                    Button(action: { showShareSheet.toggle() }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .shareSheet(items: [URL(fileURLWithPath: "shareddocuments" + session.script.absoluteOutputFile.dropFirst(4))], isPresented: $showShareSheet)
                }
            }
            if !finished {
                HStack {
                    ProgressView(value: session.progress, total: 1)
                    Button { stop(session) } label: { Image(systemName: "xmark") }
                }
                
                if session.progress < 0.01 {
                    Text("Starting...")
                } else {
                    Text(String(format: "%.2f", session.progress * 100) + "%")
                }
            }
        }
        .padding()
        .onChange(of: session.progress, perform: { newValue in
            if newValue == 1.0 {
                withAnimation {
                    finished = true
                }
            }
        })
        .onDrag {
            NSItemProvider(contentsOf: session.script.outputFile) ?? NSItemProvider()
        }
    }
}

struct VideoConversionSessionView_Previews: PreviewProvider {
    static var previews: some View {
        VideoConversionSessionView(session: try! VideoConversionSession(script: VideoConversionScript(inputFile: URL(string: "")!, codec: VideoCodec.h264_x264)), stop: { $0.cancel() })
    }
}
