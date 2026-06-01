//
//  zuhao002App.swift
//  zuhao002
//
//  Created by andy 正道 on 2026/5/20.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var securityManager = SecurityManager.shared
    
    var body: some View {
        Group {
            if securityManager.isPasswordEnabled && !securityManager.isUnlocked {
                LockScreenView()
            } else {
                ContentView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if securityManager.isPasswordEnabled {
                securityManager.isUnlocked = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            securityManager.checkAppLockState()
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: RootView())
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
}

