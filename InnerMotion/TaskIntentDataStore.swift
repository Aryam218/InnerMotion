//
//  TaskIntentDataStore.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 28/02/1448 AH.
//

import Foundation
import SwiftData

@MainActor
final class TaskIntentDataStore {

    static let shared = TaskIntentDataStore()

    let container: ModelContainer

    private init() {

        do {

            container = try ModelContainer(
                for:
                    UserTask.self,
                    DayPlan.self,
                    PlannedTask.self,
                    TaskStep.self,
                    SuggestionActivity.self
            )

        } catch {

            fatalError(
                "Failed to create SwiftData container: \(error)"
            )
        }
    }

    // MARK: - Save Task From Siri

    func save(
        _ task: UserTask
    ) throws {

        let context =
            ModelContext(container)

        context.insert(task)

        try context.save()

        print(
            "Task saved from Siri: \(task.title)"
        )
    }
}
