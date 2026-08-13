import SwiftUI
import SwiftData

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

// MARK: - Preference Key لقياس حجم محتوى الخطوة

private struct StepContentSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(
        value: inout CGSize,
        nextValue: () -> CGSize
    ) {
        value = nextValue()
    }
}

struct FocusOneStep: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let task: PlannedTask

    @State private var currentStepIndex = 0

    @State private var showCompletionPopup = false
    @State private var goToBreakTime = false
    @State private var goToStarReward = false

    @State private var hasMarkedInProgress = false

    @State private var stepContentSize: CGSize = .zero

    // MARK: - Button Press States

    @State private var isDonePressed = false
    @State private var isContinuePressed = false
    @State private var isBreakPressed = false

    private var orderedSteps: [TaskStep] {
        task.steps.sorted {
            $0.order < $1.order
        }
    }

    private var currentStep: TaskStep? {
        guard orderedSteps.indices.contains(currentStepIndex) else {
            return nil
        }

        return orderedSteps[currentStepIndex]
    }

    private var isLastStep: Bool {
        guard !orderedSteps.isEmpty else {
            return false
        }

        return currentStepIndex == orderedSteps.count - 1
    }

    private var circleDiameter: CGFloat {
        let minDiameter: CGFloat = 320
        let maxDiameter: CGFloat = 380
        let verticalPadding: CGFloat = 90

        let needed = stepContentSize.height + verticalPadding

        return min(
            max(minDiameter, needed),
            maxDiameter
        )
    }

    var body: some View {

        ZStack {

            // MARK: - Background

            Color.backgroundColor
                .ignoresSafeArea()

            VStack {
                Spacer()

                Image("background")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea()

            VStack {

                // MARK: - Top Bar

                HStack {

                    Button {
                        dismiss()
                    } label: {

                        Image(systemName: "chevron.left")
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

                    NavigationLink {
                        MainTabView()
                    } label: {

                        Image(systemName: "house")
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

                Text("Focus one step")
                    .font(
                        .system(
                            size: 34,
                            weight: .medium
                        )
                    )
                    .foregroundColor(.primaryText)

                Text("You've got this")
                    .font(.system(size: 17))
                    .foregroundColor(.secondaryText)

                Spacer()

                // MARK: - Current Step

                if let currentStep {

                    ZStack {

                        Circle()
                            .fill(
                                Color.stepCircleColor
                                    .opacity(0.7)
                            )
                            .frame(
                                width: circleDiameter,
                                height: circleDiameter
                            )
                            .animation(
                                .easeInOut(duration: 0.25),
                                value: circleDiameter
                            )

                        VStack(spacing: 14) {

                            Text(
                                "Step \(currentStepIndex + 1) of \(orderedSteps.count)"
                            )
                            .font(.system(size: 17))
                            .foregroundColor(.secondaryText)

                            Text(currentStep.text)
                                .font(
                                    .system(
                                        size: 24,
                                        weight: .bold
                                    )
                                )
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.center)

                            Text("Estimated time")
                                .font(.system(size: 15))
                                .foregroundColor(.secondaryText)
                                .padding(.top, 22)

                            Text(
                                estimatedTimeText(
                                    currentStep.estimatedMinutes
                                )
                            )
                            .font(
                                .system(
                                    size: 17,
                                    weight: .semibold
                                )
                            )
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                        }
                        .frame(width: 240)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: StepContentSizeKey.self,
                                        value: geo.size
                                    )
                            }
                        )
                        .onPreferenceChange(
                            StepContentSizeKey.self
                        ) { size in
                            stepContentSize = size
                        }
                    }

                } else {

                    Text("No steps available")
                        .foregroundColor(.secondaryText)
                }

                Spacer()

                // MARK: - Done / Take a Break

                HStack(spacing: 55) {

                    // MARK: Done

                    VStack(spacing: 10) {

                        Button {

                            completeCurrentStep()

                        } label: {

                            Image(systemName: "checkmark")
                                .font(
                                    .system(
                                        size: 30,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(.white)
                                .frame(
                                    width: 90,
                                    height: 90
                                )
                                .background(
                                    Circle()
                                        .fill(
                                            isDonePressed
                                            ? Color(
                                                red: 0.337,
                                                green: 0.239,
                                                blue: 0.416
                                            )
                                            : Color.primaryButton
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(currentStep == nil)
                        .simultaneousGesture(

                            DragGesture(
                                minimumDistance: 0
                            )
                            .onChanged { _ in

                                if currentStep != nil {
                                    isDonePressed = true
                                }
                            }
                            .onEnded { _ in

                                isDonePressed = false
                            }
                        )

                        Text("Done")
                            .font(
                                .system(
                                    size: 22,
                                    weight: .medium
                                )
                            )
                            .foregroundColor(.primaryText)
                    }

                    // MARK: Take a Break

                    VStack(spacing: 10) {

                        Button {

                            goToBreakTime = true

                        } label: {

                            Image(
                                systemName: "cup.and.saucer.fill"
                            )
                            .font(
                                .system(size: 28)
                            )
                            .foregroundStyle(.white)
                            .frame(
                                width: 90,
                                height: 90
                            )
                            .background(
                                Circle()
                                    .fill(
                                        isBreakPressed
                                        ? Color(
                                            red: 0.337,
                                            green: 0.239,
                                            blue: 0.416
                                        )
                                        : Color.secondaryButton
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(

                            DragGesture(
                                minimumDistance: 0
                            )
                            .onChanged { _ in

                                isBreakPressed = true
                            }
                            .onEnded { _ in

                                isBreakPressed = false
                            }
                        )

                        Text("Take a Break")
                            .font(
                                .system(
                                    size: 22,
                                    weight: .medium
                                )
                            )
                            .foregroundColor(.primaryText)
                    }
                }
                .padding(.top, 25)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
                .background(
                    Color.backgroundColor
                        .clipShape(
                            RoundedCorner(
                                radius: 35,
                                corners: [
                                    .topLeft,
                                    .topRight
                                ]
                            )
                        )
                        .ignoresSafeArea(
                            edges: .bottom
                        )
                )
                .navigationDestination(
                    isPresented: $goToBreakTime
                ) {
                    breakTime()
                }
            }

            // MARK: - Nice Work Popup

            if showCompletionPopup {

                Color.black
                    .opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture { }

                VStack(spacing: 22) {

                    ZStack {

                        Circle()
                            .fill(Color.successGreen)
                            .frame(
                                width: 95,
                                height: 95
                            )

                        Image(systemName: "checkmark")
                            .font(
                                .system(
                                    size: 34,
                                    weight: .bold
                                )
                            )
                            .foregroundColor(.secondaryText)
                    }

                    Text("Nice work!")
                        .font(
                            .system(
                                size: 28,
                                weight: .bold
                            )
                        )
                        .foregroundColor(.primaryText)

                    Text(
                        isLastStep
                        ? "You completed your task"
                        : "You completed this step"
                    )
                    .font(.system(size: 17))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)

                    // MARK: - Continue

                    Button {

                        continueAfterCompletion()

                    } label: {

                        Text("Continue")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(.white)
                            .frame(
                                maxWidth: .infinity
                            )
                            .frame(height: 55)
                            .background(
                                isContinuePressed
                                ? Color(
                                    red: 0.337,
                                    green: 0.239,
                                    blue: 0.416
                                )
                                : Color.primaryButton
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 27.5
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(

                        DragGesture(
                            minimumDistance: 0
                        )
                        .onChanged { _ in

                            isContinuePressed = true
                        }
                        .onEnded { _ in

                            isContinuePressed = false
                        }
                    )
                    .padding(.top, 8)
                }
                .padding(30)
                .frame(maxWidth: 340)
                .background(Color.backgroundColor)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 30
                    )
                )
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 20,
                    x: 0,
                    y: 10
                )
                .transition(
                    .scale.combined(
                        with: .opacity
                    )
                )
            }
        }

        .onAppear {

            moveToFirstIncompleteStep()

            markTaskAsInProgress()
        }

        .animation(
            .easeInOut(duration: 0.25),
            value: showCompletionPopup
        )

        .toolbar(
            .hidden,
            for: .navigationBar
        )

        .navigationDestination(
            isPresented: $goToStarReward
        ) {
            StarRewardView(task: task)
        }
    }

    // MARK: - Complete Current Step

    private func completeCurrentStep() {

        guard let currentStep else {
            return
        }

        currentStep.isCompleted = true

        do {

            try modelContext.save()

            print(
                "Completed step \(currentStep.order): \(currentStep.text)"
            )

            showCompletionPopup = true

        } catch {

            print(
                "Failed to save completed step: \(error)"
            )
        }
    }

    // MARK: - Continue After Popup

    private func continueAfterCompletion() {

        showCompletionPopup = false

        if isLastStep {

            goToStarReward = true

        } else {

            withAnimation(
                .easeInOut(duration: 0.3)
            ) {

                currentStepIndex += 1
            }
        }
    }

    // MARK: - Resume From First Incomplete Step

    private func moveToFirstIncompleteStep() {

        guard !orderedSteps.isEmpty else {
            return
        }

        if let firstIncompleteIndex =
            orderedSteps.firstIndex(
                where: {
                    !$0.isCompleted
                }
            ) {

            currentStepIndex =
                firstIncompleteIndex

        } else {

            currentStepIndex =
                max(
                    orderedSteps.count - 1,
                    0
                )
        }
    }

    // MARK: - Mark Task In Progress

    private func markTaskAsInProgress() {

        guard !hasMarkedInProgress else {
            return
        }

        hasMarkedInProgress = true

        let normalizedTitle =
            task.title
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        let descriptor =
            FetchDescriptor<UserTask>()

        do {

            let userTasks =
                try modelContext.fetch(
                    descriptor
                )

            guard let originalTask =
                userTasks.first(
                    where: {

                        $0.title
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .lowercased()
                        ==
                        normalizedTitle
                    }
                )
            else {

                print(
                    "Original UserTask not found for: \(task.title)"
                )

                return
            }

            if originalTask.status == "Not Started" {

                originalTask.status =
                    "In Progress"

                try modelContext.save()

                print(
                    "Task marked In Progress: \(originalTask.title)"
                )
            }

        } catch {

            print(
                "Failed to mark task In Progress: \(error)"
            )
        }
    }

    // MARK: - Estimated Time Text

    private func estimatedTimeText(
        _ minutes: Int
    ) -> String {

        if minutes == 1 {
            return "About\n1 minute"
        }

        return "About\n\(minutes) minutes"
    }
}

// MARK: - Rounded Corner

struct RoundedCorner: Shape {

    var radius: CGFloat = 25
    var corners: UIRectCorner = .allCorners

    func path(
        in rect: CGRect
    ) -> Path {

        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(
                width: radius,
                height: radius
            )
        )

        return Path(path.cgPath)
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

    let step4 = TaskStep(
        order: 4,
        text: "Take a short pause",
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
            step3,
            step4
        ]
    )

    NavigationStack {

        FocusOneStep(
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
