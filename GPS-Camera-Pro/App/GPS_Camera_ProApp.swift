//
//  GPS_Camera_ProApp.swift
//  GPS-Camera-Pro
//
//  Created by User on 25/03/26.
//

import SwiftUI
import SwiftData

@main
struct GPS_Camera_ProApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .modelContainer(for: StoredPhoto.self)
        }.onChange(of: scenePhase) { _,  newPhase in
            switch newPhase {
            case .active :
                /// App is in the foreground and interactive
                /// Perform setup or start tasks
                print("App is active")
            case .inactive :
                /// App is in the foreground but not receiving events (e.g., a phone call)
                /// Pause ongoing tasks
                print("Intruption occured")
            case .background :
                /// App is no longer visible
                /// Save data, stop timers, or free up resources
                print("App is in background")
            
           @unknown default:
                break
            }
        }
        
    }
}
