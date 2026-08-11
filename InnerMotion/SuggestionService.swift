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
        """
        One short, concrete activity suggestion that matches the user's
        selected category, energy, available time, and location.

        Write it in a warm, gentle, low-pressure tone.

        It should feel like a small invitation, not a command.

        Keep it concise.
        Prefer one short sentence.
        Use at most two short sentences.
        """
    )
    var activity: String

    @Guide(
        description:
        """
        Estimated number of minutes needed.

        It must not exceed the user's available time.
        It may be much shorter than the available time.
        """
    )
    var estimatedMinutes: Int

    @Guide(
        description:
        """
        Use exactly one value:

        Very Easy
        Easy
        Moderate
        """
    )
    var difficulty: String
}


// MARK: - Suggestion Service

@MainActor
final class SuggestionService {

    static let shared =
        SuggestionService()

    private init() {}


    // MARK: - Session Suggestion Memory

    /*
     نحفظ الاقتراحات التي ولّدها السيرفس نفسه
     لكل combination مختلف:

     Category + Energy + Time + Location

     حتى لو صار أي تأخير في تحديث الـ View،
     السيرفس نفسه يعرف الأشياء التي سبق أن أعطاها.
     */

    private var generatedSuggestionsByContext:
        [String: [String]] = [:]


    // MARK: - Model Availability

