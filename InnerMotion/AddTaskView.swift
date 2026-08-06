//
//  AddTaskView.swift
//  InnerMotion
//
//  Created by Renad Sameer Alharbi on 22/02/1448 AH.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss

    // حالات حفظ البيانات المربعة من الواجهة
    @State private var taskDescription: String = ""
    @State private var selectedPriority: TaskPriority? = nil // يربط مع Enum الموحد بالمرشح
    @State private var dueDate: Date? = nil
    @State private var showDatePicker = false
    @State private var tempDate: Date = Date()

    // الألوان المستخرجة من تصميم مشروعك
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
                // Back button (زر الرجوع للهوم بيج)
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

                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // Title Section
                        VStack(spacing: 6) {
                            Text("Add your task")
                                .font(.system(size: 34, weight: .regular))
                                .foregroundStyle(primary)
                            
                            Text("add one task pair time")
                                .font(.system(size: 16))
                                .foregroundStyle(secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        // Task Description Input
                        Text("Task Description")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(primary)
                            .padding(.top, 32)

                        ZStack(alignment: .topLeading) {
                            if taskDescription.isEmpty {
                                Text("add your task here...")
                                    .font(.system(size: 16))
                                    .foregroundStyle(secondary.opacity(0.6))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 18)
                            }
                            
                            TextEditor(text: $taskDescription)
                                .font(.system(size: 16))
                                .foregroundStyle(primary)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                        }
                        .frame(height: 110)
                        .background(fieldBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.top, 10)

                        // Priority Selector
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
                                            .foregroundStyle(selectedPriority == priority ? primary : priority.dotColor)
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 12)
                                    .background(selectedPriority == priority ? selectedBackground : fieldBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                }
                            }
                        }
                        .padding(.top, 10)

                        // Due Date Selector
                        Text("Due date (optional )")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(primary)
                            .padding(.top, 28)

                        Button(action: {
                            showDatePicker = true
                        }) {
                            HStack {
                                Text(dueDate != nil ? dateFormatter.string(from: dueDate!) : "Select a date")
                                    .font(.system(size: 16))
                                    .foregroundStyle(dueDate != nil ? primary : secondary.opacity(0.7))
                                
                                Spacer()
                                
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
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

                // Add Task Button (Pinned at bottom)
                Button(action: {
                    print("Task Added: \(taskDescription)")
                    dismiss()
                }) {
                    Text("Add the task")
                        .font(Font.title3.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(buttonColor)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker("Due date", selection: $tempDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(buttonColor)
                    .padding()

                Button(action: {
                    dueDate = tempDate
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
    AddTaskView()
}
