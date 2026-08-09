import SwiftUI
import SwiftData

struct TaskListView: View {

    // MARK: - User Tasks

    @Query(
        sort: \UserTask.createdAt,
        order: .reverse
    )
    private var allTasks: [UserTask]

    // MARK: - Planned Tasks

    @Query(
        sort: \PlannedTask.order
    )
    private var plannedTasks: [PlannedTask]

    // فقط المهام التي تم تخطيطها فعليًا
    private var tasks: [UserTask] {
        allTasks.filter {
            // true = مخططة
            // nil = مهمة قديمة قبل إضافة isPlanned
            $0.isPlanned != false
        }
    }

    // MARK: - Filters

    @State private var selectedTab = "All"

    let tabs = [
        "All",
        "In Progress",
        "Completed",
        "Not Started"
    ]

    private var filteredTasks: [UserTask] {

        if selectedTab == "All" {
            return tasks
        }

        return tasks.filter {
            $0.status == selectedTab
        }
    }

    // MARK: - Navigation

    @State private var selectedPlannedTask: PlannedTask? = nil
    @State private var goToPlanTask = false
    @State private var goToFocusTask = false

    // MARK: - Date Formatter

    private var dateFormatter: DateFormatter {

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"

        return formatter
    }

    var body: some View {

        ZStack {

            Color(
                red: 0.98,
                green: 0.96,
                blue: 0.93
            )
            .ignoresSafeArea()

            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                // MARK: - Title

                Text("My Tasks")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .foregroundColor(
                        Color(hex: "#4B2E83")
                    )
                    .padding(.top, 30)

                // MARK: - Filter Tabs

                HStack(spacing: 8) {

                    ForEach(
                        tabs,
                        id: \.self
                    ) { tab in

                        Button {

                            withAnimation(
                                .easeInOut
                            ) {
                                selectedTab = tab
                            }

                        } label: {

                            Text(tab)
                                .font(
                                    .system(size: 10)
                                )
                                .foregroundColor(
                                    selectedTab == tab
                                    ? Color(
                                        red: 117/255,
                                        green: 96/255,
                                        blue: 142/255
                                    )
                                    : .gray
                                )
                                .padding(
                                    .vertical,
                                    8
                                )
                                .padding(
                                    .horizontal,
                                    12
                                )
                                .background(
                                    selectedTab == tab
                                    ? Color(
                                        red: 123/255,
                                        green: 0/255,
                                        blue: 255/255
                                    )
                                    .opacity(0.10)
                                    : Color.clear
                                )
                                .cornerRadius(10)
                        }

                        if tab != tabs.last {

                            Divider()
                                .frame(height: 20)
                        }
                    }
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 8
                )
                .padding(.top, 20)

                // MARK: - Tasks

                ScrollView(
                    showsIndicators: false
                ) {

                    LazyVStack(
                        spacing: 14
                    ) {

                        if filteredTasks.isEmpty {

                            Text(
                                emptyMessage
                            )
                            .font(
                                .system(size: 15)
                            )
                            .foregroundColor(.gray)
                            .frame(
                                maxWidth: .infinity
                            )
                            .padding(.top, 70)

                        } else {

                            ForEach(
                                filteredTasks
                            ) { task in

                                Button {

                                    openTask(task)

                                } label: {

                                    taskCard(task)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }

        .navigationBarBackButtonHidden(true)

        // MARK: - Open Task Plan

        .navigationDestination(
            isPresented: $goToPlanTask
        ) {

            if let selectedPlannedTask {

                PlanOneTask(
                    task: selectedPlannedTask
                )
            }
        }

        // MARK: - Resume In Progress Task

        .navigationDestination(
            isPresented: $goToFocusTask
        ) {

            if let selectedPlannedTask {

                FocusOneStep(
                    task: selectedPlannedTask
                )
            }
        }
    }

    // MARK: - Open Task

    private func openTask(
        _ userTask: UserTask
    ) {

        guard let plannedTask =
                matchingPlannedTask(
                    for: userTask
                )
        else {

            print(
                "No PlannedTask found for \(userTask.title)"
            )

            return
        }

        selectedPlannedTask =
            plannedTask

        switch userTask.status {

        case "In Progress":

            // يكمل من أول Step غير مكتملة
            // FocusOneStep عندك يسوي هذا في onAppear
            goToFocusTask = true

        case "Not Started":

            // يشوف الخطة أول
            goToPlanTask = true

        case "Completed":

            // نعرض الخطة للقراءة
            goToPlanTask = true

        default:

            goToPlanTask = true
        }
    }

    // MARK: - Find Matching PlannedTask

    private func matchingPlannedTask(
        for userTask: UserTask
    ) -> PlannedTask? {

        let normalizedTitle =
            userTask.title
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        // أولًا نستخدم Session ID
        if let sessionID =
            userTask.planningSessionID {

            if let exactMatch =
                plannedTasks.first(
                    where: {

                        $0.planningSessionID
                        ==
                        sessionID

                        &&

                        $0.title
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .lowercased()
                        ==
                        normalizedTitle
                    }
                ) {

                return exactMatch
            }
        }

        // Fallback للمهام القديمة
        return plannedTasks.first {

            $0.title
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()
            ==
            normalizedTitle
        }
    }

    // MARK: - Task Card

    @ViewBuilder
    private func taskCard(
        _ task: UserTask
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            HStack {

                Text(task.title)
                    .font(
                        .system(
                            size: 18,
                            weight: .medium
                        )
                    )
                    .foregroundColor(
                        Color(hex: "4B2A72")
                    )
                    .multilineTextAlignment(
                        .leading
                    )

                Spacer()

                Text(task.status)
                    .font(
                        .system(
                            size: 11,
                            weight: .medium
                        )
                    )
                    .foregroundColor(
                        statusColor(
                            task.status
                        )
                    )
            }

            HStack {

                if let dueDate =
                    task.dueDate {

                    Text(
                        dateFormatter.string(
                            from: dueDate
                        )
                    )
                    .font(
                        .system(size: 15)
                    )
                    .foregroundColor(.gray)

                } else {

                    Text(
                        "No due date"
                    )
                    .font(
                        .system(size: 15)
                    )
                    .foregroundColor(.gray)
                }

                Spacer()

                // يوضح أن الكارد قابل للضغط
                Image(
                    systemName: "chevron.right"
                )
                .font(
                    .system(
                        size: 12,
                        weight: .semibold
                    )
                )
                .foregroundColor(
                    .gray.opacity(0.7)
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(20)
        .background(
            Color.white
        )
        .cornerRadius(22)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8
        )
        .contentShape(
            Rectangle()
        )
    }

    // MARK: - Status Color

    private func statusColor(
        _ status: String
    ) -> Color {

        switch status {

        case "Completed":
            return .green

        case "In Progress":
            return .orange

        case "Not Started":
            return .gray

        default:
            return .gray
        }
    }

    // MARK: - Empty Message

    private var emptyMessage: String {

        switch selectedTab {

        case "Completed":
            return "No completed tasks yet"

        case "In Progress":
            return "No tasks in progress"

        case "Not Started":
            return "No tasks waiting to be started"

        default:
            return "No tasks yet"
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        TaskListView()
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
