//
//  ContentView.swift
//  Shared
//
//  Created by Bri on 10/31/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var converter = VideoConverter()
    
    init() {
        #if os(iOS)
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithTransparentBackground()
        
        let largeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dinokids", size: 38)!,
            .foregroundColor: UIColor.white
        ]
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dinokids", size: 32)!,
            .foregroundColor: UIColor.white
        ]
        
        appearance.largeTitleTextAttributes = largeAttributes
        appearance.titleTextAttributes = attributes
        
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor(.accentColor).withAlphaComponent(0.8)
        
        UINavigationBar.appearance().largeTitleTextAttributes = largeAttributes
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        UINavigationBar.appearance().tintColor = .white
        #endif
    }
    
    var body: some View {
        VideoConverterView(converter: converter)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
