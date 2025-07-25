//
//  TodoListApp.swift
//  TodoList
//
//  Created by Deepinder on 7/25/25.
//

// File: TodoListApp.swift
import SwiftUI
import UserNotifications

@main
struct TodoListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TodoViewModel())
        }
    }
}

// AppDelegate to request notification permissions
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if !granted {
                print("Notifications permission not granted")
            }
        }
        return true
    }
}