    var isModelAvailable: Bool {

        SystemLanguageModel
            .default
            .availability
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


        guard
            model.availability
            ==
            .available
        else {

            throw SuggestionServiceError
                .modelUnavailable
        }


        // MARK: Current Context Key

        let contextKey =
            """
            \(category.rawValue)|\(energy.rawValue)|\(availableTime.rawValue)|\(location.rawValue)
            """


        // MARK: Previous Suggestions From Service

        let serviceSuggestions =
            generatedSuggestionsByContext[
                contextKey
            ]
            ??
            []


        // MARK: Merge Previous Suggestions

        let allPreviousSuggestions =
            mergeUniqueSuggestions(
                previousSuggestions
                +
                serviceSuggestions
            )


        // MARK: Previous Suggestions Text

        let previousSuggestionsText: String

        if allPreviousSuggestions.isEmpty {

            previousSuggestionsText =
                "None"

        } else {

            previousSuggestionsText =
                allPreviousSuggestions
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


        // MARK: Previously Used Families

        let usedFamilies =
            Set(
                allPreviousSuggestions
                    .compactMap {
                        activityFamily(
                            for: $0
                        )
                    }
            )


        // MARK: Feedback History

        let feedbackText =
            buildFeedbackContext(
                from:
                    feedbackHistory
            )


        // MARK: Retry Settings

        /*
         نعطي Apple model عدة محاولات.

         إذا ما قدر يطلع اقتراح مناسب بعد كل المحاولات،
         ما نرمي duplicateSuggestion للمستخدم.

         بدلاً منه نستخدم fallback آمن ومختلف.
         */

        let maxAttempts =
            6

        var lastRejectedActivity:
            String?

        var lastRejectionReason:
            String?


        // MARK: Retry Loop

        for attempt in 1...maxAttempts {

            // MARK: Model Session

            let session =
                LanguageModelSession(
                    model:
                        model,
                    instructions:
                    """
                    Suggest exactly ONE small activity for a wellbeing
                    and productivity app.

                    The app supports people who may have:

                    - very low energy
                    - low motivation
                    - difficulty starting activities
                    - reduced concentration
                    - decision fatigue

                    Do NOT diagnose the user.

                    Do NOT mention depression in the generated activity.

                    Do NOT assume how the user currently feels.

                    Do NOT provide:

                    - therapy
                    - treatment
                    - medical advice
                    - motivational speeches
                    - emotional promises

                    The purpose is simply to make one small activity
                    easier to begin.

                    ==================================================
                    OVERALL EXPERIENCE
                    ==================================================

                    The activity should feel:

                    - warm
                    - gentle
                    - understanding
                    - low-pressure
                    - simple
                    - concrete
                    - immediately actionable

                    Phrase it like a gentle invitation.

                    Do not sound demanding.

                    Especially for Low or Very Low energy,
                    make the activity very small.

                    Natural wording may include phrases such as:

                    - "If you'd like..."
                    - "If it feels manageable..."
                    - "A small ... is enough."
                    - "You can keep it brief."
                    - "No need to..."
                    - "Just one ... is enough."
                    - "A quick ... is enough for now."

                    Use these only when natural.

                    Do NOT repeatedly use the same opening phrase.

                    Keep the answer concise.

                    Prefer ONE short sentence.

                    Use at most TWO short sentences.

                    ==================================================
                    DO NOT ASSUME FEELINGS
                    ==================================================

                    Never begin with assumptions such as:

                    - "If you're overwhelmed..."
                    - "If you're feeling down..."
                    - "If you're stressed..."
                    - "If you're anxious..."
                    - "If you don't feel like it..."

                    Never tell the user to do something
                    despite not wanting to do it.

                    Do not say:

                    - "even if you don't feel like it"
                    - "push yourself"
                    - "force yourself"
                    - "make yourself do it"

                    ==================================================
                    DO NOT PROMISE EMOTIONAL RESULTS
                    ==================================================

                    Do not claim the activity will:

                    - make the user feel better
                    - improve their mood
                    - brighten their day
                    - brighten someone else's day
                    - cheer them up
                    - help them refocus
                    - reduce depression
                    - remove stress
                    - fix overwhelm

                    Just describe the activity itself.

                    ==================================================
                    CATEGORY IS THE PRIMARY CONSTRAINT
                    ==================================================

                    The selected category is the PRIMARY constraint.

                    Energy changes how EASY it should be.

                    Available time limits how LONG it may take.

                    Location changes what is REALISTIC.

                    Energy, time, and location must NOT
                    change the meaning of the category.

                    ==================================================
                    CALM
                    ==================================================

                    Calm means a quiet, settling,
                    low-stimulation SOLO activity.

                    The purpose is simply to create
                    a small calm moment.

                    Possible Calm activity families include:

                    1. Breathing
                    2. Quiet observation
                    3. Listening
                    4. One short written thought
                    5. Sensory grounding
                    6. Quiet sitting
                    7. Slowly sipping a familiar drink
                    8. Gentle relaxing body release

                    Calm must NOT primarily involve:

                    - another person
                    - messaging someone
                    - calling someone
                    - greeting someone
                    - social interaction
                    - work
                    - studying
                    - productivity
                    - cleaning
                    - organizing
                    - exercise

                    For Low or Very Low energy:

                    - use one small action
                    - minimal preparation
                    - minimal decision-making
                    - minimal physical effort

                    ==================================================
                    GENTLE CONNECTION
                    ==================================================

                    Gentle Connection MUST directly
                    involve another person.

                    A solo activity is NEVER
                    Gentle Connection.

                    The goal is a very small moment
                    of human connection with minimal social pressure.

                    Possible Gentle Connection families include:

                    1. Digital reaction
                       Example type:
                       one emoji reaction.

                    2. Short message
                       Example type:
                       one brief hello.

                    3. Reply
                       Example type:
                       one short acknowledgment
                       to an existing message.

                    4. Gratitude
                       Example type:
                       one brief thank-you.

                    5. Share
                       Example type:
                       share one simple photo,
                       meme, or ordinary thing.

                    6. In-person acknowledgment
                       Example type:
                       one nod, smile, wave,
                       or brief greeting.

                    7. Brief conversation
                       Example type:
                       one short ordinary sentence.

                    8. Presence
                       Example type:
                       briefly sitting near someone familiar.

                    9. Short call
                       Only when energy makes this reasonable.

                    Important:

                    Nod, smile, wave, hello,
                    greeting, and good morning
                    belong to the SAME general family:

                    IN-PERSON ACKNOWLEDGMENT.

                    Do not generate several variations
                    of that same family one after another.

                    Message, text, and DM belong
                    to the same general family:

                    SHORT MESSAGE.

                    Emoji and message reaction belong
                    to the same general family:

                    DIGITAL REACTION.

                    For Low or Very Low energy:

                    - prefer one tiny interaction
                    - prefer easy-to-stop interaction
                    - avoid deep conversation
                    - avoid emotional disclosure
                    - avoid pressure to keep talking
                    - prefer short or asynchronous contact

                    Gentle Connection MUST NOT be:

                    - noticing a plant
                    - observing an object
                    - breathing alone
                    - journaling alone
                    - drinking something alone
                    - sitting quietly alone
                    - listening alone
                    - stretching alone

                    ==================================================
                    LIGHT MOVEMENT
                    ==================================================

                    Light Movement MUST involve
                    actual gentle physical movement.

                    Possible Light Movement families include:

                    1. Short walking
                    2. Gentle stretching
                    3. Shoulder movement
                    4. Neck movement
                    5. Arm movement
                    6. Leg movement
                    7. Standing movement
                    8. Small mobility movement

                    This is NOT exercise training.

                    Do not turn it into:

                    - a workout
                    - repetitions
                    - performance
                    - a fitness target

                    For Very Low energy:

                    - make the movement extremely small
                    - avoid preparation
                    - avoid changing location
                    - avoid sustained effort
                    - one small movement is enough

                    For Low energy:

                    - one clear movement
                    - short duration
                    - easy to stop

                    ==================================================
                    NOT SURE
                    ==================================================

                    If category is Not Sure:

                    Silently choose ONE of:

                    - Calm
                    - Gentle Connection
                    - Light Movement

                    Then generate ONE activity
                    from that direction.

                    Do not ask the user to choose.

                    Do not give alternatives.

                    Do not combine categories.

                    Consider:

                    - energy
                    - time
                    - location
                    - previous suggestions
                    - feedback
                    - variety

                    Do not automatically choose Calm every time.

                    ==================================================
                    ENERGY
                    ==================================================

                    Very Low:

                    - normally Very Easy
                    - smallest meaningful activity
                    - one clear action
                    - minimal preparation
                    - minimal decisions
                    - minimal physical effort
                    - minimal social pressure
                    - easy to stop

                    Low:

                    - normally Very Easy or Easy
                    - one bounded activity
                    - low effort
                    - little preparation
                    - little decision-making

                    Medium:

                    - normally Easy
                    - moderate engagement is acceptable
                    - still keep it simple

                    High:

                    - may be Easy or Moderate
                    - may be somewhat more engaging
                    - still keep it gentle

                    IMPORTANT:

                    More available time does NOT mean
                    the activity needs to become harder.

                    ==================================================
                    TIME
                    ==================================================

                    Available time is only a MAXIMUM.

                    It is NOT a target.

                    If the user has 10 minutes,
                    a 1-minute activity is completely acceptable.

                    If the user has 20+ minutes,
                    a 2-minute activity is completely acceptable.

                    Choose duration based mainly on energy
                    and suitability.

                    ==================================================
                    LOCATION
                    ==================================================

                    The activity must realistically fit
                    the selected location.

                    Do not invent:

                    - a park
                    - a café
                    - a gym
                    - a plant
                    - flowers
                    - special equipment
                    - a close coworker
                    - another person living at home

                    At Work:

                    - activities should be discreet
                    - do not force coworker interaction
                    - remote connection is allowed

                    At Home:

                    - do not assume someone else is home
                    - remote connection is allowed

                    Outside:

                    - do not assume a specific facility exists

                    ==================================================
                    ONE ACTIVITY ONLY
                    ==================================================

                    Return exactly ONE underlying activity.

                    Do not bundle multiple independent actions.

                    Bad:

                    "Send a message or smile at someone."

                    That contains alternatives.

                    Better:

                    "Send one simple emoji reaction
                    to a recent message."

                    Bad:

                    "Take a walk and stretch."

                    Better:

                    "Take a few slow steps
                    around your current space."

                    ==================================================
                    DUPLICATE PREVENTION
                    ==================================================

                    The list called "Already shown"
                    contains activities the user has already seen.

                    NEVER reproduce one of them.

                    A wording change does NOT make it new.

                    You must compare the UNDERLYING ACTION.

                    Examples:

                    "Give someone a nod."

                    "Smile at someone nearby."

                    "Wave briefly to a coworker."

                    "Say a quick hello."

                    These are all considered the SAME GENERAL FAMILY:

                    IN-PERSON ACKNOWLEDGMENT.

                    After one appears,
                    prefer a genuinely different family,
                    such as:

                    - digital reaction
                    - short message
                    - gratitude
                    - sharing
                    - brief conversation
                    - another valid category family

                    Likewise:

                    "Send a text."

                    "Send a short message."

                    "DM someone."

                    belong to the same family.

                    Likewise:

                    "Walk for a minute."

                    "Take a few steps."

                    belong to the same walking family.

                    Likewise:

                    "Notice something nearby."

                    "Look quietly at one object."

                    belong to the same observation family.

                    ==================================================
                    FEEDBACK
                    ==================================================

                    Previous feedback is a preference signal.

                    Helpful:

                    Similar effort or qualities
                    may be suitable again.

                    Not for Me:

                    Generally avoid that activity type.

                    I Need Something Easier:

                    Reduce:

                    - effort
                    - duration
                    - preparation
                    - social demand
                    - physical demand
                    - decisions

                    Feedback must NEVER cause
                    the activity to leave
                    the selected category.

                    ==================================================
                    FINAL CHECK
                    ==================================================

                    Before returning:

                    - exactly one activity
                    - correct category
                    - correct energy
                    - realistic time
                    - realistic location
                    - genuinely different from previous activities
                    - different underlying family when possible
                    - concise
                    - warm
                    - low pressure
                    - immediately actionable
                    - no diagnosis
                    - no therapy
                    - no medical advice
                    - no assumptions about feelings
                    - no emotional promises
                    - no "even if you don't feel like it"

                    Difficulty must be exactly:

                    Very Easy
                    Easy
                    Moderate
                    """
                )


            // MARK: Retry Context

            let retryInstruction:
                String

            if attempt == 1 {

                retryInstruction =
                    """
                    This is the first generation attempt.

                    Carefully review the Already shown list
                    before choosing an activity.
                    """

            } else {

                retryInstruction =
                    """
                    The previous result was rejected.

                    Rejected activity:

                    \(lastRejectedActivity ?? "Unknown")

                    Reason:

                    \(lastRejectionReason ?? "It did not meet the requirements.")

                    You MUST now choose a genuinely different
                    underlying activity.

                    Do not merely reword the rejected activity.

                    Prefer a DIFFERENT activity family.

                    Stay inside the selected category.
                    """
            }


            // MARK: Prompt

            let prompt =
                """
                Generate ONE activity.

                Selected category:
                \(category.title.replacingOccurrences(of: "\n", with: " "))

                Energy:
                \(energy.title)

                Available time:
                \(availableTime.title)

                Location:
                \(location.title)

                Already shown:
                \(previousSuggestionsText)

                Activity families already used:
                \(usedFamilies.isEmpty
                    ? "None"
                    : usedFamilies.sorted().joined(separator: ", ")
                )

                Previous user feedback:
                \(feedbackText)

                Retry information:
                \(retryInstruction)

                Final requirements:

                - Category is the primary rule.
                - Exactly one activity.
                - Do not give alternatives.
                - Energy determines effort.
                - Time is only a maximum.
                - Location must be realistic.
                - Keep it concise.
                - Keep it warm and low-pressure.
                - Do not assume feelings.
                - Do not promise an emotional result.
                - Do not invent resources.
                - Do not repeat an existing activity.
                - Avoid activity families that are already used
                  when another valid family is available.
                """
            

            // MARK: AI Response

            let response =
                try await
                session.respond(
                    to:
                        prompt,
                    generating:
                        GeneratedSuggestion.self
                )


            var result =
                response.content


            // MARK: Clean Activity Text

            result.activity =
                cleanActivityText(
                    result.activity
                )


            // MARK: Validate Estimated Time

            let maxMinutes =
                maximumMinutes(
                    for:
                        availableTime
                )


            result.estimatedMinutes =
                min(
                    max(
                        result.estimatedMinutes,
                        1
                    ),
                    maxMinutes
                )


            // MARK: Keep Low Energy Activities Short

            switch energy {

            case .veryLow:

                result.estimatedMinutes =
                    min(
                        result.estimatedMinutes,
                        3
                    )

            case .low:

                result.estimatedMinutes =
                    min(
                        result.estimatedMinutes,
                        5
                    )

            case .medium,
                 .high:

                break
            }


            // MARK: Validate Difficulty

            let allowedDifficulties =
                [
                    "Very Easy",
                    "Easy",
                    "Moderate"
                ]


            if
                !allowedDifficulties
                    .contains(
                        result.difficulty
                    )
            {

                result.difficulty =
                    fallbackDifficulty(
                        for:
                            energy
                    )
            }


            // MARK: Very Low Difficulty Protection

            if energy == .veryLow {

                result.difficulty =
                    "Very Easy"
            }


            // MARK: Validate Category

            if
                !matchesSelectedCategory(
                    activity:
                        result.activity,
                    category:
                        category
                )
            {

                lastRejectedActivity =
                    result.activity

                lastRejectionReason =
                    """
                    The activity did not match
                    the selected category.
                    """

                continue
            }


            // MARK: Validate Tone

            if
                containsDisallowedTone(
                    result.activity
                )
            {

                lastRejectedActivity =
                    result.activity

                lastRejectionReason =
                    """
                    The wording assumed feelings,
                    applied pressure,
                    or promised an emotional result.
                    """

                continue
            }


            // MARK: Detect Exact / Semantic Duplicate

            let isDuplicate =
                allPreviousSuggestions
                    .contains {
                        previous in

                        isTooSimilar(
                            result.activity,
                            previous
                        )
                    }


            if isDuplicate {

                lastRejectedActivity =
                    result.activity

                lastRejectionReason =
                    """
                    The activity was too similar
                    to something already shown.

                    Generate a different underlying action.
                    """

                continue
            }


            // MARK: Detect Duplicate Family

            let currentFamily =
                activityFamily(
                    for:
                        result.activity
                )


            if
                let currentFamily,
                usedFamilies.contains(
                    currentFamily
                )
            {

                /*
                 إذا نفس العائلة مستخدمة،
                 نجرب نخلي المودل ينتقل لعائلة مختلفة.

                 لكن ما نعتمد على هذا إلى الأبد،
                 لأن عندنا fallback لاحقًا ولا نريد Error.
                 */

                lastRejectedActivity =
                    result.activity

                lastRejectionReason =
                    """
                    This activity belongs to the already-used family:

                    \(currentFamily)

                    Choose a different activity family.
                    """

                continue
            }


            // MARK: Remember Successful Suggestion

            rememberSuggestion(
                result.activity,
                for:
                    contextKey
            )


            // MARK: Success

            return result
        }


        // ==================================================
        // MARK: - SAFE FALLBACK
        // ==================================================

        /*
         إذا Apple Intelligence فشل في كل المحاولات،
         لا نرسل duplicateSuggestion للواجهة.

         نختار نشاطًا آمنًا ومختلفًا قدر الإمكان.
         */

        let fallback =
            makeFallbackSuggestion(
                category:
                    category,
                energy:
                    energy,
                availableTime:
                    availableTime,
                location:
                    location,
                previousSuggestions:
                    allPreviousSuggestions
            )


        rememberSuggestion(
            fallback.activity,
            for:
                contextKey
        )


        return fallback
    }


    // ==================================================
    // MARK: - Safe Fallback Generator
    // ==================================================

    private func makeFallbackSuggestion(
        category: SuggestionCategory,
        energy: EnergyLevel,
        availableTime: AvailableTime,
        location: UserLocation,
        previousSuggestions: [String]
    ) -> GeneratedSuggestion {

        let categoryName =
            category.title
                .replacingOccurrences(
                    of: "\n",
                    with: " "
                )
                .lowercased()


        let locationName =
            location.title
                .lowercased()


        var candidates:
            [(text: String, minutes: Int, difficulty: String)]
            =
            []


        // MARK: Calm Fallbacks

        let calmCandidates:
            [(String, Int, String)] =
            [
                (
                    "Let your eyes rest on one nearby object and quietly notice its shape for a few seconds.",
                    1,
                    "Very Easy"
                ),
                (
                    "Take one slow, comfortable breath and let it end naturally.",
                    1,
                    "Very Easy"
                ),
                (
                    "Notice one quiet sound around you for a short moment.",
                    1,
                    "Very Easy"
                ),
                (
                    "If you'd like, write down one short thought and leave it there.",
                    2,
                    "Very Easy"
                ),
                (
                    "Take a quiet moment to notice the feeling of your feet resting where they are.",
                    1,
                    "Very Easy"
                ),
                (
                    "Let your shoulders soften for a brief moment, without needing to stretch further.",
                    1,
                    "Very Easy"
                )
            ]


        // MARK: Gentle Connection Fallbacks

        var connectionCandidates:
            [(String, Int, String)] =
            [
                (
                    "Send one simple emoji to someone you already know.",
                    1,
                    "Very Easy"
                ),
                (
                    "Send a short hello message to someone you feel comfortable with.",
                    1,
                    "Very Easy"
                ),
                (
                    "Reply to one existing message with a brief acknowledgment.",
                    1,
                    "Very Easy"
                ),
                (
                    "Send one brief thank-you message to someone you know.",
                    1,
                    "Very Easy"
                ),
                (
                    "Share one simple photo or meme with someone you already know.",
                    2,
                    "Easy"
                )
            ]


        if locationName.contains("work") {

            connectionCandidates.append(
                (
                    "If someone familiar passes nearby, a brief nod is enough.",
                    1,
                    "Very Easy"
                )
            )

        } else {

            connectionCandidates.append(
                (
                    "If someone familiar is nearby, a small wave is enough.",
                    1,
                    "Very Easy"
                )
            )
        }


        // MARK: Light Movement Fallbacks

        let movementCandidates:
            [(String, Int, String)] =
            [
                (
                    "Slowly roll your shoulders once and let them rest again.",
                    1,
                    "Very Easy"
                ),
                (
                    "Gently stretch your fingers open, then let your hands relax.",
                    1,
                    "Very Easy"
                ),
                (
                    "Take a few easy steps around your current space, then stop whenever you like.",
                    2,
                    "Very Easy"
                ),
                (
                    "Gently reach your arms forward for a moment, then let them rest.",
                    1,
                    "Very Easy"
                ),
                (
                    "Slowly shift your weight from one foot to the other for a few seconds.",
                    1,
                    "Very Easy"
                ),
                (
                    "Make one small, comfortable shoulder circle and let your arms rest again.",
                    1,
                    "Very Easy"
                )
            ]


        // MARK: Choose Candidate Set

        if categoryName.contains("calm") {

            candidates =
                calmCandidates

        } else if
            categoryName.contains(
                "gentle connection"
            )
        {

            candidates =
                connectionCandidates

        } else if
            categoryName.contains(
                "light movement"
            )
        {

            candidates =
                movementCandidates

        } else {

            /*
             Not Sure:

             نخلط الأنواع بدل ما يكون Calm دائمًا.
             */

            candidates =
                calmCandidates
                +
                connectionCandidates
                +
                movementCandidates
        }


        // MARK: Find New Candidate

        for candidate in candidates {

            let duplicate =
                previousSuggestions
                    .contains {
                        previous in

                        isTooSimilar(
                            candidate.text,
                            previous
                        )
                    }


            let candidateFamily =
                activityFamily(
                    for:
                        candidate.text
                )


            let previousFamilies =
                Set(
                    previousSuggestions
                        .compactMap {
                            activityFamily(
                                for:
                                    $0
                            )
                        }
                )


            let familyAlreadyUsed =
                candidateFamily
                    .map {
                        previousFamilies
                            .contains(
                                $0
                            )
                    }
                ??
                false


            if
                !duplicate
                &&
                !familyAlreadyUsed
            {

                return makeSafeResult(
                    text:
                        candidate.text,
                    minutes:
                        candidate.minutes,
                    difficulty:
                        candidate.difficulty,
                    energy:
                        energy,
                    availableTime:
                        availableTime
                )
            }
        }


        // MARK: Second Pass

        /*
         إذا كل العائلات استُخدمت،
         نسمح بعائلة مستخدمة لكن نمنع
         النص نفسه أو النص الشبيه جدًا.

         بهذه الطريقة Another Idea
         لا يتوقف بخطأ.
         */

        for candidate in candidates {

            let duplicate =
                previousSuggestions
                    .contains {
                        previous in

                        isTooSimilar(
                            candidate.text,
                            previous
                        )
                    }


            if !duplicate {

                return makeSafeResult(
                    text:
                        candidate.text,
                    minutes:
                        candidate.minutes,
                    difficulty:
                        candidate.difficulty,
                    energy:
                        energy,
                    availableTime:
                        availableTime
                )
            }
        }


        // MARK: Absolute Last Resort

        let lastResort:
            (String, Int, String)


        if categoryName.contains("calm") {

            lastResort =
                (
                    "Take one quiet moment to notice a neutral detail in the space around you.",
                    1,
                    "Very Easy"
                )

        } else if
            categoryName.contains(
                "gentle connection"
            )
        {

            lastResort =
                (
                    "Send one brief acknowledgment to someone you already know.",
                    1,
                    "Very Easy"
                )

        } else if
            categoryName.contains(
                "light movement"
            )
        {

            lastResort =
                (
                    "Make one small, comfortable movement with your shoulders or hands.",
                    1,
                    "Very Easy"
                )

        } else {

            lastResort =
                (
                    "Take one quiet moment to notice something neutral around you.",
                    1,
                    "Very Easy"
                )
        }


        return makeSafeResult(
            text:
                lastResort.0,
            minutes:
                lastResort.1,
            difficulty:
                lastResort.2,
            energy:
                energy,
            availableTime:
                availableTime
        )
    }


    // MARK: - Make Safe Result

    private func makeSafeResult(
        text: String,
        minutes: Int,
        difficulty: String,
        energy: EnergyLevel,
        availableTime: AvailableTime
    ) -> GeneratedSuggestion {

        let maxMinutes =
            maximumMinutes(
                for:
                    availableTime
            )


        var safeMinutes =
            min(
                max(
                    minutes,
                    1
                ),
                maxMinutes
            )


        if energy == .veryLow {

            safeMinutes =
                min(
                    safeMinutes,
                    3
                )
        }


        if energy == .low {

            safeMinutes =
                min(
                    safeMinutes,
                    5
                )
        }


        let safeDifficulty:
            String


        switch energy {

        case .veryLow:

            safeDifficulty =
                "Very Easy"

        case .low:

            safeDifficulty =
                difficulty == "Moderate"
                ? "Easy"
                : difficulty

        case .medium,
             .high:

            safeDifficulty =
                difficulty
        }


        return GeneratedSuggestion(
            activity:
                text,
            estimatedMinutes:
                safeMinutes,
            difficulty:
                safeDifficulty
        )
    }


    // ==================================================
    // MARK: - Remember Suggestion
    // ==================================================

    private func rememberSuggestion(
        _ suggestion: String,
        for contextKey: String
    ) {

        var stored =
            generatedSuggestionsByContext[
                contextKey
            ]
            ??
            []


        let normalized =
            normalize(
                suggestion
            )


        let exists =
            stored.contains {
                normalize($0)
                ==
                normalized
            }


        if !exists {

            stored.append(
                suggestion
            )
        }


        /*
         ما نحتاج نخزن مئات الاقتراحات.
         نخلي آخر 20 فقط.
         */

        if stored.count > 20 {

            stored =
                Array(
                    stored
                        .suffix(20)
                )
        }


        generatedSuggestionsByContext[
            contextKey
        ] =
            stored
    }


    // ==================================================
    // MARK: - Merge Unique Suggestions
    // ==================================================

    private func mergeUniqueSuggestions(
        _ suggestions: [String]
    ) -> [String] {

        var result:
            [String] = []

        var seen:
            Set<String> = []


        for suggestion in suggestions {

            let normalized =
                normalize(
                    suggestion
                )


            guard
                !normalized.isEmpty
            else {

                continue
            }


            if
                !seen.contains(
                    normalized
                )
            {

                seen.insert(
                    normalized
                )

                result.append(
                    suggestion
                )
            }
        }


        return result
    }


    // ==================================================
    // MARK: - Available Time Limit
    // ==================================================

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


    // ==================================================
    // MARK: - Fallback Difficulty
    // ==================================================

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


    // ==================================================
    // MARK: - Clean Activity Text
    // ==================================================

    private func cleanActivityText(
        _ text: String
    ) -> String {

        text
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )
            .replacingOccurrences(
                of:
                    "  ",
                with:
                    " "
            )
    }


