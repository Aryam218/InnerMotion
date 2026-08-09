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

    @Guide(
        description:
        "The exact original task title provided by the user. Do not rewrite, shorten, split, or rename it."
    )
    var title: String

    @Guide(
        description:
        "A list of very small, concrete, immediately actionable steps for completing this single task."
    )
    var steps: [GeneratedTaskStep]
}


@Generable
struct GeneratedTaskStep {

    @Guide(
        description:
        "A short concrete action the user can do immediately."
    )
    var text: String

    @Guide(
        description:
        "Estimated number of minutes needed for this step."
    )
    var estimatedMinutes: Int
}


// النتيجة النهائية لكل المهام الأصلية
struct GeneratedDayPlan {
    let tasks: [GeneratedTaskPlan]
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

        var generatedPlans: [GeneratedTaskPlan] = []

        // كل UserTask تدخل للمودل لوحدها
        for task in tasks {

            let generatedTask =
                try await generateSingleTaskPlan(
                    task: task,
                    dayPlan: dayPlan,
                    model: model
                )

            generatedPlans.append(
                generatedTask
            )
        }

        return GeneratedDayPlan(
            tasks: generatedPlans
        )
    }


    // MARK: - Generate One Original Task

    private func generateSingleTaskPlan(
        task: UserTask,
        dayPlan: DayPlan,
        model: SystemLanguageModel
    ) async throws -> GeneratedTaskPlan {

        let session = LanguageModelSession(
            model: model,
            instructions: """
            You are a task planning assistant for a productivity app
            designed for users who may have low energy and difficulty
            starting tasks.

            You will receive EXACTLY ONE original user task.

            Your job is to break that ONE task into small actionable steps.

            Strict rules:

            - The input represents ONE task only.
            - Return exactly ONE task plan.
            - Never split the original task into multiple tasks.
            - Never create additional task titles.
            - Keep the task title exactly the same as the user's original title.
            - Put every subdivision of the task inside the steps array.
            - Break the task into approximately 3 to 5 small steps when appropriate.
            - Each step must be concrete and immediately actionable.
            - Keep the first step especially easy to start.
            - Avoid vague advice.
            - Avoid motivational speeches.
            - Consider the user's current energy level.
            - Consider the available time.
            - Consider priority and due date.
            """
        )

        let dueDateText: String

        if let dueDate = task.dueDate {

            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM yyyy"

            dueDateText =
                formatter.string(
                    from: dueDate
                )

        } else {

            dueDateText = "No due date"
        }


        let prompt = """
        Create steps for this ONE task.

        Original task title:
        \(task.title)

        Priority:
        \(task.priority)

        Due date:
        \(dueDateText)

        Current energy level:
        \(dayPlan.energyLevel)

        Available time:
        \(dayPlan.availableMinutes) minutes

        Important:
        This is ONE task.

        Do NOT turn parts of the task into separate tasks.

        For example, if the task contains:
        "study chapters, review formulas, and solve practice questions"

        those are parts or steps of the SAME task,
        not three separate tasks.

        Keep the returned task title EXACTLY:

        \(task.title)

        Then break it into small practical steps.
        """


        let response =
            try await session.respond(
                to: prompt,
                generating: GeneratedTaskPlan.self
            )

        var result = response.content

        // ضمان إضافي:
        // حتى لو المودل غير العنوان نرجعه للأصلي
        result.title = task.title

        return result
    }


    // MARK: - Make Existing Task Easier

    func makeTaskEasier(
        task: PlannedTask
    ) async throws -> GeneratedTaskPlan {

        let model = SystemLanguageModel.default

        guard model.availability == .available else {
            throw TaskPlanningError.modelUnavailable
        }

        let orderedSteps =
            task.steps.sorted {
                $0.order < $1.order
            }

        guard !orderedSteps.isEmpty else {
            throw TaskPlanningError.noStepsAvailable
        }

        let currentStepsText =
            orderedSteps
                .enumerated()
                .map { index, step in

                    """
                    Step \(index + 1):
                    \(step.text)
                    Estimated time: \(step.estimatedMinutes) minutes
                    """
                }
                .joined(
                    separator: "\n\n"
                )

        let session = LanguageModelSession(
            model: model,
            instructions: """
            You are helping a user who is having difficulty starting
            or continuing a task.

            The user already has a task plan, but it still feels too difficult.

            Your job is to make the SAME task easier.

            Strict rules:

            - Keep the exact same original task.
            - Do not create a new task.
            - Do not rename the task.
            - Do not remove any important part of the original goal.
            - Make the steps smaller, simpler, and easier to begin.
            - The new steps must be more manageable than the current steps.
            - The first step should require very little effort.
            - Prefer short, concrete, immediately actionable steps.
            - It is okay to create many small steps if that genuinely makes the task easier.

            - Do NOT invent tools, devices, apps, materials, locations,
              people, ingredients, or resources that are not mentioned
              or reasonably required by the original task or current steps.

            - Do NOT assume a specific method that the user did not provide.
            - Do NOT add optional setup steps that are unrelated to completing the task.
            - Only add a prerequisite when it is genuinely necessary to perform
              one of the existing task goals.

            - Preserve all important parts of the original task.
            - Every step must contribute directly to completing the original task.
            - Every step must be different from every other step.
            - Never repeat the same action or sentence.
            - Do not create two steps that mean essentially the same thing.
            - Arrange the steps in the logical order the user should perform them.
            - A prerequisite action must come before the action that depends on it.

            - Avoid vague instructions.
            - Avoid motivational speeches.
            - Do not tell the user to simply try harder.
            - Keep the plan realistic.
            """
        )

        let prompt = """
        Make this existing task plan easier.

        Original task:
        \(task.title)

        Current steps:

        \(currentStepsText)

        Return ONE task plan only.

        Keep the title EXACTLY:

        \(task.title)

        Create a new sequence of smaller,
        simpler, immediately actionable steps.

        Important:
        - You may split difficult actions into more small steps.
        - Do not repeat any step.
        - Each step must describe a unique action.
        - Preserve every important goal from the original task.
        - Do not invent unrelated tools, devices, apps, materials,
          resources, locations, or requirements.
        - Do not assume the user is using a phone, computer, app,
          website, recipe source, or other tool unless the task
          or current steps already indicate that.
        - Every new step must directly help complete the original task.
        - Put the steps in the real order they should be performed.
        - If one action genuinely requires another first,
          place the prerequisite first.
        - Make the new plan clearly easier to start than the current plan.
        """

        let response =
            try await session.respond(
                to: prompt,
                generating: GeneratedTaskPlan.self
            )

        var result = response.content

        // ما نسمح للـ AI يغير اسم المهمة
        result.title = task.title

        // MARK: - Remove Duplicate Steps

        var seenSteps = Set<String>()

        let uniqueSteps = result.steps.filter { step in

            let normalizedText =
                step.text
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .lowercased()

            guard !normalizedText.isEmpty else {
                return false
            }

            if seenSteps.contains(normalizedText) {
                return false
            }

            seenSteps.insert(normalizedText)

            return true
        }

        // نستبدل خطوات AI بالخطوات الفريدة فقط
        result.steps = uniqueSteps

        return result
    }
}


// MARK: - Errors

enum TaskPlanningError: LocalizedError {

    case modelUnavailable
    case noStepsAvailable

    var errorDescription: String? {

        switch self {

        case .modelUnavailable:

            return
                "Apple Intelligence is not available on this device."

        case .noStepsAvailable:

            return
                "There are no steps available to simplify."
        }
    }
}
