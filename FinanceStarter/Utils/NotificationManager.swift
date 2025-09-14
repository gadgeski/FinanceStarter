//
//  NotificationManager.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Utils/NotificationManager.swift  // <-- [ADDED]
import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func schedulePriceAlert(base: String, symbol: String, current: Double, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "価格アラート \(base)→\(symbol)"
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }
}