    // ==================================================
    // MARK: - Normalize Text
    // ==================================================

    private func normalize(
        _ text: String
    ) -> String {

        text
            .lowercased()
            .components(
                separatedBy:
                    .whitespacesAndNewlines
            )
            .filter {
                !$0.isEmpty
            }
            .joined(
                separator:
                    " "
            )
            .trimmingCharacters(
                in:
                    .punctuationCharacters
            )
    }


    // ==================================================
    // MARK: - Semantic Similarity
    // ==================================================

    private func isTooSimilar(
        _ first: String,
        _ second: String
    ) -> Bool {

        let firstNormalized =
            normalize(
                first
            )

        let secondNormalized =
            normalize(
                second
            )


        // MARK: Exact Match

        if firstNormalized
            ==
            secondNormalized
        {

            return true
        }


        // MARK: Same Activity Family

        let firstFamily =
            activityFamily(
                for:
                    first
            )


        let secondFamily =
            activityFamily(
                for:
                    second
            )


        if
            let firstFamily,
            let secondFamily,
            firstFamily
            ==
            secondFamily
        {

            return true
        }


        // MARK: Meaningful Words

        let ignoredWords:
            Set<String> =
            [
                "a",
                "an",
                "the",
                "to",
                "of",
                "and",
                "or",
                "for",
                "with",
                "in",
                "on",
                "at",
                "is",
                "it",
                "this",
                "that",
                "your",
                "you",
                "you're",
                "youre",
                "can",
                "could",
                "would",
                "just",
                "take",
                "moment",
                "brief",
                "quick",
                "small",
                "simple",
                "gentle",
                "little",
                "if",
                "feels",
                "manageable",
                "enough",
                "now",
                "one",
                "some",
                "something",
                "someone",
                "nearby"
            ]


        let firstWords =
            Set(
                firstNormalized
                    .split(
                        separator:
                            " "
                    )
                    .map {
                        String($0)
                    }
                    .filter {
                        !ignoredWords
                            .contains(
                                $0
                            )
                    }
            )


        let secondWords =
            Set(
                secondNormalized
                    .split(
                        separator:
                            " "
                    )
                    .map {
                        String($0)
                    }
                    .filter {
                        !ignoredWords
                            .contains(
                                $0
                            )
                    }
            )


        guard
            !firstWords.isEmpty,
            !secondWords.isEmpty
        else {

            return false
        }


        // MARK: Jaccard Similarity

        let intersection =
            firstWords
                .intersection(
                    secondWords
                )


        let union =
            firstWords
                .union(
                    secondWords
                )


        let similarity =
            Double(
                intersection.count
            )
            /
            Double(
                union.count
            )


        /*
         0.55 بدل 0.60

         لأننا نريد نلقط rephrasing
         بشكل أقوى قليلًا.

         لكن Activity Family هي الحماية الأساسية.
         */

        return similarity
            >=
            0.55
    }


