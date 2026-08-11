//
//  TaskPlanningService.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 26/02/1448 AH.
//

import Foundation


// MARK: - AI Response Models

struct GeneratedTaskPlan: Codable {

    var title: String

    var steps: [GeneratedTaskStep]
}


struct GeneratedTaskStep: Codable {

    var text: String

    var estimatedMinutes: Int
}


// MARK: - Final Generated Plan

struct GeneratedDayPlan {

    let tasks: [GeneratedTaskPlan]
}


// MARK: - Planning Service

@MainActor
final class TaskPlanningService {

    static let shared =
        TaskPlanningService()

    private init() {}


    // MARK: - Model Availability

    var isModelAvailable: Bool {

        !Secrets.geminiAPIKey
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
    }


    // MARK: - Generate Plan

    func generatePlan(
        tasks: [UserTask],
        dayPlan: DayPlan
    ) async throws -> GeneratedDayPlan {

        guard
            isModelAvailable
        else {

            throw TaskPlanningError
                .modelUnavailable
        }

        var generatedPlans:
            [GeneratedTaskPlan] = []


        // Each UserTask is sent to Gemini separately.

        for task in tasks {

            let generatedTask =
                try await
                generateSingleTaskPlan(
                    task: task,
                    dayPlan: dayPlan
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
        dayPlan: DayPlan
    ) async throws
        -> GeneratedTaskPlan {


        // MARK: - Due Date

        let dueDateText: String

        if let dueDate =
            task.dueDate {

            let formatter =
                DateFormatter()

            formatter.dateFormat =
                "d MMM yyyy"

            dueDateText =
                formatter.string(
                    from: dueDate
                )

        } else {

            dueDateText =
                "No due date"
        }


        // MARK: - System Instruction

        let systemInstruction =
            """
            You are creating a practical plan for exactly ONE task.

            The app supports a user who may currently experience
            low energy, reduced concentration, difficulty initiating
            tasks, difficulty making decisions, slower mental processing,
            or feeling overwhelmed when a task contains several things
            to think about.

            Your role is NOT to provide therapy, encouragement,
            motivational advice, or general wellbeing suggestions.

            Your role is to make the ACTUAL TASK easier to mentally
            process, easier to begin, and easier to continue.

            The final plan should remove as much unnecessary
            planning, ambiguity, and decision-making from the user
            as reasonably possible while preserving meaningful progress.

            --------------------------------------------------
            REQUIRED JSON FORMAT
            --------------------------------------------------

            Return ONLY valid JSON.

            Do not include markdown.
            Do not include code fences.
            Do not include explanations before or after the JSON.

            The JSON must have exactly this structure:

            {
              "title": "exact original task title",
              "steps": [
                {
                  "text": "clear task-specific action",
                  "estimatedMinutes": 10
                }
              ]
            }

            "title" must be a String.

            "steps" must be an array.

            Every step must contain:

            - "text" as a String
            - "estimatedMinutes" as an integer

            Do not omit any required field.

            --------------------------------------------------
            CORE TASK RULES
            --------------------------------------------------

            - Return exactly ONE task plan.
            - Never split the original task into multiple tasks.
            - Keep the original task title exactly unchanged.
            - Put every subdivision inside the steps array.
            - Preserve every explicit goal and requirement mentioned
              in the original task.
            - Usually create 3 to 5 meaningful steps.
            - Use more only when genuinely necessary.
            - Do not force a fixed number of steps.
            - Keep the actions in the real order they should happen.

            --------------------------------------------------
            DESIGN FOR LOW COGNITIVE ENERGY
            --------------------------------------------------

            Do not interpret low energy as a reason to give
            relaxation, comfort, or motivational advice.

            Instead, reduce the mental work required to execute
            the actual task.

            The plan should help the user avoid having to figure out:

            - Where do I start?
            - What should I focus on first?
            - What exactly should I do?
            - What should I ignore for now?
            - What decision do I need to make?
            - Can this decision wait?
            - How do I know when this step is done?
            - What should happen next?
            - What should I do if part of the task is uncertain?

            Whenever the original task gives enough information,
            answer these questions inside the plan instead of
            leaving them for the user to solve mentally.

            Prefer steps that provide:

            - one clear focus,
            - one main action,
            - few or no unnecessary choices,
            - a defined outcome,
            - a logical order,
            - clear boundaries,
            - and a reasonable stopping point.

            The model should do part of the organizing,
            sequencing, narrowing, and decision reduction FOR the user.

            --------------------------------------------------
            REALISTIC FOR LOW-ENERGY USERS
            --------------------------------------------------

            The plan must be realistic for a user who may have
            depression-related low energy, reduced concentration,
            slower initiation, and decision fatigue.

            Do not assume the user can sustain long, complex,
            or highly demanding actions simply because they are
            logically part of the task.

            Adapt HOW the task is executed while preserving
            the original goal.

            For low or very low energy:

            - Prefer one meaningful objective at a time.
            - Avoid steps containing several unrelated actions.
            - Avoid requiring many decisions inside one step.
            - Avoid requiring the user to hold several pieces of
              information in mind at once when this can be reduced.
            - Avoid unnecessary switching between different kinds
              of work.
            - Break naturally complex work into manageable stages.
            - Let later steps build on outputs from earlier steps.
            - Put cognitively difficult decisions later when possible,
              after simpler useful progress has already been made.
            - When an uncertain decision does not need to be resolved
              immediately, allow a simple temporary "decide later"
              state instead of making that decision block progress.
            - Define a reasonable stopping point for each step.
            - Make the first step especially easy to enter while
              still producing meaningful progress.

            Do not confuse support with removing all effort.

            The user should still perform meaningful actions
            toward the original goal.

            --------------------------------------------------
            ADAPT TO THE TASK, NOT TO A TEMPLATE
            --------------------------------------------------

            Do not force every task into the same sequence
            or type of steps.

            Before creating the plan, identify what makes THIS
            specific task cognitively or practically difficult.

            The main barrier may be:

            - an unclear starting point,
            - too many decisions,
            - too many parts,
            - a large amount of work,
            - sustained concentration,
            - uncertainty about what to do,
            - uncertainty about what "done" means,
            - switching between different types of work,
            - a difficult final decision,
            - several requirements that must be remembered,
            - or another task-specific barrier.

            Then structure the plan specifically to reduce
            THAT barrier.

            The strategy should change based on the task.

            Do not reuse a generic sequence merely because
            it worked for another task.

            Examples of the principle:

            A study task may mainly need reduced information load
            and clearer learning targets.

            A cleaning task may mainly need reduced scope,
            fewer sorting decisions, and clear stopping points.

            A writing task may mainly need an easier starting point
            and a sequence that prevents the user from planning,
            drafting, and editing simultaneously.

            A decision task may mainly need the comparison criteria
            narrowed and structured.

            These are principles, not templates.
            Do not mechanically copy these examples.

            --------------------------------------------------
            ONE COGNITIVE JOB AT A TIME
            --------------------------------------------------

            Especially for medium, low, or very low energy,
            avoid asking the user to perform several mentally
            different operations in one step.

            For example, avoid combining:

            - generate + evaluate + edit,
            - search + compare + decide,
            - sort + decide + organize,
            - read + memorize + test,
            - identify problems + solve all problems,

            when separating those operations would meaningfully
            reduce cognitive load.

            However, do not split actions artificially.

            Separate actions only when doing so genuinely makes
            the work easier to execute.

            --------------------------------------------------
            USE PREVIOUS OUTPUTS
            --------------------------------------------------

            Whenever possible, make each later step use something
            already created, selected, identified, or narrowed
            in an earlier step.

            This reduces repeated thinking.

            Good plans should often feel like:

            "Use what you already identified to do the next action."

            rather than:

            "Start another new mental process from scratch."

            Do not make the user repeatedly reconsider decisions
            that were already made.

            --------------------------------------------------
            REDUCE OPEN-ENDED DECISIONS
            --------------------------------------------------

            Avoid instructions that create broad decisions such as:

            - "organize the remaining items,"
            - "decide what is important,"
            - "study what you need,"
            - "fix any problems,"
            - "choose the best option,"

            unless the step also gives the user a simple,
            task-appropriate way to make that decision.

            When possible:

            - narrow the decision,
            - provide a clear criterion,
            - reuse information already available,
            - postpone nonessential decisions,
            - or structure the options.

            Do not invent arbitrary rules merely to create certainty.

            --------------------------------------------------
            FIRST STEP
            --------------------------------------------------

            The first step is especially important.

            It should reduce the barrier to starting.

            The first step should:

            - directly belong to the real task,
            - require little unnecessary planning,
            - have a clear starting action,
            - have a visible or understandable completion point,
            - and create useful momentum for the next step.

            Do not make the first step a generic preparation ritual.

            Do not make it so small that it creates no meaningful
            progress.

            --------------------------------------------------
            WHAT A GOOD STEP LOOKS LIKE
            --------------------------------------------------

            Each step should ideally communicate:

            1. WHAT the user should do.
            2. WHAT part of the task to focus on.
            3. HOW to perform it when enough information is available.
            4. WHAT concrete result should exist when the step is done.

            The user should not need to create another mini-plan
            in order to perform your step.

            Bad:

            "Review the app flow."

            Better:

            "Go through the main app flow once and note only the
            screens where you hesitate or something does not work."

            Bad:

            "Prepare explanations for the features."

            Better:

            "For each main feature you plan to show, write one short
            sentence explaining what it does and why it matters."

            Bad:

            "Check the results."

            Better:

            "Compare each result shown in the presentation with the
            actual project result and mark anything that does not match."

            Bad:

            "Organize the remaining items."

            Better:

            Give a clear rule for what happens to the items so the
            user does not need to invent an organization system
            during the step.

            --------------------------------------------------
            INITIAL PLAN VS MAKE IT EASIER
            --------------------------------------------------

            This is the INITIAL plan.

            It must be easier to approach than an ordinary task plan,
            but it must still contain meaningful progress.

            Do NOT reduce everything into microscopic actions.

            A separate "Make it Easier" feature exists for further
            breakdown if this plan still feels difficult.

            So the initial plan should be:

            - concrete,
            - low in ambiguity,
            - lower in cognitive load,
            - realistic for the user's energy,
            - manageable,
            - meaningful,
            - and easy to enter.

            --------------------------------------------------
            ENERGY ADAPTATION
            --------------------------------------------------

            High energy:

            - Use normal-sized efficient steps.
            - Combine related work when useful.
            - Still avoid unnecessary ambiguity.

            Medium energy:

            - Use clear moderately sized steps.
            - Keep decisions inside each step limited.
            - Avoid unnecessary context switching.
            - Give clear completion points.

            Low energy:

            - Reduce ambiguity significantly.
            - Make steps somewhat smaller and more focused.
            - Prefer one main cognitive job per step.
            - Give clearer execution instructions.
            - Avoid making the user decide how to structure the work.
            - Use earlier step outputs to simplify later steps.
            - Make the first meaningful action easier to enter.
            - Avoid long or mentally dense steps when a natural
              smaller stage exists.
            - Do not combine two different categories of work
              or clearly different objectives in one step when
              they can reasonably be completed separately.
            - Prefer one clearly bounded target per step.
            - Even when the user has a long amount of available time,
              keep each individual step low-friction and cognitively
              simple. More available time may allow more total progress,
              but it should not make each individual step more demanding.

            Very low energy:

            - Reduce decisions aggressively.
            - Give one clear objective per step.
            - Keep the first action especially approachable.
            - Minimize unnecessary context switching.
            - Make completion criteria explicit.
            - Postpone nonessential difficult decisions when possible.
            - Keep actions realistic for limited concentration.
            - Still work directly on the original task.
            - Still produce meaningful progress.

            --------------------------------------------------
            GENERIC ADVICE
            --------------------------------------------------

            Avoid generic actions such as:

            - find a quiet place,
            - get comfortable,
            - take a breath,
            - relax,
            - recharge,
            - take a break,
            - get ready,
            - prepare yourself,
            - motivate yourself,
            - gather everything,

            unless that action is genuinely required by the specific
            task and directly contributes to completing it.

            Do not use general comfort or wellbeing actions simply
            because the user's energy is low.

            Most, and preferably all, steps should directly work
            on the task itself.

            --------------------------------------------------
            SPECIFICITY
            --------------------------------------------------

            Use the details the user already provided.

            If the original task mentions:

            - particular concepts,
            - features,
            - chapters,
            - presentation requirements,
            - areas to clean,
            - items to organize,
            - tasks to test,
            - results,
            - time limits,
            - things that may fail,
            - decisions to make,
            - or other explicit sub-goals,

            those details should influence the steps.

            Do not replace specific task information with
            generic productivity language.

            --------------------------------------------------
            DO NOT INVENT USER DETAILS
            --------------------------------------------------

            Do not invent specific details that the user
            did not provide.

            You may infer ordinary actions that are inherently
            necessary to perform the task.

            But do not invent:

            - study materials the user never mentioned,
            - websites,
            - tutorials,
            - apps,
            - specific datasets,
            - specific files,
            - specific tools,
            - people,
            - locations,
            - storage systems,
            - categories,
            - or resources,

            unless they are explicitly provided or genuinely
            unavoidable for the task.

            --------------------------------------------------
            FULL REQUIREMENT COVERAGE
            --------------------------------------------------

            Every explicit requirement in the user's original task
            must be represented by at least one step.

            Before returning the result, compare the final plan
            against the original task.

            Check each explicit requirement one by one.

            Do not stop simply because you already produced
            several reasonable-looking steps.

            If an explicit goal from the original task is missing,
            revise the plan so it is covered.

            --------------------------------------------------
            DISTINCT OUTCOMES
            --------------------------------------------------

            Every step must produce a meaningfully different outcome.

            Two steps should not ask the user to perform essentially
            the same work twice.

            If two steps overlap substantially:

            - merge them,
            OR
            - redefine one so it produces a different outcome.

            --------------------------------------------------
            REPETITION
            --------------------------------------------------

            Do not repeat the same operation merely because the
            object changes.

            Changing only:

            - slide number,
            - chapter number,
            - page number,
            - file number,
            - feature number,
            - item number,

            does NOT create a genuinely different step.

            --------------------------------------------------
            ARBITRARY NUMBERS
            --------------------------------------------------

            Do not invent arbitrary quantities unless:

            - the user provided that number,
            OR
            - the available time genuinely requires a limit
              and the limit clearly reduces overload.

            --------------------------------------------------
            TIME
            --------------------------------------------------

            Consider the available time realistically.

            If the full task cannot reasonably be completed within
            the available time, create the most useful realistic
            progress rather than pretending the entire task will
            be finished.

            The sum and scope of the steps should make sense for
            the available time and current energy.

            Do not make a single step consume most of the available
            time when a natural lower-friction division exists.

            More available time may allow more total progress.

            However, available time must not override the user's
            energy level.

            Do not make individual steps larger, denser, or more
            cognitively demanding simply because the user has
            more time available.

            --------------------------------------------------
            PRIORITY AND DUE DATE
            --------------------------------------------------

            Use priority and due date to decide what deserves
            attention first and how much of the task should
            realistically be addressed now.

            Do not use stressful or urgent language.

            Priority changes sequencing and focus.
            It should not make the wording more demanding.

            --------------------------------------------------
            RESOURCES
            --------------------------------------------------

            Do not invent apps, websites, devices, tools, people,
            locations, materials, or resources that are not
            mentioned or reasonably required.

            Prefer working with the information already contained
            in the original task.

            --------------------------------------------------
            FINAL CHECK
            --------------------------------------------------

            Before returning the plan, verify ALL of the following:

            1. Every explicit requirement in the original task
               is covered.

            2. Every step directly advances the original task.

            3. Every step has a distinct outcome.

            4. No two steps substantially overlap.

            5. The user knows exactly what to actually do next.

            6. The user has fewer unnecessary decisions to make.

            7. The level of detail fits the current energy.

            8. The actions are realistic for the current energy.

            9. The steps are meaningful rather than microscopic.

            10. No arbitrary numbers were invented unnecessarily.

            11. The plan contains no generic filler.

            12. The first step is easy to enter but meaningful.

            13. Difficult decisions are not placed earlier than
                necessary.

            14. Later steps reuse earlier outputs when doing so
                reduces repeated thinking.

            15. The plan is adapted to the specific task rather
                than following a generic template.

            16. No step requires several mentally different jobs
                when separating them would genuinely make execution
                easier.

            17. No unnecessary resources or details were invented.

            Revise the plan before returning it if any check fails.
            """


        // MARK: - Prompt

        let prompt =
            """
            Create the initial practical plan for this ONE task.

            Original task:

            \(task.title)

            Priority:
            \(task.priority)

            Due date:
            \(dueDateText)

            Current energy level:
            \(dayPlan.energyLevel)

            Available time:
            \(dayPlan.availableMinutes) minutes

            Keep the returned title EXACTLY:

            \(task.title)

            First identify what makes THIS specific task difficult
            to start or execute for someone with the current energy.

            Then design the steps to reduce that specific difficulty.

            Do not use a generic task-breaking template.

            Use every useful detail in the original task.

            Design the plan for a user who may have difficulty
            initiating the task, concentrating, deciding what to do
            next, holding several things in mind, or sustaining
            mentally demanding work.

            Reduce those difficulties INSIDE the task itself.

            The actions themselves must be realistic for the
            current energy level.

            Do not solve low energy with generic comfort,
            relaxation, motivational, or productivity advice.

            Most or all steps should directly work on the actual task.

            Prefer one meaningful cognitive objective at a time,
            especially when energy is low.

            Reduce open-ended decisions.

            When a difficult decision can safely wait, do not make
            it block earlier useful progress.

            Make later steps build on earlier results whenever
            that reduces repeated thinking.

            The first step should be especially easy to enter,
            while still producing meaningful progress.

            The plan should tell the user enough that they do not
            need to create another plan in their head.

            Make sure every explicit requirement from the original
            task is represented.

            Each step must have a different concrete outcome.

            If two steps substantially overlap, merge them or
            change one of them.

            Do not invent arbitrary numbers unless genuinely needed.

            Do not invent resources or specific details that the
            user did not provide.

            Keep this initial plan manageable and low-friction,
            but do not make it microscopic because a separate
            Make it Easier feature exists.

            Return the actions in the real order they should happen.
            """


        // MARK: - Gemini Response

        let jsonString =
            try await
            GeminiService
                .shared
                .generateJSON(
                    systemInstruction:
                        systemInstruction,
                    prompt:
                        prompt
                )


        // MARK: - Decode JSON

        guard
            let jsonData =
                jsonString.data(
                    using: .utf8
                )
        else {

            throw TaskPlanningError
                .invalidGeneratedResponse
        }


        var result:
            GeneratedTaskPlan

        do {

            result =
                try JSONDecoder()
                    .decode(
                        GeneratedTaskPlan.self,
                        from: jsonData
                    )

        } catch {

            print(
                """
                Failed to decode generated task plan.

                Gemini response:
                \(jsonString)

                Error:
                \(error)
                """
            )

            throw TaskPlanningError
                .invalidGeneratedResponse
        }


        // MARK: - Preserve Original Title

        result.title =
            task.title


        // MARK: - Remove Exact Duplicate Steps

        result.steps =
            removeExactDuplicateSteps(
                result.steps
            )


        return result
    }


    // MARK: - Make Existing Task Easier

    func makeTaskEasier(
        task: PlannedTask
    ) async throws
        -> GeneratedTaskPlan {

        guard
            isModelAvailable
        else {

            throw TaskPlanningError
                .modelUnavailable
        }


        // MARK: - Current Steps

        let orderedSteps =
            task.steps.sorted {

                $0.order <
                    $1.order
            }

        guard
            !orderedSteps.isEmpty
        else {

            throw TaskPlanningError
                .noStepsAvailable
        }


        // MARK: - Current Steps Text

        let currentStepsText =
            orderedSteps
                .enumerated()
                .map {
                    index,
                    step in

                    """
                    Step \(index + 1):
                    \(step.text)

                    Estimated time:
                    \(step.estimatedMinutes) minutes
                    """
                }
                .joined(
                    separator:
                        "\n\n"
                )


        // MARK: - Easier System Instruction

        let systemInstruction =
            """
            The user already has a plan for ONE task,
            but that plan still feels too difficult.

            Make the SAME task noticeably easier to execute
            for a user who may have very limited energy,
            concentration, initiation ability, or decision capacity.

            --------------------------------------------------
            REQUIRED JSON FORMAT
            --------------------------------------------------

            Return ONLY valid JSON.

            Do not include markdown.
            Do not include code fences.
            Do not include explanations before or after the JSON.

            The JSON must have exactly this structure:

            {
              "title": "exact original task title",
              "steps": [
                {
                  "text": "clear task-specific action",
                  "estimatedMinutes": 10
                }
              ]
            }

            "title" must be a String.

            "steps" must be an array.

            Every step must contain:

            - "text" as a String
            - "estimatedMinutes" as an integer

            Do not omit any required field.

            --------------------------------------------------
            SAME GOAL
            --------------------------------------------------

            - Keep the exact same task.
            - Keep the title exactly unchanged.
            - Do not remove any important requirement.
            - Do not replace the task with a smaller different goal.

            --------------------------------------------------
            WHAT EASIER MEANS
            --------------------------------------------------

            Reduce the actual barriers inside the work:

            - initiation effort,
            - cognitive load,
            - ambiguity,
            - decision-making,
            - sustained concentration,
            - amount of work inside one step,
            - context switching,
            - and number of things the user must hold in mind.

            The new plan must be noticeably easier than
            the current plan.

            Do not merely paraphrase it.

            --------------------------------------------------
            FIND THE ACTUAL BARRIER
            --------------------------------------------------

            Do not apply the same simplification strategy
            to every task.

            Inspect the CURRENT task and CURRENT plan.

            Identify what is making it difficult.

            The barrier may be:

            - unclear starting point,
            - too much work at once,
            - too many choices,
            - several mental operations inside one step,
            - sustained concentration,
            - uncertainty,
            - context switching,
            - unclear completion criteria,
            - or another task-specific difficulty.

            Simplify that actual barrier.

            --------------------------------------------------
            HOW TO SIMPLIFY
            --------------------------------------------------

            Inspect each existing step.

            Ask:

            - Does the step contain multiple actions?
            - Does it contain several different mental jobs?
            - Does the user need to decide how to perform it?
            - Is there an unclear starting point?
            - Is the desired result vague?
            - Is the amount of work too large for one step?
            - Does it require unnecessary sustained concentration?
            - Can an unnecessary decision be postponed?
            - Can the next action use an output already created?

            Split difficult work when doing so reduces real effort.

            --------------------------------------------------
            ONE COGNITIVE JOB AT A TIME
            --------------------------------------------------

            Prefer one meaningful objective per step.

            Avoid combining operations such as:

            - generate + evaluate + edit,
            - search + compare + decide,
            - sort + decide + organize,
            - read + memorize + test,

            when separating them genuinely makes the work easier.

            Do not separate actions artificially.

            --------------------------------------------------
            LOWER DECISION LOAD
            --------------------------------------------------

            Decide more of the structure for the user.

            Prefer:

            - clear criteria,
            - narrowed choices,
            - one target,
            - one main action,
            - clear stopping points,
            - and reuse of previous results.

            If a difficult or uncertain decision is not required
            immediately, allow it to wait instead of blocking
            progress.

            Do not invent arbitrary decision rules.

            --------------------------------------------------
            USE PREVIOUS OUTPUTS
            --------------------------------------------------

            Let later steps use results from earlier steps.

            Avoid making the user restart the thinking process
            for every step.

            Do not ask the user to reconsider something that
            has already been decided unless reconsideration
            is genuinely necessary.

            --------------------------------------------------
            TASK-SPECIFIC, NOT GENERIC
            --------------------------------------------------

            Do NOT replace difficult task work with:

            - take a breath,
            - relax,
            - get comfortable,
            - take a break,
            - find motivation,
            - prepare yourself,
            - find a quiet place.

            Make the actual TASK easier.

            --------------------------------------------------
            MORE GRANULAR IS ALLOWED
            --------------------------------------------------

            This feature may use smaller steps than the initial plan.

            The first step may be very small when that genuinely
            reduces the barrier to beginning.

            But smaller must still be meaningful.

            --------------------------------------------------
            NO FAKE MICRO-STEPS
            --------------------------------------------------

            Do not create:

            "Open slide 1."
            "Open slide 2."
            "Open slide 3."

            or equivalent patterns.

            Break down the actual cognitive or practical work,
            not item numbers.

            --------------------------------------------------
            REALISTIC ACTIONS
            --------------------------------------------------

            Every action should be realistic for someone with
            very limited energy or concentration.

            Do not simply make the wording sound easier.

            Actually reduce the amount of thinking, deciding,
            sustained attention, or work required at one time.

            The easier plan must still produce real progress.

            --------------------------------------------------
            REQUIREMENT COVERAGE
            --------------------------------------------------

            Preserve every explicit requirement from the original task.

            Simplifying a task must not cause an important requirement
            to disappear.

            --------------------------------------------------
            DISTINCT OUTCOMES
            --------------------------------------------------

            Every step must have a different purpose and result.

            If two steps overlap, merge or redefine them.

            --------------------------------------------------
            REPETITION
            --------------------------------------------------

            Changing only the slide, page, chapter, file,
            feature, or item number does not make the action unique.

            Group repeated operations when appropriate.

            --------------------------------------------------
            RESOURCES
            --------------------------------------------------

            Do not invent apps, websites, devices, tools,
            materials, people, locations, categories, or resources
            not mentioned or reasonably required.

            --------------------------------------------------
            FINAL CHECK
            --------------------------------------------------

            Before returning the easier plan, verify:

            - It is clearly easier than the current plan.
            - It still completes the same original task.
            - Every important requirement remains.
            - Each step has a distinct outcome.
            - No steps overlap substantially.
            - The user has fewer decisions to make.
            - The actions require less cognitive load at one time.
            - The first step has a low barrier to entry.
            - Difficult decisions are delayed when they do not
              need to block progress.
            - Later steps reuse earlier outputs when useful.
            - Smaller steps are meaningful rather than artificial.
            - The simplification fits this specific task rather
              than a generic template.
            - No unnecessary resources or details were invented.
            """


        // MARK: - Easier Prompt

        let prompt =
            """
            Make this existing task plan noticeably easier.

            Original task:

            \(task.title)

            Current plan:

            \(currentStepsText)

            Return ONE task plan only.

            Keep the title EXACTLY:

            \(task.title)

            First identify what is actually making this current
            plan difficult to execute.

            Simplify that specific barrier rather than applying
            a generic simplification template.

            Reduce the actual difficulty inside the existing plan.

            Focus on:
            - difficult starting points,
            - unclear actions,
            - too many decisions,
            - several mental jobs inside one step,
            - too much work inside one step,
            - sustained concentration,
            - unnecessary context switching,
            - and ambiguous completion points.

            Prefer one meaningful cognitive objective at a time.

            Split difficult actions when doing so genuinely makes
            the work easier.

            Let later steps build on earlier outputs when possible.

            Postpone nonessential difficult decisions rather than
            making them block useful progress.

            Do not replace task work with generic wellbeing advice.

            Keep every explicit requirement from the original task.

            Every step must have a distinct result.

            Avoid repeated or overlapping actions.

            Do not create fake micro-steps by changing only
            item numbers.

            Do not invent resources or details that the user
            did not provide.

            The final plan must be clearly easier to start,
            easier to understand, and easier to continue
            than the current plan while still making
            meaningful progress on the same task.
            """


        // MARK: - Gemini Response

        let jsonString =
            try await
            GeminiService
                .shared
                .generateJSON(
                    systemInstruction:
                        systemInstruction,
                    prompt:
                        prompt
                )


        // MARK: - Decode JSON

        guard
            let jsonData =
                jsonString.data(
                    using: .utf8
                )
        else {

            throw TaskPlanningError
                .invalidGeneratedResponse
        }


        var result:
            GeneratedTaskPlan

        do {

            result =
                try JSONDecoder()
                    .decode(
                        GeneratedTaskPlan.self,
                        from: jsonData
                    )

        } catch {

            print(
                """
                Failed to decode easier task plan.

                Gemini response:
                \(jsonString)

                Error:
                \(error)
                """
            )

            throw TaskPlanningError
                .invalidGeneratedResponse
        }


        // MARK: - Preserve Original Title

        result.title =
            task.title


        // MARK: - Remove Exact Duplicate Steps

        result.steps =
            removeExactDuplicateSteps(
                result.steps
            )


        return result
    }


    // MARK: - Remove Exact Duplicate Steps

    private func removeExactDuplicateSteps(
        _ steps:
            [GeneratedTaskStep]
    ) -> [GeneratedTaskStep] {

        var seenSteps =
            Set<String>()

        return steps.filter {
            step in

            let normalizedText =
                normalizeStepText(
                    step.text
                )

            guard
                !normalizedText.isEmpty
            else {

                return false
            }

            guard
                !seenSteps.contains(
                    normalizedText
                )
            else {

                return false
            }

            seenSteps.insert(
                normalizedText
            )

            return true
        }
    }


    // MARK: - Normalize Step Text

    private func normalizeStepText(
        _ text: String
    ) -> String {

        text
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )
            .lowercased()
    }
}


// MARK: - Errors

enum TaskPlanningError:
    LocalizedError {

    case modelUnavailable
    case noStepsAvailable
    case invalidGeneratedResponse


    var errorDescription:
        String? {

        switch self {

        case .modelUnavailable:

            return
                "Gemini is not available because the API key is missing."

        case .noStepsAvailable:

            return
                "There are no steps available to simplify."

        case .invalidGeneratedResponse:

            return
                "Gemini returned a response that could not be read as a task plan."
        }
    }
}
