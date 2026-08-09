import SwiftUI
import SwiftData

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

struct FocusOneStep: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // المهمة الحقيقية الناتجة من الـ AI
    let task: PlannedTask

    // رقم الخطوة الحالية
    @State private var currentStepIndex = 0

    // حالات التنقل والـ Popup
    @State private var showCompletionPopup = false
    @State private var goToBreakTime = false
    @State private var goToStarReward = false

    // يمنع محاولة تغيير الحالة أكثر من مرة
    @State private var hasMarkedInProgress = false

    // ترتيب الخطوات حسب رقمها
    private var orderedSteps: [TaskStep] {
        task.steps.sorted {
            $0.order < $1.order
        }
    }

    // الخطوة الحالية
    private var currentStep: TaskStep? {
        guard orderedSteps.indices.contains(currentStepIndex) else {
            return nil
        }

        return orderedSteps[currentStepIndex]
    }

    // هل الخطوة الحالية هي آخر خطوة؟
    private var isLastStep: Bool {
        guard !orderedSteps.isEmpty else {
            return false
        }

        return currentStepIndex == orderedSteps.count - 1
    }

    var body: some View {

        ZStack {

            // MARK: - Background

            Color.backgroundColor
                .ignoresSafeArea()

            // صورة الخلفية - الجبال
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
                            .font(.title2)
                    }
                    .buttonStyle(
                        PressableIconStyle(
                            normalColor: .primaryText,
                            pressedColor: .secondaryButton
                        )
                    )

                    Spacer()

                    NavigationLink {
                        MainTabView()
                    } label: {

                        Image(systemName: "house")
                            .font(.system(size: 28))
                    }
                    .buttonStyle(
                        PressableIconStyle(
                            normalColor: .primaryText,
                            pressedColor: .secondaryButton
                        )
                    )
                }
                .padding(.horizontal, 25)
                .padding(.top, 15)

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
                                width: 320,
                                height: 320
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
                                .padding(.horizontal, 40)

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
                    }

                } else {

                    Text("No steps available")
                        .foregroundColor(.secondaryText)
                }

                Spacer()

                // MARK: - Done / Take a Break

                HStack(spacing: 55) {

                    // Done
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
                                .frame(
                                    width: 90,
                                    height: 90
                                )
                        }
                        .buttonStyle(
                            PressableCircleIconStyle(
                                fillColor: .primaryButton
                            )
                        )
                        .disabled(currentStep == nil)

                        Text("Done")
                            .font(
                                .system(
                                    size: 22,
                                    weight: .medium
                                )
                            )
                            .foregroundColor(.primaryText)
                    }

                    // Take a Break
                    VStack(spacing: 10) {

                        Button {

                            goToBreakTime = true

                        } label: {

                            Image(
                                systemName: "cup.and.saucer.fill"
                            )
                            .font(.system(size: 28))
                            .frame(
                                width: 90,
                                height: 90
                            )
                        }
                        .buttonStyle(
                            PressableCircleIconStyle(
                                fillColor: .secondaryButton
                            )
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

                // يمنع الضغط على الخلفية
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
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                    }
                    .buttonStyle(
                        PressableCapsuleStyle(
                            fillColor: .primaryButton,
                            cornerRadius: 27.5
                        )
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

        // MARK: - On Appear

        .onAppear {

            // يرجع لأول خطوة غير مكتملة
            moveToFirstIncompleteStep()

            // أول ما يبدأ المهمة تتحول إلى In Progress
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

        // بعد إنهاء جميع الخطوات
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

        // نحفظ أن هذه الخطوة اكتملت
        currentStep.isCompleted = true

        do {

            try modelContext.save()

            print(
                "Completed step \(currentStep.order): \(currentStep.text)"
            )

            // يظهر Nice Work
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

        // إذا كانت آخر خطوة
        if isLastStep {

            // يروح إلى صفحة النجمة
            goToStarReward = true

        } else {

            // يروح للخطوة التالية
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

        // يبحث عن أول خطوة لم تكتمل
        if let firstIncompleteIndex =
            orderedSteps.firstIndex(
                where: {
                    !$0.isCompleted
                }
            ) {

            currentStepIndex =
                firstIncompleteIndex

        } else {

            // إذا كانت كل الخطوات مكتملة
            // يعرض آخر خطوة
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

            // فقط المهمة الجديدة تتحول إلى In Progress
            // لو كانت Completed ما نرجع نغيرها
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
