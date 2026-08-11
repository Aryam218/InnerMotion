//
//  AddTaskIntent.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 28/02/1448 AH.
//

import AppIntents
import SwiftData
import Foundation

// MARK: - Priority For Siri

enum SiriTaskPriority: String, AppEnum {

    case high
    case medium
    case low

    static var typeDisplayRepresentation =
        TypeDisplayRepresentation(
            name: "Priority"
        )

    static var caseDisplayRepresentations:
        [SiriTaskPriority: DisplayRepresentation] = [

            .high:
                DisplayRepresentation(
                    title: "High"
                ),

            .medium:
                DisplayRepresentation(
                    title: "Medium"
                ),

            .low:
                DisplayRepresentation(
                    title: "Low"
                )
        ]

    var taskPriorityValue: String {

        switch self {

        case .high:
            return "High"

        case .medium:
            return "Medium"

        case .low:
            return "Low"
        }
    }
}


// MARK: - Add Task Intent

struct AddTaskIntent: AppIntent {

    static var title:
        LocalizedStringResource =
            "Add Task"

    static var description =
        IntentDescription(
            "Adds a new task to Inner Motion so you can continue planning it later."
        )

    // ما نبي يفتح التطبيق
    static var openAppWhenRun:
        Bool = false


    // MARK: - Task Name

    @Parameter(
        title: "Task",
        requestValueDialog:
            IntentDialog(
                "What task would you like to add?"
            )
    )
    var taskName: String


    // MARK: - Priority

    @Parameter(
        title: "Priority",
        requestValueDialog:
            IntentDialog(
                "What is the priority?"
            )
    )
    var priority:
        SiriTaskPriority


    // MARK: - Run Intent

    @MainActor
    func perform() async throws
        -> some IntentResult & ProvidesDialog {

        let cleanTitle =
            taskName
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        guard !cleanTitle.isEmpty else {

            return .result(
                dialog:
                    "I couldn't add an empty task."
            )
        }

        // نعطي المهمة Session خاصة فيها
        // عشان تظهر لاحقًا في Continue Planning
        let sessionID =
            UUID()

        // بنربط هذا بالـ SwiftData
        // في الخطوة التالية
        let newTask =
            UserTask(

                title:
                    cleanTitle,

                priority:
                    priority
                        .taskPriorityValue,

                dueDate:
                    nil,

                status:
                    "Not Started",

                planningSessionID:
                    sessionID,

                isPlanned:
                    false
            )

        try TaskIntentDataStore
            .shared
            .save(
                newTask
            )

        return .result(
            dialog:
                "Added \(cleanTitle) to Inner Motion."
        )
    }
}
