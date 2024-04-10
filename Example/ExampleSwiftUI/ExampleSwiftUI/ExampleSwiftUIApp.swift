//
//  ExampleSwiftUIApp.swift
//  ExampleSwiftUI
//
//  Created by Juraldinio on 10.04.2024.
//

import SwiftUI
import Zealot

@main
struct ExampleSwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let zealot = Zealot(endpoint: "https://...", channelKey: "...")
        zealot.checkVersion()
        
        return true
    }
}
