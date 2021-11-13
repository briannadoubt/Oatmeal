//
//  OatmealApp.swift
//  Shared
//
//  Created by Bri on 10/31/21.
//

import SwiftUI
import SpriteKit

@main
struct OatmealApp: App {
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
//            EnvironmentView()
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
