//
//  VideoConversionPicker.swift
//  Oatmeal
//
//  Created by Bri on 11/2/21.
//

import SwiftUI
import UniformTypeIdentifiers
import FilesUI

public struct VideoConversionPicker: View {
    
    @ObservedObject public var converter: VideoConverter
    
    @State private var inputFile: URL?
    @State private var outputDirectory: URL = FileManager.default
        .url(forUbiquityContainerIdentifier: nil)?
        .appendingPathComponent("Oatmeal", isDirectory: true)
        ?? (
            try? FileManager.default
                .url(
                    for: .downloadsDirectory,
                    in: .allDomainsMask,
                    appropriateFor: nil,
                    create: true
                )
        )
        ?? FileManager.default.appDirectory
        
    @AppStorage("outputDirectory") private var outputData: Data = Data()
    
    @State public var probe: VideoProbe?
    
    @State private var videoExtension: VideoExtension = .mp4
    @State private var videoCodec: VideoCodec = .h264_x264
    
    var types: [UTType] = [.appleProtectedMPEG4Video, .avi, .mpeg, .mpeg2TransportStream, .mpeg2Video, .mpeg4Movie, .quickTimeMovie, .video, UTType(filenameExtension: "webm")!, UTType(filenameExtension: "mov")!, UTType(filenameExtension: "mkv")!]
    
    private func probeVideo(_ newInputFile: URL) {
        do {
            probe = try VideoProbe(newInputFile)
        } catch let error as VideoConverterError {
            fatalError(error.localizedDescription)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func newInputFile(_ newInputFile: URL) {
        inputFile = newInputFile
        probeVideo(newInputFile)
    }
    
    @State private var showingOverwriteAlert = false
    
    public var body: some View {
        VStack {
            if converter.totalProgress > 0 {
                ProgressView(value: converter.totalProgress, total: 1)
            }
            VStack {
                if inputFile == nil {
                    FilePicker(types, inputFile: newInputFile)
                        .aspectRatio(1, contentMode: .fit)
                }
                
                if let inputFile = inputFile {
                    if let probe = probe {
                        HStack {
                            Spacer()
                            VideoPreview(inputFile: inputFile, aspectRatio: probe.aspectRatio ?? 1, showCloseButton: true) {
                                withAnimation {
                                    self.inputFile = nil
                                }
                            } showVideoPlayer: {
                                VideoExtension.allCases.filter({ $0 != .webm }).contains(probe.fileExtension)
                            }
                            Spacer()
                        }
                        
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
                    
                    HStack(spacing: 0) {
                        DirectoryPicker(directory: $outputDirectory)
                    
                        if let outputDirectory = outputDirectory {
                            Button {
                                do {
                                    try converter.convert(
                                        inputFile: inputFile,
                                        to: videoCodec,
                                        outputDirectory: outputDirectory,
                                        probe: probe
                                    )
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
                                    Spacer()
                                }
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(minWidth: 150)
                            .padding()
                        }
                    }
                }
            }
            #if os(macOS)
            .padding()
            #endif
        }
    }
}

struct VideoConversionPicker_Previews: PreviewProvider {
    static var previews: some View {
        VideoConversionPicker(converter: VideoConverter())
    }
}