    // ==================================================
    // MARK: - Validate Selected Category
    // ==================================================

    private func matchesSelectedCategory(
        activity: String,
        category: SuggestionCategory
    ) -> Bool {

        let value =
            normalize(
                activity
            )


        let categoryName =
            category.title
                .replacingOccurrences(
                    of:
                        "\n",
                    with:
                        " "
                )
                .lowercased()


        // ==================================================
        // MARK: Calm
        // ==================================================

        if categoryName.contains(
            "calm"
        ) {

            let connectionSignals =
                [
                    "message",
                    "text",
                    "dm",
                    "hello",
                    "hi ",
                    "greet",
                    "coworker",
                    "colleague",
                    "call",
                    "emoji",
                    "reply",
                    "thank",
                    "smile at",
                    "nod to",
                    "wave to",
                    "someone",
                    "another person"
                ]


            let obviousMovementSignals =
                [
                    "walk",
                    "walking",
                    "take a few steps",
                    "march",
                    "mobility",
                    "move around"
                ]


            let hasConnection =
                connectionSignals
                    .contains {
                        value.contains(
                            $0
                        )
                    }


            let hasMovement =
                obviousMovementSignals
                    .contains {
                        value.contains(
                            $0
                        )
                    }


            return
                !hasConnection
                &&
                !hasMovement
        }


        // ==================================================
        // MARK: Gentle Connection
        // ==================================================

        if categoryName.contains(
            "gentle connection"
        ) {

            /*
             أهم تعديل:

             ما عاد يكفي أن النشاط "مو Calm".

             لازم النشاط يحتوي فعل اتصال حقيقي.
             */

            let connectionSignals =
                [
                    "message",
                    "text",
                    "dm",
                    "emoji",
                    "reaction",
                    "reply",
                    "respond",
                    "hello",
                    "say hi",
                    "greet",
                    "greeting",
                    "thank",
                    "thanks",
                    "appreciate",
                    "share",
                    "smile at",
                    "nod to",
                    "wave to",
                    "eye contact",
                    "call",
                    "phone",
                    "facetime",
                    "conversation",
                    "chat",
                    "sit with",
                    "sit beside",
                    "sit near",
                    "someone",
                    "person",
                    "coworker",
                    "colleague",
                    "friend"
                ]


            let forbiddenSoloSignals =
                [
                    "notice a plant",
                    "notice the plant",
                    "notice one object",
                    "look at a plant",
                    "look around your workspace",
                    "observe an object",
                    "deep breath",
                    "breathe slowly",
                    "breathing",
                    "close your eyes",
                    "journal",
                    "write down one thought",
                    "sit quietly",
                    "sit still",
                    "sensory grounding",
                    "listen to calming",
                    "listen quietly",
                    "warm drink",
                    "sip a drink"
                ]


            let hasConnection =
                connectionSignals
                    .contains {
                        value.contains(
                            $0
                        )
                    }


            let isSoloActivity =
                forbiddenSoloSignals
                    .contains {
                        value.contains(
                            $0
                        )
                    }


            return
                hasConnection
                &&
                !isSoloActivity
        }


        // ==================================================
        // MARK: Light Movement
        // ==================================================

        if categoryName.contains(
            "light movement"
        ) {

            let movementSignals =
                [
                    "walk",
                    "walking",
                    "steps",
                    "step ",
                    "stretch",
                    "stretching",
                    "shoulder",
                    "neck",
                    "arm",
                    "arms",
                    "leg",
                    "legs",
                    "stand",
                    "standing",
                    "mobility",
                    "move your",
                    "movement",
                    "shift your weight",
                    "reach"
                ]


            return
                movementSignals
                    .contains {
                        value.contains(
                            $0
                        )
                    }
        }


        // ==================================================
        // MARK: Not Sure
        // ==================================================

        if categoryName.contains(
            "not sure"
        ) {

            return true
        }


        return true
    }


