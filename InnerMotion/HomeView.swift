//
//  HomeView.swift
//  InnerMotion
//
//  Created by Renad Sameer Alharbi on 22/02/1448 AH.
//

import SwiftUI
import SwiftData
import UserNotifications

struct HomeView: View {

    // MARK: - Data

    @Query(
        sort: \UserTask.createdAt,
        order: .reverse
    )
    private var userTasks: [UserTask]

    @Query(
        sort: \PlannedTask.order
    )
    private var plannedTasks: [PlannedTask]

    // MARK: - Navigation State

    @State private var showSuggestionCategories = false
    @State private var goToFocusTask = false
    @State private var goToPendingPlanning = false

    // نحفظ الجلسة التي ضغط عليها المستخدم
    // حتى لو حذف آخر Task أثناء وجوده داخل MyTasksView
    @State private var selectedPendingPlanningSessionID: UUID?

    // MARK: - Notifications

    @AppStorage("notificationsEnabled")
    private var notificationsEnabled = false

    @State private var notificationsAuthorized = false
    @State private var showNotificationDeniedAlert = false

    // MARK: - Pending Planning Session

    private var pendingPlanningSessionID: UUID? {

        userTasks.first {

            $0.isPlanned == false &&
            $0.planningSessionID != nil

        }?.planningSessionID
    }

    // MARK: - Pending Planning Tasks

    private var pendingPlanningTasks: [UserTask] {

        guard let pendingPlanningSessionID else {
            return []
        }

        return userTasks
            .filter {

                $0.planningSessionID ==
                    pendingPlanningSessionID
                &&
                $0.isPlanned == false
            }
            .sorted {

                $0.createdAt <
                    $1.createdAt
            }
    }

    // MARK: - Incomplete Tasks For Notifications

    private var hasIncompleteTasks: Bool {

        userTasks.contains {

            $0.isPlanned != false
            &&
            (
                $0.status == "Not Started"
                ||
                $0.status == "In Progress"
            )
        }
    }

    // MARK: - Current In Progress Task

    private var currentUserTask: UserTask? {

        userTasks.first {

            $0.status == "In Progress"
            &&
            $0.isPlanned != false
        }
    }

    // MARK: - Matching Planned Task

    private var currentPlannedTask: PlannedTask? {

        guard let currentUserTask else {
            return nil
        }

        // أولًا المطابقة باستخدام Session ID

        if let sessionID =
            currentUserTask.planningSessionID {

            if let matchedTask =
                plannedTasks.first(
                    where: {

                        $0.planningSessionID ==
                            sessionID

                        &&

                        $0.title
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .lowercased()
                        ==
                        currentUserTask.title
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .lowercased()
                    }
                ) {

                return matchedTask
            }
        }

        // Fallback للمهام القديمة

        let normalizedTitle =
            currentUserTask.title
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .lowercased()

        return plannedTasks.first {

            $0.title
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .lowercased()
            ==
            normalizedTitle
        }
    }

    // MARK: - Ordered Steps

    private var orderedCurrentSteps: [TaskStep] {

        guard let currentPlannedTask else {
            return []
        }

        return currentPlannedTask.steps.sorted {

            $0.order <
                $1.order
        }
    }

    // MARK: - Current Step

    private var currentStepIndex: Int? {

        orderedCurrentSteps.firstIndex {

            !$0.isCompleted
        }
    }

    // MARK: - Display Step Number

    private var displayedStepNumber: Int {

        guard !orderedCurrentSteps.isEmpty else {
            return 0
        }

        if let currentStepIndex {

            return currentStepIndex + 1
        }

        return orderedCurrentSteps.count
    }

    // MARK: - Progress

    private var progressValue: CGFloat {

        guard !orderedCurrentSteps.isEmpty else {
            return 0
        }

        let completedCount =
            orderedCurrentSteps.filter {

                $0.isCompleted

            }.count

        return CGFloat(completedCount)
        /
        CGFloat(orderedCurrentSteps.count)
    }

    // MARK: - Body

