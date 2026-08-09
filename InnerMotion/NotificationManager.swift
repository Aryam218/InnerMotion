//
//  NotificationManager.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 27/02/1448 AH.
//

import Foundation
import UserNotifications
import UIKit

final class NotificationManager {

    static let shared = NotificationManager()

    private init() {}

    private let center =
        UNUserNotificationCenter.current()

    // IDs ثابتة عشان نقدر نحدث أو نلغي نفس الإشعارات
    private let encouragementID =
        "innerMotion.daily.encouragement"

    private let taskReminderID =
        "innerMotion.daily.taskReminder"


    // MARK: - Get Current Permission

    func authorizationStatus() async -> UNAuthorizationStatus {

        let settings =
            await center.notificationSettings()

        return settings.authorizationStatus
    }


    // MARK: - Enable Notifications

    func enableNotifications(
        hasIncompleteTasks: Bool
    ) async throws -> Bool {

        let status =
            await authorizationStatus()

        switch status {

        case .notDetermined:

            let granted =
                try await center.requestAuthorization(
                    options: [
                        .alert,
                        .sound,
                        .badge
                    ]
                )

            guard granted else {
                return false
            }

            try await scheduleDailyNotifications(
                hasIncompleteTasks:
                    hasIncompleteTasks
            )

            return true


        case .authorized,
             .provisional,
             .ephemeral:

            try await scheduleDailyNotifications(
                hasIncompleteTasks:
                    hasIncompleteTasks
            )

            return true


        case .denied:

            return false


        @unknown default:

            return false
        }
    }


    // MARK: - Disable Notifications In App

    func disableNotifications() {

        /*
         هذا يلغي الإشعارات المجدولة من Inner Motion.

         ملاحظة:
         ما نقدر نلغي إذن iOS نفسه برمجيًا.
         المستخدم يقدر يغير الإذن من Settings.
         */

        center.removePendingNotificationRequests(
            withIdentifiers: [
                encouragementID,
                taskReminderID
            ]
        )

        center.removeDeliveredNotifications(
            withIdentifiers: [
                encouragementID,
                taskReminderID
            ]
        )
    }


    // MARK: - Schedule Notifications

    func scheduleDailyNotifications(
        hasIncompleteTasks: Bool
    ) async throws {

        // أولًا نشيل الجدولة القديمة
        center.removePendingNotificationRequests(
            withIdentifiers: [
                encouragementID,
                taskReminderID
            ]
        )


        // MARK: Encouragement Notification - 11:00 AM

        let encouragementContent =
            UNMutableNotificationContent()

        encouragementContent.title =
            "Inner Motion"

        encouragementContent.body =
            "Small progress still counts. One tiny step is enough for today."

        encouragementContent.sound =
            .default

        var encouragementTime =
            DateComponents()

        encouragementTime.hour = 11
        encouragementTime.minute = 0

        let encouragementTrigger =
            UNCalendarNotificationTrigger(
                dateMatching:
                    encouragementTime,
                repeats:
                    true
            )

        let encouragementRequest =
            UNNotificationRequest(
                identifier:
                    encouragementID,
                content:
                    encouragementContent,
                trigger:
                    encouragementTrigger
            )

        try await center.add(
            encouragementRequest
        )


        // MARK: Task Reminder - 6:00 PM

        /*
         ما نجدول تذكير Task
         إذا المستخدم ما عنده أي مهمة
         Not Started أو In Progress.
         */

        if hasIncompleteTasks {

            let taskContent =
                UNMutableNotificationContent()

            taskContent.title =
                "Inner Motion"

            taskContent.body =
                "You still have a task waiting for you. One small step can be enough."

            taskContent.sound =
                .default

            var taskTime =
                DateComponents()

            taskTime.hour = 18
            taskTime.minute = 0

            let taskTrigger =
                UNCalendarNotificationTrigger(
                    dateMatching:
                        taskTime,
                    repeats:
                        true
                )

            let taskRequest =
                UNNotificationRequest(
                    identifier:
                        taskReminderID,
                    content:
                        taskContent,
                    trigger:
                        taskTrigger
                )

            try await center.add(
                taskRequest
            )
        }
    }


    // MARK: - Refresh Task Reminder

    func refreshNotifications(
        hasIncompleteTasks: Bool
    ) async {

        let status =
            await authorizationStatus()

        guard status == .authorized ||
              status == .provisional ||
              status == .ephemeral
        else {
            return
        }

        do {

            try await scheduleDailyNotifications(
                hasIncompleteTasks:
                    hasIncompleteTasks
            )

        } catch {

            print(
                "Failed to refresh notifications: \(error)"
            )
        }
    }


    // MARK: - Open App Notification Settings

    @MainActor
    func openSettings() {

        guard let settingsURL =
                URL(
                    string:
                        UIApplication.openSettingsURLString
                )
        else {
            return
        }

        UIApplication.shared.open(
            settingsURL
        )
    }
}
