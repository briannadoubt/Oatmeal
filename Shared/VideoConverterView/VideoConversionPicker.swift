//
//  VideoConversionPicker.swift
//  Oatmeal
//
//  Created by Bri on 11/2/21.
//

import SwiftUI
import FilesUI
import UniformTypeIdentifiers
import AVKit

public struct VideoConversionPicker: View {
    
    @ObservedObject public var converter: VideoConverter
    
    @State private var inputFile: URL?
    
    @State public var probe: VideoProbe?
    
    @State private var videoExtension: VideoExtension = .mp4
    @State private var videoCodec: VideoCodec = .h264_x264
    
    var types: [UTType] = [.appleProtectedMPEG4Video, .avi, .mpeg, .mpeg2TransportStream, .mpeg2Video, .mpeg4Movie, .quickTimeMovie, .video, UTType(filenameExtension: "webm")!, UTType(filenameExtension: "mkv")!]
    
    private func newInputFile(_ newInputFile: URL) {
        inputFile = newInputFile
        do {
            probe = try VideoProbe(newInputFile)
        } catch let error as VideoConverterError {
            fatalError(error.localizedDescription)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public var body: some View {
        VStack {
            if inputFile == nil {
                FileImporterButton(types, url: newInputFile)
                    .buttonStyle(PlainButtonStyle())
            }
            
            if let inputFile = inputFile {
                if let probe = probe {
                    let closeButton = VStack {
                        HStack {
                            Button {
                                withAnimation {
                                    self.inputFile = nil
                                }
                            }
                            label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 44, height: 44)
                            
                            Spacer()
                        }
                        Spacer()
                    }
                    if let size = probe.size, probe.fileExtension != .webm {
                        ZStack {
                            VideoPlayer(player: AVPlayer(url: inputFile))
                                .aspectRatio(size.width / size.height, contentMode: .fit)
                                .frame(maxHeight: 320)
                                .cornerRadius(10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange, lineWidth: 3)
                                }
                                .padding()
                                .overlay(closeButton)
                        }
                    } else {
                        HStack {
                            Spacer()
                            ZStack {
                                FileThumbnail(url: $inputFile)
                                    .frame(maxHeight: 150)
                                    .cornerRadius(10)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.orange, lineWidth: 3)
                                    }
                                    .overlay(closeButton.offset(x: -22, y: -22))
                            }
                            Spacer()
                        }
                    }
                }
                
                if let probe = probe {
                    Text(probe.title ?? probe.filename ?? "--").font(.headline).padding()
                }
            
                VStack {
                    HStack {
                        Text("Export as").font(.headline)
                        Menu {
                            ForEach(VideoExtension.allCases) { vidExtension in
                                Button { withAnimation { videoExtension = vidExtension } } label: {
                                    Text(vidExtension.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                }
                            }
                        } label: {
                            Text(videoExtension.rawValue)
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        .onChange(of: videoCodec) { newCodec in
                            withAnimation {
                                videoExtension = newCodec.fileExtension
                            }
                        }
                    }
                    
                    HStack {
                        Text("with codec: ").font(.headline)
                        Menu {
                            ForEach(videoExtension.codecs) { codec in
                                Button { withAnimation { videoCodec = codec } } label: {
                                    Text(codec.label)
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                }
                            }
                        } label: {
                            Text(videoCodec.label)
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        .onChange(of: videoExtension) { newExtension in
                            withAnimation {
                                if let newCodec = newExtension.codecs.first {
                                    videoCodec = newCodec
                                }
                            }
                        }
                    }
                }
                .padding()
                
                Button {
                    do {
                        let script = VideoConversionScript(inputFile: inputFile, codec: videoCodec)
                        converter.sessions.append(try VideoConversionSession(script: script, probe: probe) )
                        self.inputFile = nil
                    } catch let error as VideoConverterError {
                        fatalError(error.localizedDescription)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Go!").font(.headline)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .background(Color.orange)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
        }
        #if os(macOS)
        .padding()
        #endif
    }
}

struct VideoConversionPicker_Previews: PreviewProvider {
    static var previews: some View {
        VideoConversionPicker(converter: VideoConverter())
    }
}
