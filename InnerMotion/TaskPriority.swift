//
//  EditTaskView.swift
//  team15
//

import SwiftUI

enum TaskPriority: String, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var dotColor: Color {
        switch self {
        case .high: return Color(red: 0.933, green: 0.561, blue: 0.561)   // EE8F8F
        case .medium: return Color(red: 0.910, green: 0.663, blue: 0.043) // E8A90B
        case .low: return Color(red: 0.004, green: 0.588, blue: 0.082)    // 019615
        }
    }
}

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var taskDescription: String = "Study for math test"
    @State private var selectedPriority: TaskPriority? = nil
    @State private var dueDate: Date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 1)) ?? Date()
    @State private var showDatePicker = false

    private var isFormComplete: Bool {
        !taskDescription.trimmingCharacters(in: .whitespaces).isEmpty && selectedPriority != nil
    }

    private let primary = Color(red: 0.216, green: 0.0, blue: 0.541)     // 37008A
    private let secondary = Color(red: 0.337, green: 0.239, blue: 0.416) // 563D6A
    private let buttonColor = Color(red: 0.459, green: 0.376, blue: 0.557) // 75608E
    private let pageBackground = Color(red: 0.996, green: 0.969, blue: 0.945) // FEF7F1
    private let fieldBackground = Color.black.opacity(0.04)
    private let selectedBackground = Color(red: 0.910, green: 0.867, blue: 0.965) // E8DDF6

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Scrollable content (everything except the bottom button)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Title
                        VStack(spacing: 4) {
                            Text("Edit your task")
                                .font(.system(size: 34, weight: .regular))
                                .foregroundStyle(primary)
                            Text("add one task pair time")
                                .font(.system(size: 16))
                                .foregroundStyle(secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        // Task Description
                        Text("Task Description")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(primary)
                            .padding(.top, 32)

                        TextField("Enter task description", text: $taskDescription)
                            .font(.system(size: 16))
                            .foregroundStyle(secondary)
                            .padding(18)
                            .background(fieldBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.top, 10)

                        // Priority
                        Text("Priority")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(primary)
                            .padding(.top, 28)

                        HStack(spacing: 10) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Button(action: {
                                    selectedPriority = priority
                                }) {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(priority.dotColor)
                                            .frame(width: 10, height: 10)
                                        Text(priority.rawValue)
                                            .font(.system(size: 15))
                                            .foregroundStyle(priority.dotColor)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(selectedPriority == priority ? selectedBackground : fieldBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                }
                            }
                        }
                        .padding(.top, 10)

                        // Due date
                        Text("Due date (optional )")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(primary)
                            .padding(.top, 28)

                        Button(action: {
                            showDatePicker = true
                        }) {
                            HStack {
                                Text(dateFormatter.string(from: dueDate))
                                    .font(.system(size: 16))
                                    .foregroundStyle(secondary)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundStyle(primary)
                            }
                            .padding(18)
                            .background(fieldBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                // Edit the task button - pinned to the bottom of the screen
                Button(action: {
                    // TODO: persist the edited task (taskDescription, selectedPriority, dueDate)
                    // to your actual data source/model here before dismissing.
                    if let selectedPriority {
                        print("Saving task: \(taskDescription), priority: \(selectedPriority.rawValue), due: \(dateFormatter.string(from: dueDate))")
                    }
                    dismiss()
                }) {
                    Text("Edit the task")
                        .font(Font.title3.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(buttonColor)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                }
                .disabled(!isFormComplete)
                .opacity(isFormComplete ? 1 : 0.55)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(buttonColor)
                    .padding()

                Button(action: {
                    showDatePicker = false
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(buttonColor)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    EditTaskView()
}
