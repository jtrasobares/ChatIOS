//
//  TSADMChatApp.swift
//  TSADMChat
//
//  Created by Gabriel Marro on 20/11/23.
//

import SwiftUI
import SwiftData

/**
 # TSADMChatApp #
 The main app.
 */
@main
struct TSADMChatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Message.self,User.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ViewCoordinator()
        }.modelContainer(sharedModelContainer)
    }
}
