//
//  Persistence.swift
//  Shared
//
//  Created by Bri on 11/12/21.
//

import CoreData
import GBDeviceInfo
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let completedSession = CompletedVideoConversionSession(context: viewContext)
            
            completedSession.completed = Date()
            #if os(iOS)
            completedSession.device = UIDevice.current.name
            #elseif os(macOS)
            completedSession.device = Host.current().localizedName
            #endif
            
            completedSession.filename = "meow.mp4"
            
            #if os(iOS)
            completedSession.userInterfaceIdiom = GBDeviceInfo.deviceInfo().modelString
            #elseif os(macOS)
            completedSession.userInterfaceIdiom = GBDeviceInfo.deviceInfo().nodeName.replacingOccurrences(of: ".local", with: "")
            #endif
            
            completedSession.url = URL(fileURLWithPath: "~/Downloads/egg.png")
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Coredatathing")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
