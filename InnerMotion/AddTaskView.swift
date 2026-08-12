//
//  AddTaskView.swift
//  InnerMotion
//
//  Created by Renad Sameer Alharbi on 22/02/1448 AH.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Planning Session

    // كل مرة نفتح AddTaskView من الهوم بدون تمرير ID
    // تبدأ جلسة جديدة تلقائيًا.
    // وإذا جينا من Add Another Task نمرر نفس الـ ID.
    @State private var sessionID: UUID

    init(sessionID: UUID? = nil) {
        _sessionID = State(
            initialValue: sessionID ?? UUID()
        )
    }
    // MARK: - Keyboard

    @FocusState private var isTaskFieldFocused: Bool

    // MARK: - Navigation

    @State private var navigateToMyTasks = false

    // MARK: - User Input

    @State private var taskDescription: String = ""
    @State private var selectedPriority: TaskPriority? = nil
    @State private var dueDate: Date? = nil

    @State private var showDatePicker = false
    @State private var tempDate: Date = Date()

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

    private let fieldBackground =
        Color.black.opacity(0.04)

    private let selectedBackground = Color(
        red: 0.910,
        green: 0.867,
        blue: 0.965
    )

    private var dateFormatter: DateFormatter {

        let formatter = DateFormatter()

        formatter.dateFormat = "d MMM yyyy"

        return formatter
    }

    // MARK: - Minimum selectable date (بداية اليوم — يمنع اختيار تاريخ راح)
    private var minimumSelectableDate: Date {
        Calendar.current.startOfDay(for: Date())
    }

    var body: some View {

        ZStack {

            pageBackground
                .ignoresSafeArea()

            // MARK: - Navigate To My Tasks

            NavigationLink(
                destination:
                    MyTasksView(
                        sessionID: sessionID
                    ),
                isActive:
                    $navigateToMyTasks
            ) {

                EmptyView()
            }

            VStack(spacing: 0) {

                // MARK: - Back Button

                HStack {

                    Button {

                        isTaskFieldFocused = false

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

                // MARK: - Content

                ScrollView(
                    showsIndicators: false
                ) {

                    VStack(
                        alignment: .leading,
                        spacing: 0
                    ) {

                        // MARK: Title

                        VStack(spacing: 6) {

                            Text("Add your task")
                                .font(
                                    .system(
                                        size: 34,
                                        weight: .regular
                                    )
                                )
                                .foregroundStyle(primary)

                            Text(
                                "add one task pair time"
                            )
                            .font(.system(size: 16))
                            .foregroundStyle(secondary)
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(.top, 8)

                        // MARK: Task Description

                        Text("Task Description")
                            .font(
                                .system(
                                    size: 18,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(primary)
                            .padding(.top, 32)

                        ZStack(
                            alignment: .topLeading
                        ) {

                            if taskDescription.isEmpty {

                                Text(
                                    "add your task here..."
                                )
                                .font(.system(size: 16))
                                .foregroundStyle(
                                    secondary.opacity(
                                        0.6
                                    )
                                )
                                .padding(
                                    .horizontal,
                                    18
                                )
                                .padding(
                                    .vertical,
                                    18
                                )
                                .allowsHitTesting(
                                    false
                                )
                            }

                            TextEditor(
                                text:
                                    $taskDescription
                            )
                            .font(
                                .system(size: 16)
                            )
                            .foregroundStyle(primary)
                            .scrollContentBackground(
                                .hidden
                            )
                            .padding(
                                .horizontal,
                                14
                            )
                            .padding(
                                .vertical,
                                10
                            )
                            .focused(
                                $isTaskFieldFocused
                            )
                        }
                        .frame(height: 110)
                        .background(
                            fieldBackground
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 18
                            )
                        )
                        .padding(.top, 10)

                        // MARK: - Priority

                        Text("Priority")
                            .font(
                                .system(
                                    size: 18,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(primary)
                            .padding(.top, 28)

                        HStack(spacing: 10) {

                            ForEach(
                                TaskPriority.allCases,
                                id: \.self
                            ) { priority in

                                Button {

                                    isTaskFieldFocused =
                                        false

                                    selectedPriority =
                                        priority

                                } label: {

                                    HStack(spacing: 6) {

                                        Circle()
                                            .fill(
                                                priority
                                                    .dotColor
                                            )
                                            .frame(
                                                width: 10,
                                                height: 10
                                            )

                                        Text(
                                            priority.rawValue
                                        )
                                        .font(
                                            .system(
                                                size: 15
                                            )
                                        )
                                        .foregroundStyle(
                                            selectedPriority
                                                == priority
                                            ? primary
                                            : priority
                                                .dotColor
                                        )
                                    }
                                    .padding(
                                        .horizontal,
                                        18
                                    )
                                    .padding(
                                        .vertical,
                                        12
                                    )
                                    .background(
                                        selectedPriority
                                            == priority
                                        ? selectedBackground
                                        : fieldBackground
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius:
                                                24
                                        )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 10)

                        // MARK: - Due Date

                        Text(
                            "Due date (optional )"
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(primary)
                        .padding(.top, 28)

                        Button {

                            isTaskFieldFocused =
                                false

                            // نبدأ التاريخ المؤقت من اليوم (أو من التاريخ المختار سابقًا لو موجود)
                            tempDate = dueDate ?? minimumSelectableDate

                            showDatePicker = true

                        } label: {

                            HStack {

                                Text(
                                    dueDate != nil
                                    ? dateFormatter
                                        .string(
                                            from:
                                                dueDate!
                                        )
                                    : "Select a date"
                                )
                                .font(
                                    .system(size: 16)
                                )
                                .foregroundStyle(
                                    dueDate != nil
                                    ? primary
                                    : secondary
                                        .opacity(0.7)
                                )

                                Spacer()

                                Image(
                                    systemName:
                                        "calendar"
                                )
                                .font(
                                    .system(size: 20)
                                )
                                .foregroundStyle(
                                    primary
                                )
                            }
                            .padding(18)
                            .background(
                                fieldBackground
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 18
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 10)
                    }
                    .padding(
                        .horizontal,
                        24
                    )
                    .padding(
                        .bottom,
                        24
                    )
                }
                .scrollDismissesKeyboard(
                    .interactively
                )

                // MARK: - Add Task Button

                Button {

                    isTaskFieldFocused = false

                    saveTask()

                } label: {

                    Text("Add the task")
                        .font(
                            Font.title3.bold()
                        )
                        .foregroundStyle(.white)
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(
                            .vertical,
                            18
                        )
                        .background(
                            buttonColor
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 32
                            )
                        )
                }
                .buttonStyle(.plain)
                .padding(
                    .horizontal,
                    24
                )
                .padding(
                    .bottom,
                    24
                )
            }
        }

        .navigationBarHidden(true)

        // الزر يضل ثابت تحت — ما يطلع فوق الكيبورد
        .ignoresSafeArea(.keyboard, edges: .bottom)

        // MARK: - Date Picker

        .sheet(
            isPresented:
                $showDatePicker
        ) {

            VStack {

                DatePicker(
                    "Due date",
                    selection:
                        $tempDate,
                    in: minimumSelectableDate...,
                    displayedComponents:
                        .date
                )
                .datePickerStyle(
                    .graphical
                )
                .tint(buttonColor)
                .padding()

                Button {

                    dueDate = tempDate

                    showDatePicker =
                        false

                } label: {

                    Text("Done")
                        .font(
                            .system(
                                size: 16,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            .white
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(
                            .vertical,
                            14
                        )
                        .background(
                            buttonColor
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 24
                            )
                        )
                }
                .buttonStyle(.plain)
                .padding(
                    .horizontal
                )
                .padding(
                    .bottom,
                    24
                )
            }
            .presentationDetents(
                [.medium]
            )
        }
    }

    // MARK: - Save Task To SwiftData

    private func saveTask() {

        let cleanTitle =
            taskDescription
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        guard
            !cleanTitle.isEmpty,
            let selectedPriority
        else {
            return
        }

        let newTask = UserTask(

            title:
                cleanTitle,

            priority:
                selectedPriority.rawValue,

            dueDate:
                dueDate,

            status:
                "Not Started",

            planningSessionID:
                sessionID,

            // لسه ما خلص AI منها
            isPlanned:
                false
        )

        modelContext.insert(
            newTask
        )

        do {

            try modelContext.save()

            print(
                "Task saved to session \(sessionID): \(cleanTitle)"
            )

            navigateToMyTasks =
                true

        } catch {

            print(
                "Failed to save task: \(error)"
            )
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        AddTaskView()
    }
    .modelContainer(
        for:
            UserTask.self,
        inMemory: true
    )
}
