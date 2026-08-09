//
//  TaskPlanningService.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 26/02/1448 AH.
//

import Foundation
import FoundationModels

// MARK: - AI Response Models

@Generable
struct GeneratedTaskPlan {
    @Guide(description: "The original task title exactly as provided by the user.")
    var title: String

    @Guide(description: "A list of very small, concrete, immediately actionable steps for completing this task.")
    var steps: [GeneratedTaskStep]
}

@Generable
struct GeneratedTaskStep {
    @Guide(description: "A short concrete action the user can do immediately.")
    var text: String

    @Guide(description: "Estimated number of minutes needed for this step.")
    var estimatedMinutes: Int
}

@Generable
struct GeneratedDayPlan {
    @Guide(description: "The user's tasks, ordered in the most appropriate sequence based on priority, due date, energy, and available time.")
    var tasks: [GeneratedTaskPlan]
}


// MARK: - Planning Service

@MainActor
final class TaskPlanningService {

    static let shared = TaskPlanningService()

    private init() {}

    // MARK: - Model Availability

    var isModelAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    // MARK: - Generate Plan

    func generatePlan(
        tasks: [UserTask],
        dayPlan: DayPlan
    ) async throws -> GeneratedDayPlan {

        let model = SystemLanguageModel.default

        guard model.availability == .available else {
            throw TaskPlanningError.modelUnavailable
        }

        let session = LanguageModelSession(
            model: model,
            instructions: """
            You are a task planning assistant for a productivity app designed
            for users who may have low energy and difficulty starting tasks.

            Your job is to create a gentle, practical plan.

            Follow these rules:
            - Break every task into very small and concrete steps.
            - Each step must be immediately actionable.
            - Avoid vague advice and motivational speeches.
            - Keep the first step especially easy to start.
            - Consider the user's current energy level.
            - Consider the total available time.
            - Consider task priority and due date.
            - If there are multiple tasks, order them appropriately.
            - Do not invent new tasks.
            - Keep the total plan realistic for the user's available time.
            """
        )

        let taskDescriptions = tasks.enumerated().map { index, task in

            let dueDateText: String

            if let dueDate = task.dueDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM yyyy"
                dueDateText = formatter.string(from: dueDate)
            } else {
                dueDateText = "No due date"
            }

            return """
            Task \(index + 1):
            Title: \(task.title)
            Priority: \(task.priority)
            Due date: \(dueDateText)
            """
        }
        .joined(separator: "\n\n")

        let prompt = """
        Create a plan for the following user.

        Current energy level:
        \(dayPlan.energyLevel)

        Total available time:
        \(dayPlan.availableMinutes) minutes

        Tasks:
        \(taskDescriptions)

        Break each task into approximately 3 to 5 small steps when appropriate.
        Keep each step short and practical.
        """

        let response = try await session.respond(
            to: prompt,
            generating: GeneratedDayPlan.self
        )

        return response.content
    }
}


// MARK: - Errors

enum TaskPlanningError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple Intelligence is not available on this device."
        }
    }
}
