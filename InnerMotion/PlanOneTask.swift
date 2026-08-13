import SwiftUI
import SwiftData

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

struct PlanOneTask: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // المهمة الحقيقية الناتجة من AI
    let task: PlannedTask

    // اختياري للتحكم بزر الرجوع
    var onBack: (() -> Void)? = nil

    @State private var goToFocusOneStep = false

    // MARK: - Make It Easier State

    @State private var isMakingEasier = false
    @State private var makeItEasierError: String? = nil

    // MARK: - Button Press States

    @State private var isStartPressed = false
    @State private var isMakeItEasierPressed = false

    private var orderedSteps: [TaskStep] {

        task.steps.sorted {
            $0.order < $1.order
        }
    }

    var body: some View {

        ZStack {

            Color.backgroundColor
                .ignoresSafeArea()

            VStack {

                // MARK: - Top Bar

                HStack {

                    // Back
                    Button {

                        if let onBack {
                            onBack()
                        } else {
                            dismiss()
                        }

                    } label: {

                        Image(
                            systemName: "chevron.left"
                        )
                        .font(
                            .system(
                                size: 20,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            Color(hex: "75608E")
                        )
                        .frame(
                            width: 32,
                            height: 32
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Home
                    NavigationLink {
                        MainTabView()
                    } label: {

                        Image(
                            systemName: "house"
                        )
                        .font(
                            .system(
                                size: 27,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            Color(hex: "75608E")
                        )
                        .frame(
                            width: 38,
                            height: 38
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Spacer()
                    .frame(height: 25)

                // MARK: - Title

                Text("Your first steps")
                    .font(
                        .system(
                            size: 34,
                            weight: .medium
                        )
                    )
                    .foregroundColor(
                        .primaryText
                    )

                Text(
                    "Tiny steps to get you moving"
                )
                .font(.system(size: 17))
                .foregroundColor(
                    .secondaryText
                )

                Spacer()
                    .frame(height: 35)

                // MARK: - Task Title

                RoundedRectangle(
                    cornerRadius: 18
                )
                .fill(Color.cardColor)
                .frame(height: 65)
                .overlay(

                    HStack {

                        Text(task.title)
                            .foregroundColor(
                                .secondaryText
                            )
                            .font(
                                .system(size: 21)
                            )

                        Spacer()
                    }
                    .padding(
                        .horizontal,
                        20
                    )
                )
                .padding(.horizontal)

                Spacer()
                    .frame(height: 25)

                // MARK: - AI Generated Steps

                ScrollView(
                    showsIndicators: false
                ) {

                    VStack(spacing: 12) {

                        ForEach(
                            orderedSteps
                        ) { step in

                            StepCard(
                                number:
                                    "\(step.order)",
                                text:
                                    step.text,
                                highlight:
                                    step.order == 1
                            )
                        }
                    }
                }

                Spacer(
                    minLength: 20
                )

                // MARK: - Error Message

                if let makeItEasierError {

                    Text(makeItEasierError)
                        .font(
                            .system(size: 13)
                        )
                        .foregroundStyle(.red)
                        .multilineTextAlignment(
                            .center
                        )
                        .padding(
                            .horizontal,
                            35
                        )
                        .padding(
                            .bottom,
                            8
                        )
                }

                // MARK: - Start First Step

                Button {

                    if !orderedSteps.isEmpty {

                        goToFocusOneStep = true
                    }

                } label: {

                    Text("Start First Step")
                        .font(
                            .system(size: 28)
                        )
                        .foregroundStyle(.white)
                        .frame(
                            maxWidth: .infinity
                        )
                        .frame(height: 60)
                        .background(

                            isStartPressed

                            ? Color(
                                red: 0.337,
                                green: 0.239,
                                blue: 0.416
                            )

                            : Color.primaryButton
                        )
                        .clipShape(
                            Capsule()
                        )
                }
                .buttonStyle(.plain)
                .disabled(
                    orderedSteps.isEmpty
                    ||
                    isMakingEasier
                )
                .opacity(
                    orderedSteps.isEmpty
                    ||
                    isMakingEasier
                    ? 0.55
                    : 1
                )
                .simultaneousGesture(

                    DragGesture(
                        minimumDistance: 0
                    )
                    .onChanged { _ in

                        if !orderedSteps.isEmpty
                            &&
                            !isMakingEasier {

                            isStartPressed = true
                        }
                    }
                    .onEnded { _ in

                        isStartPressed = false
                    }
                )
                .padding(
                    .horizontal,
                    35
                )
                .navigationDestination(
                    isPresented:
                        $goToFocusOneStep
                ) {

                    FocusOneStep(
                        task: task
                    )
                }

                // MARK: - Make It Easier

                Button {

                    Task {

                        await makeTaskEasier()
                    }

                } label: {

                    HStack(
                        spacing: 10
                    ) {

                        if isMakingEasier {

                            ProgressView()
                                .tint(.white)

                            Text(
                                "Making it Easier..."
                            )

                        } else {

                            Text(
                                "Make it Easier"
                            )
                        }
                    }
                    .font(
                        .system(size: 28)
                    )
                    .foregroundStyle(.white)
                    .frame(
                        maxWidth: .infinity
                    )
                    .frame(height: 60)
                    .background(

                        isMakeItEasierPressed

                        ? Color(
                            red: 0.337,
                            green: 0.239,
                            blue: 0.416
                        )

                        : Color.secondaryButton
                    )
                    .clipShape(
                        Capsule()
                    )
                }
                .buttonStyle(.plain)
                .disabled(
                    orderedSteps.isEmpty
                    ||
                    isMakingEasier
                )
                .opacity(
                    orderedSteps.isEmpty
                    ||
                    isMakingEasier
                    ? 0.55
                    : 1
                )
                .simultaneousGesture(

                    DragGesture(
                        minimumDistance: 0
                    )
                    .onChanged { _ in

                        if !orderedSteps.isEmpty
                            &&
                            !isMakingEasier {

                            isMakeItEasierPressed = true
                        }
                    }
                    .onEnded { _ in

                        isMakeItEasierPressed = false
                    }
                )
                .padding(
                    .horizontal,
                    35
                )
                .padding(
                    .bottom,
                    35
                )
            }
        }
        .toolbar(
            .hidden,
            for: .navigationBar
        )
    }

    // MARK: - Make Task Easier

    @MainActor
    private func makeTaskEasier() async {

        guard !isMakingEasier else {
            return
        }

        guard !orderedSteps.isEmpty else {
            return
        }

        isMakingEasier = true

        makeItEasierError = nil

        do {

            // MARK: Ask AI

            let easierPlan =
                try await
                TaskPlanningService
                    .shared
                    .makeTaskEasier(
                        task: task
                    )

            guard
                !easierPlan.steps.isEmpty
            else {

                makeItEasierError =
                    "The AI did not return any steps."

                isMakingEasier =
                    false

                return
            }

            // MARK: Build New Steps

            let newSteps =
                easierPlan.steps
                    .enumerated()
                    .map {
                        index,
                        generatedStep in

                        TaskStep(

                            order:
                                index + 1,

                            text:
                                generatedStep.text,

                            estimatedMinutes:
                                generatedStep
                                    .estimatedMinutes,

                            isCompleted:
                                false
                        )
                    }

            // MARK: Remove Old Steps

            let oldSteps =
                Array(task.steps)

            /*
             نحذف الخطوات القديمة من SwiftData.

             ما نحذف PlannedTask نفسها.
             المهمة نفسها تبقى:
             - بنفس العنوان
             - بنفس sessionID
             - بنفس Priority
             - بنفس Due Date
             */

            for oldStep in
                oldSteps {

                modelContext.delete(
                    oldStep
                )
            }

            // MARK: Replace Relationship

            task.steps =
                newSteps

            // إدخال الخطوات الجديدة

            for newStep in
                newSteps {

                modelContext.insert(
                    newStep
                )
            }

            // MARK: Save

            try modelContext.save()

            print(
                "Task made easier successfully: \(task.title)"
            )

        } catch {

            print(
                "Make it easier failed: \(error)"
            )

            makeItEasierError =
                error.localizedDescription
        }

        isMakingEasier =
            false
    }
}


// MARK: - Step Card

struct StepCard: View {

    var number: String
    var text: String
    var highlight = false

    var body: some View {

        HStack(
            alignment: .center,
            spacing: 18
        ) {

            // MARK: - Step Number

            Circle()
                .stroke(
                    Color.secondaryText,
                    lineWidth: 2
                )
                .frame(
                    width: 38,
                    height: 38
                )
                .overlay {

                    Text(number)
                        .foregroundColor(
                            .secondaryText
                        )
                }

            // MARK: - Step Text

            Text(text)
                .foregroundColor(
                    .secondaryText
                )
                .font(
                    .system(size: 20)
                )
                .multilineTextAlignment(
                    .leading
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Spacer(
                minLength: 0
            )
        }
        .padding(
            .horizontal,
            18
        )
        .padding(
            .vertical,
            14
        )
        .frame(
            maxWidth: .infinity
        )
        .frame(
            minHeight: 70
        )
        .background(
            RoundedRectangle(
                cornerRadius: 18
            )
            .fill(
                highlight
                ? Color.selectedCard
                : Color.cardColor
            )
        )
        .padding(
            .horizontal
        )
    }
}


// MARK: - Preview

#Preview {

    let step1 = TaskStep(
        order: 1,
        text: "Open the lecture slides",
        estimatedMinutes: 2
    )

    let step2 = TaskStep(
        order: 2,
        text: "Read the first title only",
        estimatedMinutes: 3
    )

    let step3 = TaskStep(
        order: 3,
        text: "Highlight one line",
        estimatedMinutes: 2
    )

    let previewTask = PlannedTask(
        title: "Study for math exam",
        priority: "High",
        order: 1,
        planningSessionID: UUID(),
        steps: [
            step1,
            step2,
            step3
        ]
    )

    NavigationStack {

        PlanOneTask(
            task: previewTask
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
