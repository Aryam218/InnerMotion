//
//  LoadingPlanView.swift
//  InnerMotion
//
//  Created by sabaalzuqzuq on 22/02/1448 AH.
//

import SwiftUI
import SwiftData

struct LoadingPlanView: View {

    var onComplete: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Current Planning Session

    let sessionID: UUID

    // كل المهام المحفوظة
    @Query private var allUserTasks: [UserTask]

    // كل خطط اليوم
    @Query(
        sort: \DayPlan.createdAt,
        order: .reverse
    )
    private var allDayPlans: [DayPlan]

    // كل الخطط المولدة سابقًا
    @Query private var existingPlannedTasks: [PlannedTask]

    // MARK: - Current Session Data

    // فقط المهام التي أضافها المستخدم في هذه الجلسة
    private var userTasks: [UserTask] {

        allUserTasks
            .filter {
                $0.planningSessionID == sessionID
            }
            .sorted {
                $0.createdAt < $1.createdAt
            }
    }

    // فقط DayPlan الخاص بهذه الجلسة
    private var currentDayPlan: DayPlan? {

        allDayPlans.first {
            $0.planningSessionID == sessionID
        }
    }

    // MARK: - UI State

    @State private var visibleItemCount = 0

    @State private var progress: CGFloat = 0

    // الخطة الجديدة الناتجة من AI
    @State private var generatedTasks: [PlannedTask] = []

    // التنقل
    @State private var goToSingleTask = false

    @State private var goToMultipleTasks = false

    // يمنع تشغيل AI أكثر من مرة
    @State private var hasStartedGenerating = false

    // رسالة الخطأ
    @State private var errorMessage: String? = nil

    // MARK: - Loading Content

    private let checklistItems = [
        "Prioritizing them based on importance",
        "Considering your available time and energy",
        "Breaking them into small, manageable steps",
        "Creating a plan tailored for you"
    ]

    // MARK: - Colors

    private let primary = Color(
        red: 0.471,
        green: 0.392,
        blue: 0.533
    )

    private let pageBackground = Color(
        red: 0.996,
        green: 0.969,
        blue: 0.945
    )

    private let trackBackground = Color(
        red: 0.910,
        green: 0.867,
        blue: 0.965
    )

    private let checkCircleBackground =
        Color.black.opacity(0.06)

