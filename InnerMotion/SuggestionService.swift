//
//  SuggestionService.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 27/02/1448 AH.
//

import Foundation
import FoundationModels

// MARK: - AI Response Model

@Generable
struct GeneratedSuggestion {

    @Guide(
        description:
        "One short, concrete activity suggestion that directly matches the user's selected category, energy level, available time, and location."
    )
    var activity: String

    @Guide(
        description:
        "Estimated number of minutes needed to complete the suggested activity. It must not exceed the user's available time."
    )
    var estimatedMinutes: Int

    @Guide(
        description:
        "The difficulty of the activity. Use exactly one of these values: Very Easy, Easy, Moderate."
    )
    var difficulty: String
}


// MARK: - Suggestion Service

@MainActor
final class SuggestionService {

    static let shared = SuggestionService()

    private init() {}


    // MARK: - Model Availability

    var isModelAvailable: Bool {

        SystemLanguageModel.default.availability
        ==
        .available
    }


    // MARK: - Generate Suggestion

    func generateSuggestion(
        category: SuggestionCategory,
        energy: EnergyLevel,
        availableTime: AvailableTime,
        location: UserLocation,
        previousSuggestions: [String] = [],
        feedbackHistory: [SuggestionActivity] = []
    ) async throws -> GeneratedSuggestion {

        let model =
            SystemLanguageModel.default

        guard model.availability == .available else {

            throw SuggestionServiceError
                .modelUnavailable
        }


        // MARK: - Previous Suggestions

        let previousSuggestionsText: String

        if previousSuggestions.isEmpty {

            previousSuggestionsText =
                "None"

        } else {

            previousSuggestionsText =
                previousSuggestions
                    .enumerated()
                    .map {
                        index,
                        suggestion in

                        "\(index + 1). \(suggestion)"
                    }
                    .joined(
                        separator: "\n"
                    )
        }


        // MARK: - Feedback History

        let feedbackText =
            buildFeedbackContext(
                from: feedbackHistory
            )


        // MARK: - Retry Settings

        let maxAttempts = 3

        var lastDuplicateActivity:
            String?


        // MARK: - Retry Loop

        for attempt in 1...maxAttempts {

            // MARK: - Session

            let session =
                LanguageModelSession(
                    model: model,
                    instructions: """
                    You are an activity suggestion assistant for a wellbeing
                    and productivity app.

                    The user may have low energy or difficulty deciding what
                    to do right now.

                    Your job is to suggest exactly ONE simple activity.

                    The suggestion must be practical, gentle, and immediately
                    actionable.

                    Strict rules:

                    - Return exactly ONE activity.
                    - Do not return a list of activities.
                    - Match the selected category.
                    - Match the user's current energy level.
                    - Match the user's available time.
                    - Match the user's current location.
                    - The estimated time must never exceed the user's available time.
                    - The activity should be realistic for the selected location.
                    - Do not invent unnecessary tools, apps, devices, equipment,
                      people, locations, or materials.
                    - Only suggest something that can reasonably be done with
                      ordinary resources expected in the user's current location.
                    - Keep the activity specific and concrete.
                    - Avoid vague advice.
                    - Avoid motivational speeches.
                    - Avoid medical advice.
                    - Do not diagnose the user.

                    - Do not repeat an activity that has already been shown
                      during the current session.

                    - A new suggestion must be meaningfully different in the
                      ACTION itself, not only different wording.

                    - Do not give another variation of the same type of activity
                      if that type has already been shown in the current session.

                    - Treat semantically similar activities as duplicates.

                    For example:
                    "Take three deep breaths",
                    "Close your eyes and breathe slowly",
                    "Practice deep breathing",
                    and
                    "Take slow calming breaths"
                    are all the SAME type of activity.

                    If a breathing activity has already been shown, choose a
                    genuinely different kind of activity next, while still
                    respecting the selected category.

                    For a Calm category, possible activity types may include,
                    when suitable:
                    - quiet observation
                    - listening to something calming
                    - a simple warm drink
                    - light journaling
                    - gentle stretching
                    - sitting somewhere comfortable
                    - a short sensory activity
                    - breathing

                    These are examples of variety only.
                    Do not force any specific example if it does not fit the
                    user's energy, time, or location.

                    For Light Movement, vary between genuinely different forms
                    of light movement rather than rephrasing the same movement.

                    For Gentle Connection, vary between genuinely different
                    simple ways of connecting rather than repeatedly suggesting
                    the same communication action.

                    For Not Sure, choose a suitable activity from different
                    possible types based on the user's current situation.

                    - If previous feedback is provided, use it only as a preference
                      signal, not as an absolute rule.
                    - Activities previously marked Helpful may inspire similar
                      suggestions in future sessions.
                    - Activities marked Not for Me should generally be avoided.
                    - Activities marked I Need Something Easier should guide you
                      toward simpler activities.

                    - Difficulty must be exactly one of:
                      Very Easy
                      Easy
                      Moderate
                    """
                )


            // MARK: - Retry Context

            let retryInstruction: String

            if attempt == 1 {

                retryInstruction =
                    "This is the first generation attempt."

            } else {

                retryInstruction = """
                A previous generation attempt produced an activity that was
                too similar to something already shown.

                You MUST choose a different underlying action this time.

                Do not return:
                \(lastDuplicateActivity ?? "the previous duplicate activity")

                Change the actual type of activity, not just the wording.
                """
            }


            // MARK: - Prompt

            let prompt = """
            Suggest ONE activity for this user.

            Selected category:
            \(category.title.replacingOccurrences(of: "\n", with: " "))

            Energy level:
            \(energy.title)

            Available time:
            \(availableTime.title)

            Current location:
            \(location.title)

            Suggestions already shown in this session:
            \(previousSuggestionsText)

            Previous user feedback:
            \(feedbackText)

            Retry information:
            \(retryInstruction)

            Important:
            - Give only one activity.
            - It must fit the selected category.
            - It must be suitable for the current energy level.
            - Its estimated duration must fit within the available time.
            - It must be possible in the user's current location.

            - Do not repeat any previous suggestion.
            - Do not slightly rephrase any previous suggestion.
            - Do not repeat the same underlying activity type.

            - If a previous suggestion involved breathing, the next suggestion
              must not be another breathing exercise.

            - If a previous suggestion involved stretching, the next suggestion
              should not simply be another version of stretching.

            - If a previous suggestion involved sitting quietly, the next
              suggestion should use a genuinely different action.

            - Think about what the user would physically DO.
              That action should be different from previous actions.

            - A new suggestion must be meaningfully different, while still
              staying inside the selected category.

            - Do not assume the user has special equipment or resources.
            - Keep it simple and immediately actionable.
            """


            // MARK: - AI Response

            let response =
                try await session.respond(
                    to: prompt,
                    generating:
                        GeneratedSuggestion.self
                )

            var result =
                response.content


            // MARK: - Validate Estimated Time

            let maxMinutes =
                maximumMinutes(
                    for: availableTime
                )

            result.estimatedMinutes =
                min(
                    max(
                        result.estimatedMinutes,
                        1
                    ),
                    maxMinutes
                )


            // MARK: - Validate Difficulty

            let allowedDifficulties =
                [
                    "Very Easy",
                    "Easy",
                    "Moderate"
                ]

            if !allowedDifficulties.contains(
                result.difficulty
            ) {

                result.difficulty =
                    fallbackDifficulty(
                        for: energy
                    )
            }


            // MARK: - Check Duplicate

            let normalizedResult =
                normalize(
                    result.activity
                )

            let alreadyShown =
                previousSuggestions.contains {

                    normalize($0)
                    ==
                    normalizedResult
                }


            // MARK: - Success

            if !alreadyShown {

                return result
            }


            // MARK: - Duplicate Found

            lastDuplicateActivity =
                result.activity

            print(
                """
                Duplicate suggestion detected.
                Attempt: \(attempt) of \(maxAttempts)
                Activity: \(result.activity)
                """
            )
        }


        // MARK: - All Attempts Failed

        throw SuggestionServiceError
            .duplicateSuggestion
    }


