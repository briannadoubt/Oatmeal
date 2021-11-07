//
//  VideoConversionSessionView.swift
//  Oatmeal
//
//  Created by Bri on 11/3/21.
//

import SwiftUI
import FilesUI

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = style
    return formatter.string(from: self) ?? ""
  }
}

public struct VideoConversionView: View {
    
    public init(inputFile: URL, stop: @escaping (_ session: VideoConversionSession) -> ()) {
        self._inputFile = State(wrappedValue: inputFile)
        self.stop = stop
    }
    
    @EnvironmentObject private var session: VideoConversionSession
    
    @State private var inputFile: URL
    
    private var stop: (_ session: VideoConversionSession) -> ()
    
    public var body: some View {
        HStack {
            Thumbnail(url: inputFile)
                .frame(height: 88)
                .onDrag {
                    NSItemProvider(contentsOf: session.script.outputFile) ?? NSItemProvider()
                }
            VideoConversionSessionView(inputFile: inputFile, stop: stop)
        }
        .padding(.horizontal)
    }
}

public struct VideoConversionSessionView: View {
    
    public init(inputFile: URL, stop: @escaping (_ session: VideoConversionSession) -> ()) {
        self._inputFile = State(wrappedValue: inputFile)
        self.stop = stop
    }
    
    @EnvironmentObject private var session: VideoConversionSession
    
    @State private var inputFile: URL
    @State private var showShareSheet = false
    
    private var stop: (_ session: VideoConversionSession) -> ()
    
    private var formatter: DateComponentsFormatter {
        let format = DateComponentsFormatter()
        format.unitsStyle = .short
        format.allowedUnits = [.hour, .minute, .second]
        format.unitsStyle = .positional
        return format
    }
    
    private var progressText: String {
        if session.progress >= 0.01 && session.probe.totalFrames != nil {
            return "(" + String(format: "%.2f", session.progress) + "%)"
        } else {
            return ""
        }
    }
    
    public var body: some View {
        let finishedView = HStack {
            Text((session.probe.title ?? session.probe.filename ?? "Video")) + Text("(Complete)")
            Spacer()
            #if os(iOS)
            Button(action: { showShareSheet.toggle() }) {
                Image(systemName: "square.and.arrow.up")
            }
            .shareSheet(items: [URL(fileURLWithPath: "shareddocuments" + session.script.absoluteOutputFile.dropFirst(4))], isPresented: $showShareSheet)
            #endif
        }
        
        let notFinishedView = Group {
            HStack {
                if session.progress == session.convertedTime {
                    if let time = session.convertedTime {
                        Text("We've converted " + time.asString(style: .abbreviated) + " so far!")
                    }
                    if session.progress >= 0.01, session.probe.totalFrames != nil {
                        Text("(" + String(format: "%.2f", session.progress) + "%)")
                    }
                } else if session.progress < 0.01 {
                    Text("Starting...")
                } else {
                    if let totalDuration = session.probe.totalDuration, let convertedTime = session.convertedTime {
                        ProgressView(value: convertedTime, total: totalDuration)
                    }
                }
                Spacer()
                Button { stop(session) } label: { Image(systemName: "xmark") }
            }
            
            if let time = session.convertedTime, time != session.progress {
                HStack {
                    Text(
                        "We've converted "
                        + time.asString(style: .abbreviated)
                        + progressText
                        + " so far!"
                    )
                    Spacer()
                }
            }
        }
        
        VStack {
            if session.finished {
                finishedView
            } else {
                notFinishedView
            }
        }
    }
}

struct VideoConversionSessionView_Previews: PreviewProvider {
    static var previews: some View {
        VideoConversionSessionView(inputFile: URL(string: "")!, stop: { $0.cancel() })
            .environmentObject(try! VideoConversionSession(
                script: VideoConversionScript(
                    inputFile: URL(string: "")!,
                    outputDirectory: URL(string: "")!,
                    codec: VideoCodec.h264_x264
                )
            ))
    }
}
