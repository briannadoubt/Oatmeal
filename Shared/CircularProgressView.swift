//
//  CircularProgressView.swift
//  
//
//  Created by Bri on 11/11/21.
//

import SwiftUI

public struct CircularProgressView: View {
    
    private var value: CGFloat
    private var total: CGFloat
    
    private var lineWidth: CGFloat
    
    var cancel: () -> ()
    
    public init(value: CGFloat, total: CGFloat, lineWidth: CGFloat = 3, cancel: @escaping () -> ()) {
        self.value = value
        self.total = total
        self.lineWidth = lineWidth
        self.cancel = cancel
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: value / total)
                .stroke(Color.accentColor, lineWidth: lineWidth)
                .aspectRatio(1, contentMode: .fit)
                .rotationEffect(Angle(degrees: -90))
            Button(action: cancel) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(value: 50, total: 100, cancel: { print("Meow") })
            .frame(width: 64, height: 64)
    }
}
