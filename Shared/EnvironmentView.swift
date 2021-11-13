//
//  EnvironmentView.swift
//  Oatmeal
//
//  Created by Bri on 11/11/21.
//

import SwiftUI
import SceneKit

struct EnvironmentView: View {
    
    var scene: SCNScene? {
        let scene = SCNScene(named: "Environment Scene.scn")
        return scene
    }
    
    var camera: SCNNode? {
        scene?.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    var body: some View {
        SceneView(
            scene: scene,
            pointOfView: camera,
            options: [.allowsCameraControl]
        )
        .background(Color("BackgroundColor"))
        .edgesIgnoringSafeArea(.all)
    }
}

struct EnvironmentView_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentView()
    }
}