    // ==================================================
    // MARK: - Validate Tone
    // ==================================================

    private func containsDisallowedTone(
        _ text: String
    ) -> Bool {

        let value =
            normalize(
                text
            )


        let disallowedPhrases =
            [
                // Assume feelings

                "if you're feeling overwhelmed",
                "if you are feeling overwhelmed",

                "if you're overwhelmed",
                "if you are overwhelmed",

                "if you're feeling down",
                "if you are feeling down",

                "if you're stressed",
                "if you are stressed",

                "if you're anxious",
                "if you are anxious",

                // Pressure

                "even if you don't feel like it",
                "even if you do not feel like it",

                "push yourself",
                "force yourself",
                "make yourself",

                // Emotional promises

                "feel better",
                "feel a little better",
                "make you feel better",

                "brighten your day",
                "brighten the day",
                "brighten their day",
                "brighten someone's day",

                "improve your mood",
                "lift your mood",
                "boost your mood",

                "help you refocus",
                "help you feel",

                "cheer you up",
                "reduce depression",
                "fix overwhelm"
            ]


        return
            disallowedPhrases
                .contains {
                    value.contains(
                        $0
                    )
                }
    }


    // ==================================================
    // MARK: - Activity Family
    // ==================================================

    private func activityFamily(
        for text: String
    ) -> String? {

        let value =
            normalize(
                text
            )


        // ==================================================
        // MARK: Gentle Connection
        // ==================================================

        /*
         الترتيب مهم.

         الأشياء الأكثر تحديدًا أولًا،
         عشان smile emoji ما ينحسب
         physical smile مثلًا.
         */


        // MARK: Digital Reaction

        if
            value.contains("emoji")
            ||
            value.contains("reaction")
            ||
            value.contains("react to")
            ||
            value.contains("thumbs up")
            ||
            value.contains("thumbs-up")
        {

            return
                "connection_digital_reaction"
        }


        // MARK: Sharing Media

        if
            value.contains("share")
            &&
            (
                value.contains("photo")
                ||
                value.contains("picture")
                ||
                value.contains("meme")
                ||
                value.contains("video")
                ||
                value.contains("link")
            )
        {

            return
                "connection_share"
        }


        // MARK: Reply

        if
            value.contains("reply")
            ||
            value.contains("respond to")
            ||
            value.contains("answer a message")
            ||
            value.contains("acknowledgment")
        {

            return
                "connection_reply"
        }


        // MARK: Gratitude

        if
            value.contains("thank")
            ||
            value.contains("thanks")
            ||
            value.contains("appreciate")
            ||
            value.contains("appreciation")
        {

            return
                "connection_gratitude"
        }


        // MARK: Short Message

        if
            value.contains("message")
            ||
            value.contains("text")
            ||
            value.contains("dm ")
            ||
            value.contains("send a note")
            ||
            value.contains("write a message")
        {

            return
                "connection_message"
        }


        // MARK: Call

        if
            value.contains("call")
            ||
            value.contains("phone")
            ||
            value.contains("facetime")
        {

            return
                "connection_call"
        }


        // MARK: Presence

        if
            value.contains("sit with")
            ||
            value.contains("sit beside")
            ||
            value.contains("sit near")
            ||
            value.contains("spend a moment with")
        {

            return
                "connection_presence"
        }


        // MARK: Conversation

        if
            value.contains("conversation")
            ||
            value.contains("quick chat")
            ||
            value.contains("chat briefly")
            ||
            value.contains("share a thought")
            ||
            value.contains("share one thought")
            ||
            value.contains("say one")
        {

            return
                "connection_conversation"
        }


        // MARK: In-Person Acknowledgment Family

        /*
         هذي كلها عائلة واحدة:

         nod
         smile
         wave
         hello
         hi
         greeting
         good morning
         eye contact

         وهذا يحل التكرار اللي كان ظاهر بالصور.
         */

        if
            value.contains("nod")
            ||
            value.contains("smile")
            ||
            value.contains("wave")
            ||
            value.contains("eye contact")
            ||
            value.contains("acknowledge")
            ||
            value.contains("hello")
            ||
            value.contains("say hi")
            ||
            value.contains("say hello")
            ||
            value.contains("greet")
            ||
            value.contains("greeting")
            ||
            value.contains("good morning")
            ||
            value.contains("good afternoon")
        {

            return
                "connection_in_person_acknowledgement"
        }


        // ==================================================
        // MARK: Calm
        // ==================================================

        // MARK: Breathing

        if
            value.contains("breath")
            ||
            value.contains("breathe")
            ||
            value.contains("breathing")
        {

            return
                "calm_breathing"
        }


        // MARK: Journaling

        if
            value.contains("journal")
            ||
            value.contains("write one")
            ||
            value.contains("write a thought")
            ||
            value.contains("write down")
        {

            return
                "calm_journaling"
        }


        // MARK: Listening

        if
            value.contains("listen")
            ||
            value.contains("music")
            ||
            value.contains("audio")
            ||
            value.contains("sound")
        {

            return
                "calm_listening"
        }


        // MARK: Drink

        if
            value.contains("drink")
            ||
            value.contains("tea")
            ||
            value.contains("coffee")
            ||
            value.contains("sip")
        {

            return
                "calm_drink"
        }


        // MARK: Grounding

        if
            value.contains("grounding")
            ||
            value.contains("sensory")
            ||
            value.contains("five senses")
            ||
            value.contains("texture")
            ||
            value.contains("feeling of your feet")
        {

            return
                "calm_grounding"
        }


        // MARK: Quiet Sitting

        if
            value.contains("sit quietly")
            ||
            value.contains("sit still")
            ||
            value.contains("quiet moment")
        {

            return
                "calm_sitting"
        }


        // MARK: Observation

        if
            value.contains("observe")
            ||
            value.contains("notice")
            ||
            value.contains("look at")
            ||
            value.contains("watch")
            ||
            value.contains("rest your eyes")
        {

            return
                "calm_observation"
        }


        // ==================================================
        // MARK: Light Movement
        // ==================================================

        // MARK: Walking

        if
            value.contains("walk")
            ||
            value.contains("walking")
            ||
            value.contains("take a few steps")
            ||
            value.contains("few easy steps")
        {

            return
                "movement_walk"
        }


        // MARK: Stretch

        if
            value.contains("stretch")
            ||
            value.contains("stretching")
        {

            return
                "movement_stretch"
        }


        // MARK: Shoulders

        if
            value.contains("shoulder")
            &&
            (
                value.contains("move")
                ||
                value.contains("roll")
                ||
                value.contains("circle")
                ||
                value.contains("raise")
                ||
                value.contains("soften")
            )
        {

            return
                "movement_shoulders"
        }


        // MARK: Neck

        if
            value.contains("neck")
            &&
            (
                value.contains("move")
                ||
                value.contains("roll")
                ||
                value.contains("turn")
                ||
                value.contains("tilt")
            )
        {

            return
                "movement_neck"
        }


        // MARK: Arms

        if
            (
                value.contains("arm")
                ||
                value.contains("arms")
            )
            &&
            (
                value.contains("move")
                ||
                value.contains("raise")
                ||
                value.contains("circle")
                ||
                value.contains("reach")
            )
        {

            return
                "movement_arms"
        }


        // MARK: Hands / Fingers

        if
            value.contains("finger")
            ||
            value.contains("fingers")
            ||
            value.contains("hands")
        {

            return
                "movement_hands"
        }


        // MARK: Legs

        if
            (
                value.contains("leg")
                ||
                value.contains("legs")
            )
            &&
            (
                value.contains("move")
                ||
                value.contains("raise")
                ||
                value.contains("extend")
                ||
                value.contains("march")
            )
        {

            return
                "movement_legs"
        }


        // MARK: Standing / Weight Shift

        if
            value.contains("shift your weight")
            ||
            (
                value.contains("stand")
                &&
                (
                    value.contains("move")
                    ||
                    value.contains("shift")
                    ||
                    value.contains("step")
                )
            )
        {

            return
                "movement_standing"
        }


        // MARK: General Mobility

        if
            value.contains("mobility")
            ||
            value.contains("move your body")
            ||
            value.contains("gentle movement")
        {

            return
                "movement_mobility"
        }


        return nil
    }


    // ==================================================
    // MARK: - Build Feedback Context
    // ==================================================

    private func buildFeedbackContext(
        from history:
            [SuggestionActivity]
    ) -> String {

        let completedFeedback =
            history
                .filter {
                    $0.feedback
                    !=
                    nil
                }
                .sorted {
                    $0.createdAt
                    >
                    $1.createdAt
                }


        guard
            !completedFeedback.isEmpty
        else {

            return
                "No previous feedback is available."
        }


        let recentHistory =
            Array(
                completedFeedback
                    .prefix(10)
            )


        return
            recentHistory
                .map {
                    item in

                    """
                    Activity:
                    \(item.activityText)

                    Feedback:
                    \(item.feedback ?? "No feedback")
                    """
                }
                .joined(
                    separator:
                        "\n\n"
                )
    }
}


// MARK: - Errors

enum SuggestionServiceError:
    LocalizedError {

    case modelUnavailable
    case duplicateSuggestion


    var errorDescription:
        String? {

        switch self {

        case .modelUnavailable:

            return
                "Apple Intelligence is not available on this device."

        case .duplicateSuggestion:

            return
                "A suitable different suggestion could not be generated."
        }
    }
}
