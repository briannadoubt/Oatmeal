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
    
    public init(value: CGFloat, total: CGFloat, lineWidth: CGFloat = 3) {
        self.value = value
        self.total = total
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: value)
                .stroke(Color.accentColor, lineWidth: lineWidth)
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(value: 0.5, total: 1)
    }
}