    var body: some View {

        ZStack(alignment: .bottom) {

            // MARK: - Background

            Color(
                red: 0.992,
                green: 0.973,
                blue: 0.949
            )
            .ignoresSafeArea()

            ScrollView(
                showsIndicators: false
            ) {

                VStack(spacing: 32) {

                    // MARK: - Header

                    VStack(spacing: 18) {

                        HStack {

                            Spacer()

                            // MARK: Notification Bell

                            Button {

                                handleNotificationButton()

                            } label: {

                                Image(
                                    systemName:
                                        notificationsEnabled
                                        &&
                                        notificationsAuthorized
                                        ? "bell.fill"
                                        : "bell"
                                )
                                .font(
                                    .system(
                                        size: 26,
                                        weight: .regular
                                    )
                                )
                                .foregroundColor(
                                    Color(
                                        red: 0.28,
                                        green: 0.18,
                                        blue: 0.42
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 5)

                        Text(
                            "Welcome to Inner Motion"
                        )
                        .font(
                            .system(
                                size: 28,
                                weight: .bold
                            )
                        )
                        .foregroundColor(
                            Color(
                                red: 0.22,
                                green: 0.05,
                                blue: 0.48
                            )
                        )
                        .multilineTextAlignment(
                            .center
                        )

                        Text(
                            "Small steps, real progress."
                        )
                        .font(
                            .system(size: 18)
                        )
                        .foregroundColor(
                            Color(
                                red: 0.4,
                                green: 0.3,
                                blue: 0.5
                            )
                        )
                        .multilineTextAlignment(
                            .center
                        )
                    }
                    .padding(
                        .horizontal,
                        24
                    )

                    // MARK: - Feature Cards

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {

                        Text(
                            "What would help you right now?"
                        )
                        .font(
                            .system(
                                size: 17,
                                weight: .medium
                            )
                        )
                        .foregroundColor(
                            Color(
                                red: 0.35,
                                green: 0.25,
                                blue: 0.45
                            )
                        )
                        .padding(
                            .leading,
                            2
                        )

                        // MARK: Feature 1

                        NavigationLink(
                            destination:
                                AddTaskView()
                        ) {

                            HStack(spacing: 14) {

                                ZStack {

                                    Circle()
                                        .fill(
                                            Color.white
                                        )
                                        .frame(
                                            width: 50,
                                            height: 48
                                        )

                                    Image("noise")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(
                                            width: 60,
                                            height: 100
                                        )
                                }

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {

                                    Text(
                                        "I have a task, but I\ncan’t start"
                                    )
                                    .font(
                                        .system(
                                            size: 16,
                                            weight: .bold
                                        )
                                    )
                                    .foregroundColor(
                                        Color(
                                            red: 0.22,
                                            green: 0.05,
                                            blue: 0.48
                                        )
                                    )
                                    .multilineTextAlignment(
                                        .leading
                                    )
                                    .lineSpacing(2)

                                    Text(
                                        "Help me begin, step by step"
                                    )
                                    .font(
                                        .system(
                                            size: 12
                                        )
                                    )
                                    .foregroundColor(
                                        Color(
                                            red: 0.45,
                                            green: 0.35,
                                            blue: 0.55
                                        )
                                    )
                                }

                                Spacer(
                                    minLength: 0
                                )

                                Image(
                                    systemName:
                                        "chevron.right"
                                )
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .bold
                                    )
                                )
                                .foregroundColor(
                                    Color(
                                        red: 0.35,
                                        green: 0.25,
                                        blue: 0.45
                                    )
                                )
                            }
                            .padding(
                                .horizontal,
                                16
                            )
                            .padding(
                                .vertical,
                                18
                            )
                            .frame(
                                maxWidth: .infinity
                            )
                            .background(
                                Color(
                                    red: 0.92,
                                    green: 0.89,
                                    blue: 0.97
                                )
                            )
                            .cornerRadius(22)
                        }
                        .buttonStyle(.plain)

                        // MARK: Feature 2

                        HStack(spacing: 14) {

                            ZStack {

                                Circle()
                                    .fill(
                                        Color.white
                                    )
                                    .frame(
                                        width: 48,
                                        height: 48
                                    )

                                Image("tree")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: 36,
                                        height: 100
                                    )
                            }

                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {

                                Text(
                                    "I don’t know what I need to\ndo right now"
                                )
                                .font(
                                    .system(
                                        size: 15,
                                        weight: .bold
                                    )
                                )
                                .foregroundColor(
                                    Color(
                                        red: 0.2,
                                        green: 0.1,
                                        blue: 0.4
                                    )
                                )
                                .multilineTextAlignment(
                                    .leading
                                )
                                .lineSpacing(2)

                                Text(
                                    "Suggest something for me to do"
                                )
                                .font(
                                    .system(size: 12)
                                )
                                .foregroundColor(
                                    Color(
                                        red: 0.4,
                                        green: 0.35,
                                        blue: 0.5
                                    )
                                )
                            }

                            Spacer(
                                minLength: 0
                            )

                            Image(
                                systemName:
                                    "chevron.right"
                            )
                            .font(
                                .system(
                                    size: 14,
                                    weight: .bold
                                )
                            )
                            .foregroundColor(
                                Color(
                                    red: 0.35,
                                    green: 0.25,
                                    blue: 0.45
                                )
                            )
                        }
                        .padding(
                            .horizontal,
                            15
                        )
                        .padding(
                            .vertical,
                            18
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                        .background(
                            Color(
                                red: 0.86,
                                green: 0.89,
                                blue: 0.78
                            )
                        )
                        .cornerRadius(22)
                        .contentShape(
                            Rectangle()
                        )
                        .onTapGesture {

                            showSuggestionCategories =
                                true
                        }

                    }
                    .padding(
                        .horizontal,
                        20
                    )

                    // MARK: - Continue Planning

                    if let pendingPlanningSessionID,
                       !pendingPlanningTasks.isEmpty {

                        VStack(
                            alignment: .leading,
                            spacing: 12
                        ) {

                            Text(
                                "Continue planning"
                            )
                            .font(
                                .system(
                                    size: 17,
                                    weight: .medium
                                )
                            )
                            .foregroundColor(
                                Color(
                                    red: 0.35,
                                    green: 0.25,
                                    blue: 0.45
                                )
                            )
                            .padding(
                                .leading,
                                2
                            )

                            VStack(
                                alignment: .trailing,
                                spacing: 12
                            ) {

                                HStack(
                                    alignment: .top,
                                    spacing: 16
                                ) {

                                    RoundedRectangle(
                                        cornerRadius: 16
                                    )
                                    .fill(
                                        Color(
                                            red: 0.9,
                                            green: 0.86,
                                            blue: 0.94
                                        )
                                    )
                                    .frame(
                                        width: 58,
                                        height: 58
                                    )
                                    .overlay {

                                        Image(
                                            systemName:
                                                "list.bullet.clipboard"
                                        )
                                        .font(
                                            .system(
                                                size: 24
                                            )
                                        )
                                        .foregroundColor(
                                            Color(
                                                red: 0.35,
                                                green: 0.2,
                                                blue: 0.55
                                            )
                                        )
                                    }

                                    VStack(
                                        alignment: .leading,
                                        spacing: 5
                                    ) {

                                        Text(
                                            pendingPlanningTasks.count == 1
                                            ? "1 task waiting to be planned"
                                            : "\(pendingPlanningTasks.count) tasks waiting to be planned"
                                        )
                                        .font(
                                            .system(
                                                size: 15,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundColor(
                                            Color(
                                                red: 0.22,
                                                green: 0.05,
                                                blue: 0.48
                                            )
                                        )

                                        Text(
                                            "Finish setting up your plan"
                                        )
                                        .font(
                                            .system(
                                                size: 12
                                            )
                                        )
                                        .foregroundColor(
                                            Color(
                                                red: 0.5,
                                                green: 0.4,
                                                blue: 0.6
                                            )
                                        )
                                    }

                                    Spacer(
                                        minLength: 0
                                    )
                                }

                                // MARK: Continue Planning Button

                                Button {

                                    selectedPendingPlanningSessionID =
                                        pendingPlanningSessionID

                                    goToPendingPlanning =
                                        true

                                } label: {

                                    HStack(
                                        spacing: 4
                                    ) {

                                        Text(
                                            "Continue Planning"
                                        )
                                        .font(
                                            .system(
                                                size: 12,
                                                weight: .medium
                                            )
                                        )

                                        Image(
                                            systemName:
                                                "chevron.right"
                                        )
                                        .font(
                                            .system(
                                                size: 9,
                                                weight: .bold
                                            )
                                        )
                                    }
                                    .foregroundStyle(
                                        .white
                                    )
                                    .padding(
                                        .vertical,
                                        8
                                    )
                                    .padding(
                                        .horizontal,
                                        16
                                    )
                                }
                                .buttonStyle(
                                    ContinueButtonStyle(
                                        color:
                                            Color(
                                                red: 0.45,
                                                green: 0.38,
                                                blue: 0.58
                                            )
                                    )
                                )
                            }
                            .padding(18)
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                            .background(
                                Color(
                                    red: 0.95,
                                    green: 0.93,
                                    blue: 0.94
                                )
                            )
                            .cornerRadius(22)
                        }
                        .padding(
                            .horizontal,
                            24
                        )
                    }

                    // MARK: - Continue Current Task

                    if let currentPlannedTask {

                        VStack(
                            alignment: .leading,
                            spacing: 12
                        ) {

                            Text(
                                "Continue where you left off"
                            )
                            .font(
                                .system(
                                    size: 17,
                                    weight: .medium
                                )
                            )
                            .foregroundColor(
                                Color(
                                    red: 0.35,
                                    green: 0.25,
                                    blue: 0.45
                                )
                            )
                            .padding(
                                .leading,
                                2
                            )

                            VStack(
                                alignment: .trailing,
                                spacing: 12
                            ) {

                                HStack(
                                    alignment: .top,
                                    spacing: 16
                                ) {

                                    RoundedRectangle(
                                        cornerRadius: 16
                                    )
                                    .fill(
                                        Color(
                                            red: 0.9,
                                            green: 0.86,
                                            blue: 0.94
                                        )
                                    )
                                    .frame(
                                        width: 58,
                                        height: 58
                                    )
                                    .overlay {

                                        Image(
                                            systemName: "book"
                                        )
                                        .font(
                                            .system(
                                                size: 24
                                            )
                                        )
                                        .foregroundColor(
                                            Color(
                                                red: 0.35,
                                                green: 0.2,
                                                blue: 0.55
                                            )
                                        )
                                    }

                                    VStack(
                                        alignment: .leading,
                                        spacing: 5
                                    ) {

                                        Text(
                                            currentPlannedTask.title
                                        )
                                        .font(
                                            .system(
                                                size: 15,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundColor(
                                            Color(
                                                red: 0.22,
                                                green: 0.05,
                                                blue: 0.48
                                            )
                                        )

                                        Text(
                                            "Step \(displayedStepNumber) of \(orderedCurrentSteps.count)"
                                        )
                                        .font(
                                            .system(
                                                size: 12
                                            )
                                        )
                                        .foregroundColor(
                                            Color(
                                                red: 0.5,
                                                green: 0.4,
                                                blue: 0.6
                                            )
                                        )

                                        GeometryReader {
                                            geo in

                                            ZStack(
                                                alignment: .leading
                                            ) {

                                                Capsule()
                                                    .fill(
                                                        Color.gray
                                                            .opacity(
                                                                0.2
                                                            )
                                                    )
                                                    .frame(
                                                        height: 4
                                                    )

                                                Capsule()
                                                    .fill(
                                                        Color(
                                                            red: 0.45,
                                                            green: 0.35,
                                                            blue: 0.6
                                                        )
                                                    )
                                                    .frame(
                                                        width:
                                                            geo.size.width
                                                            * progressValue,
                                                        height: 4
                                                    )

                                                Circle()
                                                    .fill(
                                                        Color(
                                                            red: 0.3,
                                                            green: 0.15,
                                                            blue: 0.45
                                                        )
                                                    )
                                                    .frame(
                                                        width: 8,
                                                        height: 8
                                                    )
                                                    .offset(
                                                        x:
                                                            max(
                                                                geo.size.width
                                                                * progressValue
                                                                - 4,
                                                                0
                                                            )
                                                    )
                                            }
                                        }
                                        .frame(height: 8)
                                        .padding(.top, 4)
                                    }

                                    Spacer(
                                        minLength: 0
                                    )
                                }

                                // MARK: Continue Task Button

                                Button {

                                    goToFocusTask =
                                        true

                                } label: {

                                    HStack(
                                        spacing: 4
                                    ) {

                                        Text(
                                            "Continue Task"
                                        )
                                        .font(
                                            .system(
                                                size: 12,
                                                weight: .medium
                                            )
                                        )

                                        Image(
                                            systemName:
                                                "chevron.right"
                                        )
                                        .font(
                                            .system(
                                                size: 9,
                                                weight: .bold
                                            )
                                        )
                                    }
                                    .foregroundStyle(
                                        .white
                                    )
                                    .padding(
                                        .vertical,
                                        8
                                    )
                                    .padding(
                                        .horizontal,
                                        16
                                    )
                                }
                                .buttonStyle(
                                    ContinueButtonStyle(
                                        color:
                                            Color(
                                                red: 0.45,
                                                green: 0.38,
                                                blue: 0.58
                                            )
                                    )
                                )
                            }
                            .padding(18)
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                            .background(
                                Color(
                                    red: 0.95,
                                    green: 0.93,
                                    blue: 0.94
                                )
                            )
                            .cornerRadius(22)
                        }
                        .padding(
                            .horizontal,
                            24
                        )
                    }
                }
                .padding(
                    .bottom,
                    110
                )
            }
        }

        .navigationBarBackButtonHidden(
            true
        )

        // MARK: - Suggestion Feature

        .navigationDestination(
            isPresented:
                $showSuggestionCategories
        ) {

            SuggestionCategoryView()
        }

        // MARK: - Continue Pending Planning

        .navigationDestination(
            isPresented:
                $goToPendingPlanning
        ) {

            if let selectedPendingPlanningSessionID {

                MyTasksView(
                    sessionID:
                        selectedPendingPlanningSessionID
                )

            } else {

                EmptyView()
            }
        }

        // MARK: - Continue Current Task

        .navigationDestination(
            isPresented:
                $goToFocusTask
        ) {

            if let currentPlannedTask {

                FocusOneStep(
                    task:
                        currentPlannedTask
                )
            }
        }

        // MARK: - Notification State

        .onAppear {

            refreshNotificationState()
        }

        // MARK: - Notifications Denied Alert

        .alert(
            "Notifications Are Off",
            isPresented:
                $showNotificationDeniedAlert
        ) {

            Button(
                "Open Settings"
            ) {

                NotificationManager
                    .shared
                    .openSettings()
            }

            Button(
                "Cancel",
                role: .cancel
            ) { }

        } message: {

            Text(
                "Allow notifications in Settings to receive task reminders and encouraging messages."
            )
        }
    }

    // MARK: - Notification Button

    private func handleNotificationButton() {

        Task {

            if notificationsEnabled {

                NotificationManager
                    .shared
                    .disableNotifications()

                await MainActor.run {

                    notificationsEnabled =
                        false

                    notificationsAuthorized =
                        false
                }

                return
            }

            let status =
                await NotificationManager
                    .shared
                    .authorizationStatus()

            if status == .denied {

                await MainActor.run {

                    showNotificationDeniedAlert =
                        true
                }

                return
            }

            do {

                let enabled =
                    try await
                    NotificationManager
                        .shared
                        .enableNotifications(
                            hasIncompleteTasks:
                                hasIncompleteTasks
                        )

                await MainActor.run {

                    notificationsEnabled =
                        enabled

                    notificationsAuthorized =
                        enabled
                }

            } catch {

                print(
                    "Failed to enable notifications: \(error)"
                )
            }
        }
    }

    // MARK: - Refresh Notification State

    private func refreshNotificationState() {

        Task {

            let status =
                await NotificationManager
                    .shared
                    .authorizationStatus()

            let authorized =
                status == .authorized
                ||
                status == .provisional
                ||
                status == .ephemeral

            await MainActor.run {

                notificationsAuthorized =
                    authorized

                if !authorized {

                    notificationsEnabled =
                        false
                }
            }

            if authorized &&
                notificationsEnabled {

                await NotificationManager
                    .shared
                    .refreshNotifications(
                        hasIncompleteTasks:
                            hasIncompleteTasks
                    )
            }
        }
    }
}


// MARK: - Continue Button Style

struct ContinueButtonStyle: ButtonStyle {

    let color: Color

    func makeBody(
        configuration: Configuration
    ) -> some View {

        configuration.label
            .background(
                Capsule()
                    .fill(
                        configuration.isPressed
                        ? Color(
                            red: 0.337,
                            green: 0.239,
                            blue: 0.416
                        )
                        : color
                    )
            )
            .scaleEffect(
                configuration.isPressed
                ? 0.97
                : 1
            )
            .animation(
                .easeOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        HomeView()
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