    var body: some View {

        ZStack {

            pageBackground
                .ignoresSafeArea()

            GeometryReader { screen in

                ScrollView {

                    VStack(spacing: 0) {

                        // MARK: - Top Bar

                        HStack {

                            Button {

                                dismiss()

                            } label: {

                                Image(
                                    systemName: "chevron.left"
                                )
                                .font(
                                    .system(
                                        size: 20,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(
                                    primary
                                )
                            }

                            Spacer()
                        }
                        .padding(
                            .horizontal,
                            24
                        )
                        .padding(
                            .top,
                            16
                        )

                        // MARK: - Robot

                        Image("robotIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 350,
                                height: 350
                            )
                            .background(

                                Circle()
                                    .fill(
                                        Color.black
                                            .opacity(0.03)
                                    )
                                    .frame(
                                        width: 210,
                                        height: 210
                                    )
                            )

                        Text(
                            "Understanding your tasks...."
                        )
                        .font(
                            .system(
                                size: 20,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            primary
                        )
                        .padding(
                            .top,
                            28
                        )

                        // MARK: - Checklist

                        VStack(
                            alignment: .leading,
                            spacing: 18
                        ) {

                            ForEach(
                                Array(
                                    checklistItems.enumerated()
                                ),
                                id: \.offset
                            ) { index, item in

                                HStack(
                                    alignment: .top,
                                    spacing: 14
                                ) {

                                    ZStack {

                                        Circle()
                                            .fill(
                                                checkCircleBackground
                                            )
                                            .frame(
                                                width: 28,
                                                height: 28
                                            )

                                        Image(
                                            systemName:
                                                "checkmark"
                                        )
                                        .font(
                                            .system(
                                                size: 12,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundStyle(
                                            primary
                                        )
                                    }

                                    // MARK: - Checklist Text

                                    Text(item)
                                        .font(
                                            .system(
                                                size: 16
                                            )
                                        )
                                        .foregroundStyle(
                                            primary
                                        )
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
                                        )
                                        .offset(
                                            y:
                                                index == checklistItems.count - 1
                                                ? 5
                                                : 0
                                        )

                                    Spacer()
                                }
                                .opacity(
                                    visibleItemCount > index
                                    ? 1
                                    : 0
                                )
                                .offset(
                                    y:
                                        visibleItemCount > index
                                        ? 0
                                        : 8
                                )
                            }
                        }
                        .padding(
                            .top,
                            36
                        )
                        .padding(
                            .horizontal,
                            32
                        )

                        Spacer(
                            minLength: 40
                        )

                        // MARK: - Progress

                        VStack(
                            spacing: 14
                        ) {

                            GeometryReader { geo in

                                ZStack(
                                    alignment: .leading
                                ) {

                                    Capsule()
                                        .fill(
                                            trackBackground
                                        )
                                        .frame(
                                            height: 6
                                        )

                                    Capsule()
                                        .fill(
                                            primary
                                        )
                                        .frame(
                                            width:
                                                geo.size.width
                                                * progress,
                                            height: 6
                                        )
                                }
                            }
                            .frame(
                                height: 6
                            )

                            if let errorMessage {

                                Text(
                                    errorMessage
                                )
                                .font(
                                    .system(
                                        size: 13
                                    )
                                )
                                .foregroundStyle(
                                    .red
                                )
                                .multilineTextAlignment(
                                    .center
                                )

                            } else {

                                Text(
                                    "Preparing your plan..."
                                )
                                .font(
                                    .system(
                                        size: 14
                                    )
                                )
                                .foregroundStyle(
                                    .gray
                                )
                            }
                        }
                        .padding(
                            .horizontal,
                            32
                        )
                        .padding(
                            .bottom,
                            40
                        )
                    }
                    .frame(
                        minHeight:
                            screen.size.height
                    )
                }
            }
        }

        // MARK: - Start AI

        .task {

            guard !hasStartedGenerating else {
                return
            }

            hasStartedGenerating = true

            runVisualSequence()

            await generatePlan()
        }

        // MARK: - Single Task Navigation

        .navigationDestination(
            isPresented: $goToSingleTask
        ) {

            if let task = generatedTasks.first {

                PlanOneTask(
                    task: task
                )
            }
        }

        // MARK: - Multiple Tasks Navigation

        .navigationDestination(
            isPresented: $goToMultipleTasks
        ) {

            MultipleTaks(
                tasks: generatedTasks
            )
        }

        .navigationBarHidden(true)
    }

    // MARK: - Visual Loading Animation

    private func runVisualSequence() {

        for index in 0..<checklistItems.count {

            DispatchQueue.main.asyncAfter(
                deadline:
                    .now()
                    + Double(index) * 0.6
            ) {

                withAnimation(
                    .easeOut(
                        duration: 0.4
                    )
                ) {

                    visibleItemCount = index + 1
                }
            }
        }
    }

    // MARK: - Generate AI Plan

    @MainActor
    private func generatePlan() async {

        // فقط مهام الجلسة الحالية
        guard !userTasks.isEmpty else {

            errorMessage =
                "No tasks were found for this planning session."

            return
        }

        // فقط Energy + Time الخاصة بنفس الجلسة
        guard let currentDayPlan else {

            errorMessage =
                "No day plan was found for this planning session."

            return
        }

        do {

            // MARK: - Generate With AI

            let result =
                try await
                TaskPlanningService
                    .shared
                    .generatePlan(
                        tasks: userTasks,
                        dayPlan: currentDayPlan
                    )

            // كل UserTask لازم تنتج PlannedTask واحدة
            guard result.tasks.count == userTasks.count else {

                errorMessage =
                    "The generated plan does not match the original tasks."

                return
            }

            // MARK: - Delete Previous Plan
            // For Current Session Only

            for plannedTask in existingPlannedTasks
            where plannedTask.planningSessionID == sessionID {

                modelContext.delete(
                    plannedTask
                )
            }

            // MARK: - Build New Planned Tasks

            var newPlannedTasks: [PlannedTask] = []

            for (
                taskIndex,
                generatedTask
            ) in result.tasks.enumerated() {

                // المهمة الأصلية المقابلة لرد AI
                let originalTask =
                    userTasks[taskIndex]

                // MARK: - Build Steps

                let generatedSteps =
                    generatedTask.steps
                        .enumerated()
                        .map {
                            stepIndex,
                            generatedStep in

                            TaskStep(
                                order:
                                    stepIndex + 1,

                                text:
                                    generatedStep.text,

                                estimatedMinutes:
                                    generatedStep.estimatedMinutes,

                                isCompleted:
                                    false
                            )
                        }

                // MARK: - Build Planned Task

                let plannedTask =
                    PlannedTask(

                        // عنوان المستخدم الأصلي
                        title:
                            originalTask.title,

                        // Priority الأصلية
                        priority:
                            originalTask.priority,

                        // Due Date الأصلية
                        dueDate:
                            originalTask.dueDate,

                        // ترتيب المهمة
                        order:
                            taskIndex + 1,

                        // نفس جلسة التخطيط
                        planningSessionID:
                            sessionID,

                        // خطوات AI
                        steps:
                            generatedSteps
                    )

                modelContext.insert(
                    plannedTask
                )

                newPlannedTasks.append(
                    plannedTask
                )
            }

            // MARK: - Save Generated Plan

            try modelContext.save()

            // MARK: - Mark User Tasks As Planned

            for userTask in userTasks {

                userTask.isPlanned = true
            }

            try modelContext.save()

            // MARK: - Store Generated Tasks

            generatedTasks =
                newPlannedTasks.sorted {

                    $0.order < $1.order
                }

            // MARK: - Finish Loading Animation

            withAnimation(
                .easeInOut(
                    duration: 0.8
                )
            ) {

                progress = 1.0

                visibleItemCount =
                    checklistItems.count
            }

            // نخلي المستخدم يشوف اكتمال الشريط

            try? await Task.sleep(
                for:
                    .milliseconds(850)
            )

            onComplete()

            // MARK: - Navigation Decision

            if userTasks.count == 1 {

                goToSingleTask = true

            } else if userTasks.count > 1 {

                goToMultipleTasks = true
            }

        } catch {

            print("========== AI ERROR ==========")
            print("Error: \(error)")
            print("Type: \(type(of: error))")
            print(
                "Description: \(error.localizedDescription)"
            )
            print(
                "NSError: \(error as NSError)"
            )
            print("==============================")

            errorMessage =
                "We couldn’t create your plan right now. Please try again."
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        LoadingPlanView(
            sessionID: UUID()
        )
    }
    .modelContainer(
        for: [
            UserTask.self,
            DayPlan.self,
            PlannedTask.self,
            TaskStep.self
        ],
        inMemory: true
    )
}
