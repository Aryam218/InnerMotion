//
//  EditTaskView.swift
//  team15
//

import SwiftUI
import SwiftData

enum TaskPriority: String, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var dotColor: Color {
        switch self {
        case .high:
            return Color(
                red: 0.933,
                green: 0.561,
                blue: 0.561
            )

        case .medium:
            return Color(
                red: 0.910,
                green: 0.663,
                blue: 0.043
            )

        case .low:
            return Color(
                red: 0.004,
                green: 0.588,
                blue: 0.082
            )
        }
    }
}

struct EditTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // نفس المهمة الموجودة في SwiftData
    let task: UserTask

    @State private var taskDescription: String
    @State private var selectedPriority: TaskPriority?
    @State private var dueDate: Date?
    @State private var showDatePicker = false
    @State private var tempDate: Date

    init(task: UserTask) {

        self.task = task

        _taskDescription = State(
            initialValue: task.title
        )

        _selectedPriority = State(
            initialValue: TaskPriority(
                rawValue: task.priority
            )
        )

        _dueDate = State(
            initialValue: task.dueDate
        )

        _tempDate = State(
            initialValue: task.dueDate ?? Date()
        )
    }

    private var isFormComplete: Bool {

        !taskDescription
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        &&
        selectedPriority != nil
    }

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

            VStack(spacing: 0) {

                // Back button
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

                // Scrollable content
                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 0
                    ) {

                        // Title
                        VStack(spacing: 4) {

                            Text("Edit your task")
                                .font(
                                    .system(
                                        size: 34,
                                        weight: .regular
                                    )
                                )
                                .foregroundStyle(primary)

                            Text("add one task pair time")
                                .font(
                                    .system(size: 16)
                                )
                                .foregroundStyle(secondary)
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(.top, 8)

                        // Task Description
                        Text("Task Description")
                            .font(
                                .system(
                                    size: 18,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(primary)
                            .padding(.top, 32)

                        TextField(
                            "Enter task description",
                            text: $taskDescription
                        )
                        .font(.system(size: 16))
                        .foregroundStyle(secondary)
                        .padding(18)
                        .background(fieldBackground)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 18
                            )
                        )
                        .padding(.top, 10)

                        // Priority
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

                                    selectedPriority = priority

                                } label: {

                                    HStack(spacing: 6) {

                                        Circle()
                                            .fill(
                                                priority.dotColor
                                            )
                                            .frame(
                                                width: 10,
                                                height: 10
                                            )

                                        Text(
                                            priority.rawValue
                                        )
                                        .font(
                                            .system(size: 15)
                                        )
                                        .foregroundStyle(
                                            selectedPriority == priority
                                            ? primary
                                            : priority.dotColor
                                        )
                                    }
                                    .padding(
                                        .horizontal,
                                        16
                                    )
                                    .padding(
                                        .vertical,
                                        12
                                    )
                                    .background(
                                        selectedPriority == priority
                                        ? selectedBackground
                                        : fieldBackground
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 24
                                        )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 10)

                        // Due Date
                        Text("Due date (optional )")
                            .font(
                                .system(
                                    size: 18,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(primary)
                            .padding(.top, 28)

                        Button {

                            // نبدأ التاريخ المؤقت من اليوم (أو من التاريخ المختار سابقًا لو موجود)
                            tempDate =
                                dueDate ?? minimumSelectableDate

                            showDatePicker = true

                        } label: {

                            HStack {

                                Text(
                                    dueDate != nil
                                    ? dateFormatter.string(
                                        from: dueDate!
                                    )
                                    : "Select a date"
                                )
                                .font(
                                    .system(size: 16)
                                )
                                .foregroundStyle(
                                    dueDate != nil
                                    ? secondary
                                    : secondary.opacity(0.7)
                                )

                                Spacer()

                                Image(
                                    systemName: "calendar"
                                )
                                .foregroundStyle(primary)
                            }
                            .padding(18)
                            .background(fieldBackground)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 18
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                // Edit Task Button
                Button {

                    saveChanges()

                } label: {

                    Text("Edit the task")
                        .font(Font.title3.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(buttonColor)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 32
                            )
                        )
                }
                .buttonStyle(.plain)
                .disabled(!isFormComplete)
                .opacity(
                    isFormComplete
                    ? 1
                    : 0.55
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)

        // الزر يضل ثابت تحت — ما يطلع فوق الكيبورد
        .ignoresSafeArea(.keyboard, edges: .bottom)

        // Date Picker
        .sheet(
            isPresented: $showDatePicker
        ) {

            VStack {

                DatePicker(
                    "Due date",
                    selection: $tempDate,
                    in: minimumSelectableDate...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(buttonColor)
                .padding()

                Button {

                    dueDate = tempDate
                    showDatePicker = false

                } label: {

                    Text("Done")
                        .font(
                            .system(
                                size: 16,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(buttonColor)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 24
                            )
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Update SwiftData

    private func saveChanges() {

        let cleanTitle =
            taskDescription
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        guard !cleanTitle.isEmpty,
              let selectedPriority
        else {
            return
        }

        task.title = cleanTitle
        task.priority =
            selectedPriority.rawValue
        task.dueDate = dueDate

        do {

            try modelContext.save()

            print(
                "Task updated: \(task.title)"
            )

            dismiss()

        } catch {

            print(
                "Failed to update task: \(error)"
            )
        }
    }
}
