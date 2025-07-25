//
//  NotificationManager.swift
//  TodoList
//
//  Created by Deepinder on 7/25/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func scheduleReminder(for item: TodoItem) {
        guard let due = item.dueDate else { return }
        let content = UNMutableNotificationContent()
        content.title = "To-Do Reminder"
        content.body = item.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: due.addingTimeInterval(-300))
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let err = error {
                print("Notification scheduling error: \(err)")
            }
        }
    }

    func cancelReminder(for item: TodoItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
    }
}