    // MARK: - Available Time Limit

    private func maximumMinutes(
        for availableTime: AvailableTime
    ) -> Int {

        switch availableTime {

        case .fiveMinutes:

            return 5

        case .tenMinutes:

            return 10

        case .twentyPlusMinutes:

            return 20
        }
    }


    // MARK: - Fallback Difficulty

    private func fallbackDifficulty(
        for energy: EnergyLevel
    ) -> String {

        switch energy {

        case .veryLow:

            return "Very Easy"

        case .low:

            return "Very Easy"

        case .medium:

            return "Easy"

        case .high:

            return "Moderate"
        }
    }


    // MARK: - Normalize Text

    private func normalize(
        _ text: String
    ) -> String {

        text
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )
            .lowercased()
    }


    // MARK: - Build Feedback Context

    private func buildFeedbackContext(
        from history: [SuggestionActivity]
    ) -> String {

        let completedFeedback =
            history
                .filter {
                    $0.feedback != nil
                }
                .sorted {
                    $0.createdAt >
                    $1.createdAt
                }

        guard !completedFeedback.isEmpty else {

            return "No previous feedback is available."
        }


        // نستخدم آخر 10 فقط
        // عشان البرومبت ما يكبر بدون داعي
        let recentHistory =
            Array(
                completedFeedback
                    .prefix(10)
            )

        return recentHistory
            .map { item in

                """
                Activity:
                \(item.activityText)

                Feedback:
                \(item.feedback ?? "No feedback")
                """
            }
            .joined(
                separator: "\n\n"
            )
    }
}


// MARK: - Errors

enum SuggestionServiceError:
    LocalizedError {

    case modelUnavailable
    case duplicateSuggestion

    var errorDescription: String? {

        switch self {

        case .modelUnavailable:

            return
                "Apple Intelligence is not available on this device."

        case .duplicateSuggestion:

            return
                "A different suggestion could not be generated. Please try again."
        }
    }
}
