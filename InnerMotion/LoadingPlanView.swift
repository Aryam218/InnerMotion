//
//  LoadingPlanView.swift
//  InnerMotion
//
//  Created by sabaalzuqzuq on 22/02/1448 AH.
//


//
//  LoadingPlanView.swift
//  team15
//

import SwiftUI
import SwiftData

struct LoadingPlanView: View {

    var onComplete: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // المهام الأصلية التي كتبها المستخدم
    @Query private var userTasks: [UserTask]

    // خطط اليوم المحفوظة
    @Query(
        sort: \DayPlan.createdAt,
        order: .reverse
    )
    private var dayPlans: [DayPlan]

    // الخطط المولدة سابقًا
    @Query private var existingPlannedTasks: [PlannedTask]

    @State private var visibleItemCount = 0
    @State private var progress: CGFloat = 0

    // الخطة الجديدة الناتجة من AI
    @State private var generatedTasks: [PlannedTask] = []

    // التنقل
    @State private var goToSingleTask = false
    @State private var goToMultipleTasks = false

    // يمنع تشغيل AI مرتين
    @State private var hasStartedGenerating = false

    // خطأ في حالة Foundation Model غير متاح
    @State private var errorMessage: String? = nil

    private let checklistItems = [
        "Prioritizing them based on importance",
        "Considering your available time and energy",
        "Breaking them into small, manageable steps",
        "Creating a plan tailored for you"
    ]

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
                                .foregroundStyle(primary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

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
                                        Color.black.opacity(0.03)
                                    )
                                    .frame(
                                        width: 210,
                                        height: 210
                                    )
                            )

                        Text("Understanding your tasks....")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(primary)
                            .padding(.top, 28)

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
                                            systemName: "checkmark"
                                        )
                                        .font(
                                            .system(
                                                size: 12,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundStyle(primary)
                                    }

                                    Text(item)
                                        .font(
                                            .system(size: 16)
                                        )
                                        .foregroundStyle(primary)
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
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
                        .padding(.top, 36)
                        .padding(.horizontal, 32)

                        Spacer(
                            minLength: 40
                        )

                        // MARK: - Progress

                        VStack(spacing: 14) {

                            GeometryReader { geo in

                                ZStack(
                                    alignment: .leading
                                ) {

                                    Capsule()
                                        .fill(
                                            trackBackground
                                        )
                                        .frame(height: 6)

                                    Capsule()
                                        .fill(primary)
                                        .frame(
                                            width:
                                                geo.size.width
                                                * progress,
                                            height: 6
                                        )
                                }
                            }
                            .frame(height: 6)

                            if let errorMessage {

                                Text(errorMessage)
                                    .font(
                                        .system(size: 13)
                                    )
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(
                                        .center
                                    )

                            } else {

                                Text("Preparing your plan...")
                                    .font(
                                        .system(size: 14)
                                    )
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    }
                    .frame(
                        minHeight: screen.size.height
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

        // MARK: - Single Task

        .navigationDestination(
            isPresented: $goToSingleTask
        ) {

            if let task = generatedTasks.first {

                PlanOneTask(
                    task: task
                )
            }
        }

        // MARK: - Multiple Tasks

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
                    .easeOut(duration: 0.4)
                ) {

                    visibleItemCount =
                        index + 1
                }
            }
        }
    }

    // MARK: - Generate AI Plan

    @MainActor
    private func generatePlan() async {

        guard !userTasks.isEmpty else {

            errorMessage =
                "No tasks were found."

            return
        }

        guard let currentDayPlan =
                dayPlans.first
        else {

            errorMessage =
                "No day plan was found."

            return
        }

        do {

            let result =
                try await TaskPlanningService.shared
                    .generatePlan(
                        tasks: userTasks,
                        dayPlan: currentDayPlan
                    )

            // نمسح الخطة المولدة السابقة
            // حتى ما تتكرر كل مرة
            for plannedTask in
                existingPlannedTasks {

                modelContext.delete(
                    plannedTask
                )
            }

            var newPlannedTasks:
                [PlannedTask] = []

            for (
                taskIndex,
                generatedTask
            ) in result.tasks.enumerated() {

                // نحاول نلقى المهمة الأصلية
                // عشان نحافظ على Priority و Due Date
                let originalTask =
                    userTasks.first {

                        $0.title
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .lowercased()
                        ==
                        generatedTask.title
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .lowercased()
                    }

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
                                    generatedStep
                                        .estimatedMinutes,

                                isCompleted:
                                    false
                            )
                        }

                let plannedTask =
                    PlannedTask(

                        title:
                            generatedTask.title,

                        priority:
                            originalTask?
                                .priority
                            ?? "Medium",

                        dueDate:
                            originalTask?
                                .dueDate,

                        order:
                            taskIndex + 1,

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

            try modelContext.save()

            generatedTasks =
                newPlannedTasks.sorted {
                    $0.order < $1.order
                }

            // يكمل الشريط بعد ما AI يخلص فعلًا
            withAnimation(
                .easeInOut(duration: 0.8)
            ) {

                progress = 1.0
                visibleItemCount =
                    checklistItems.count
            }

            // ننتظر شوي فقط عشان الأنيميشن
            try? await Task.sleep(
                for:
                    .milliseconds(850)
            )

            onComplete()

            // القرار الحقيقي حسب عدد المهام
            if generatedTasks.count == 1 {

                goToSingleTask = true

            } else if generatedTasks.count > 1 {

                goToMultipleTasks = true
            }

        } catch {

            print(
                "AI plan generation failed: \(error)"
            )

            errorMessage =
                error.localizedDescription
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        LoadingPlanView()
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
