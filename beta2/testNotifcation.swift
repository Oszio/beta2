//
//  testNotifcation.swift
//  beta2
//
//  Created by Oskar Almå on 2023-11-20.
//

import UserNotifications

func scheduleDailyNotification() {
    let content = UNMutableNotificationContent()
    content.title = "New Challenge"
    content.body = "Check out today's new challenge!"

    var dateComponents = DateComponents()
    dateComponents.hour = 12  // Set to your desired hour
    dateComponents.minute = 00 // Set to your desired minute

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    let request = UNNotificationRequest(identifier: "dailyChallengeNotification", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { (error) in
        if let error = error {
            print("Error scheduling notification: \(error)")
        } else {
            print("Notification scheduled successfully")
        }
    }

}

