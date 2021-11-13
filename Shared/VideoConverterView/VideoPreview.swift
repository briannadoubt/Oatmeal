//
//  VideoPreview.swift
//  Oatmeal
//
//  Created by Bri on 11/6/21.
//

import SwiftUI
import AVKit
import FilesUI

public struct VideoPreview: View {
    
    public var inputFile: URL
    public var aspectRatio: CGFloat
    @State public var showCloseButton = false
    public var closeButtonPressed: () -> ()
    public var showVideoPlayer: () -> Bool
    
    public var body: some View {
        let closeButton = VStack {
            HStack {
                Button(action: closeButtonPressed) {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 44, height: 44)
                
                Spacer()
            }
            Spacer()
        }
        
        if showVideoPlayer() {
            ZStack {
                VideoPlayer(player: AVPlayer(url: inputFile))
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .frame(maxHeight: 320)
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange, lineWidth: 3)
                    }
                    .padding()
                    .overlay(showCloseButton ? AnyView(closeButton) : AnyView(EmptyView()))
            }
        } else {
            HStack {
                Spacer()
                ZStack {
                    Thumbnail(url: inputFile)
                        .frame(maxHeight: 150)
                        .cornerRadius(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.orange, lineWidth: 3)
                        }
                        .overlay(showCloseButton ? AnyView(closeButton.offset(x: -22, y: -22)) : AnyView(EmptyView()))
                }
                Spacer()
            }
        }
    }
}

struct VideoPreview_Previews: PreviewProvider {
    static var previews: some View {
        VideoPreview(inputFile: URL(fileURLWithPath: "~/Downloads/egg.png"), aspectRatio: 1, closeButtonPressed: { }, showVideoPlayer: { false })
    }
}
