//
//  beta2App.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-23.
//

import SwiftUI
import Firebase




@main
struct beta2: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                
                RootView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}



