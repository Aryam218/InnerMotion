//
//  MyTasksView.swift
//  team15
//

import SwiftUI
import SwiftData

struct MyTasksView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Current Planning Session

    let sessionID: UUID

    // كل المهام المحفوظة تاريخيًا
    @Query(
        sort: \UserTask.createdAt,
        order: .reverse
    )
    private var allTasks: [UserTask]

    // فقط مهام الجلسة الحالية
    private var tasks: [UserTask] {

        allTasks.filter {

            $0.planningSessionID ==
                sessionID
        }
    }

    @State private var isContinuePressed =
        false

    @State private var isHomePressed =
        false

    @State private var navigateHome =
        false

    // MARK: - Colors

    private let primary = Color(
        red: 0.216,
        green: 0.0,
        blue: 0.541
    )

    private let secondary = Color(
        red: 0.337,
        green: 0.239,
        blue: 0.416
    )

    private let buttonColor = Color(
        red: 0.459,
        green: 0.376,
        blue: 0.557
    )

    private let pageBackground = Color(
        red: 0.996,
        green: 0.969,
        blue: 0.945
    )

    var body: some View {

        NavigationStack {

            ZStack {

                pageBackground
                    .ignoresSafeArea()

                // MARK: - Navigate Home

                NavigationLink(
                    destination:
                        MainTabView(),
                    isActive:
                        $navigateHome
                ) {

                    EmptyView()
                }

                VStack {

                    // MARK: - Top Bar

                    HStack {

                        // Back
                        Button {

                            dismiss()

                        } label: {

                            Image(
                                systemName:
                                    "chevron.left"
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
                        .buttonStyle(.plain)

                        Spacer()

                        // Home
                        Button {

                            navigateHome = true

                        } label: {

                            Image(
                                systemName:
                                    "house.fill"
                            )
                            .font(
                                .system(size: 26)
                            )
                            .foregroundStyle(
                                buttonColor
                                    .opacity(
                                        isHomePressed
                                        ? 0.5
                                        : 1.0
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(

                            DragGesture(
                                minimumDistance: 0
                            )
                            .onChanged { _ in

                                isHomePressed =
                                    true
                            }
                            .onEnded { _ in

                                isHomePressed =
                                    false
                            }
                        )
                    }
                    .padding(
                        .horizontal,
                        24
                    )
                    .padding(
                        .top,
                        16
                    )

                    // MARK: - Title

                    VStack(spacing: 4) {

                        Text("My Tasks")
                            .font(
                                .system(
                                    size: 44,
                                    weight: .regular
                                )
                            )
                            .foregroundStyle(
                                primary
                            )

                        Text(
                            "Your tasks list"
                        )
                        .font(
                            .system(size: 18)
                        )
                        .foregroundStyle(
                            secondary
                        )
                    }
                    .padding(.top, 8)

                    // MARK: - Current Session Tasks

                    ScrollView {

                        VStack(spacing: 16) {

                            ForEach(
                                tasks
                            ) { task in

                                SwipeToDeleteUserTaskCard(
                                    task: task
                                ) {

                                    deleteTask(
                                        task
                                    )
                                }
                            }
                        }
                        .padding(
                            .horizontal,
                            24
                        )
                        .padding(
                            .top,
                            32
                        )
                    }

                    // MARK: - Buttons

                    VStack(spacing: 14) {

                        // Continue
                        NavigationLink(
                            destination:
                                PlanYourDayView(
                                    sessionID: sessionID
                                )
                        ) {

                            Text("Continue")
                                .font(
                                    Font.title3
                                        .bold()
                                )
                                .foregroundStyle(
                                    isContinuePressed
                                    ? buttonColor
                                    : .white
                                )
                                .frame(
                                    maxWidth:
                                        .infinity
                                )
                                .padding(
                                    .vertical,
                                    18
                                )
                                .background(
                                    isContinuePressed
                                    ? Color.white
                                    : buttonColor
                                )
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius:
                                            32
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(
                            tasks.isEmpty
                        )
                        .opacity(
                            tasks.isEmpty
                            ? 0.55
                            : 1
                        )
                        .simultaneousGesture(

                            DragGesture(
                                minimumDistance: 0
                            )
                            .onChanged { _ in

                                isContinuePressed =
                                    true
                            }
                            .onEnded { _ in

                                isContinuePressed =
                                    false
                            }
                        )

                        // MARK: Add Another Task
                        //
                        // مهم:
                        // نمرر نفس sessionID.
                        //
                        // يعني المهمة الجديدة
                        // تنتمي لنفس المجموعة الحالية.

                        NavigationLink(
                            destination:
                                AddTaskView(
                                    sessionID:
                                        sessionID
                                )
                        ) {

                            Text(
                                "Add another task"
                            )
                            .font(
                                Font.title3.bold()
                            )
                            .foregroundStyle(
                                .white
                            )
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                            .padding(
                                .vertical,
                                18
                            )
                            .background(
                                Color(
                                    red: 0.663,
                                    green: 0.592,
                                    blue: 0.741
                                )
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 32
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(
                        .horizontal,
                        24
                    )
                    .padding(
                        .bottom,
                        40
                    )
                }
            }

            .navigationBarHidden(
                true
            )
        }
    }

    // MARK: - Delete Task

    private func deleteTask(
        _ task: UserTask
    ) {

        withAnimation(
            .easeOut(
                duration: 0.25
            )
        ) {

            modelContext.delete(
                task
            )

            do {

                try modelContext.save()

            } catch {

                print(
                    "Failed to delete task: \(error)"
                )
            }
        }
    }
}


// MARK: - Swipeable Task Card

private struct SwipeToDeleteUserTaskCard: View {

    let task: UserTask

    var onDelete: () -> Void

    @State private var offset:
        CGFloat = 0

    @State private var isSwipeOpen =
        false

    private let deleteButtonWidth:
        CGFloat = 90

    private let primary = Color(
        red: 0.216,
        green: 0.0,
        blue: 0.541
    )

    private let buttonColor = Color(
        red: 0.459,
        green: 0.376,
        blue: 0.557
    )

    private let cardBackground = Color(
        red: 0.956,
        green: 0.930,
        blue: 0.907
    )

    private var priorityColor: Color {

        switch task.priority {

        case "High":

            return Color(
                red: 0.918,
                green: 0.522,
                blue: 0.443
            )

        case "Medium":

            return Color(
                red: 0.812,
                green: 0.659,
                blue: 0.365
            )

        case "Low":

            return Color(
                red: 0.004,
                green: 0.588,
                blue: 0.082
            )

        default:

            return .gray
        }
    }

    private var formattedDueDate:
        String {

        guard let dueDate =
                task.dueDate
        else {

            return "No due date"
        }

        let formatter =
            DateFormatter()

        formatter.dateFormat =
            "d MMM yyyy"

        return formatter.string(
            from: dueDate
        )
    }

    var body: some View {

        ZStack(
            alignment: .leading
        ) {

            // MARK: Delete Panel
            // نخليه يمتد لنفس ارتفاع الكارد تلقائيًا
            // (maxHeight: .infinity) بدل رقم ثابت،
            // عشان لو التاسك طويلة ويكبر الكارد، الديليت يكبر معاه

            Button {

                onDelete()

            } label: {

                VStack {

                    Text("Delete")
                        .font(
                            .system(
                                size: 17,
                                weight:
                                    .semibold
                            )
                        )
                        .foregroundStyle(
                            Color(
                                red: 0.8,
                                green: 0.2,
                                blue: 0.2
                            )
                        )
                }
                .frame(
                    width:
                        deleteButtonWidth
                )
                .frame(
                    maxHeight:
                        .infinity
                )
                .background(
                    Color.black
                        .opacity(0.04)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 20
                    )
                )
            }
            .buttonStyle(.plain)

            // MARK: - Task Card

            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                HStack {

                    Text(task.title)
                        .font(
                            .system(
                                size: 18,
                                weight:
                                    .semibold
                            )
                        )
                        .foregroundStyle(
                            primary
                        )

                    Spacer()

                    NavigationLink(
                        destination:
                            EditTaskView(
                                task: task
                            )
                    ) {

                        Image(
                            systemName:
                                "pencil"
                        )
                        .font(
                            .system(size: 22, weight: .medium)
                        )
                        .foregroundStyle(
                            buttonColor
                        )
                    }
                }

                HStack(spacing: 6) {

                    Text(task.status)
                        .font(
                            .system(size: 14)
                        )
                        .foregroundStyle(
                            .gray
                        )

                    Text("•")
                        .foregroundStyle(
                            .gray
                        )

                    Text(task.priority)
                        .font(
                            .system(
                                size: 14,
                                weight:
                                    .semibold
                            )
                        )
                        .foregroundStyle(
                            priorityColor
                        )
                }

                Text(
                    formattedDueDate
                )
                .font(
                    .system(
                        size: 15,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    primary
                )
            }
            .padding(20)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                cardBackground
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )
            .offset(x: offset)

            .gesture(

                DragGesture()

                    .onChanged { value in

                        let translation =
                            value
                                .translation
                                .width

                        if isSwipeOpen {

                            offset = min(
                                max(
                                    deleteButtonWidth
                                    + translation,
                                    0
                                ),
                                deleteButtonWidth
                            )

                        } else {

                            offset = min(
                                max(
                                    translation,
                                    0
                                ),
                                deleteButtonWidth
                            )
                        }
                    }

                    .onEnded { value in

                        let translation =
                            value
                                .translation
                                .width

                        withAnimation(
                            .easeOut(
                                duration:
                                    0.25
                            )
                        ) {

                            if isSwipeOpen {

                                if translation
                                    < -20 {

                                    offset = 0

                                    isSwipeOpen =
                                        false

                                } else {

                                    offset =
                                        deleteButtonWidth

                                    isSwipeOpen =
                                        true
                                }

                            } else {

                                if translation
                                    > 20 {

                                    offset =
                                        deleteButtonWidth

                                    isSwipeOpen =
                                        true

                                } else {

                                    offset = 0

                                    isSwipeOpen =
                                        false
                                }
                            }
                        }
                    }
            )
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        MyTasksView(
            sessionID: UUID()
        )
    }
    .modelContainer(
        for:
            UserTask.self,
        inMemory: true
    )
}
