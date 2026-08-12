import SwiftUI
import SwiftData

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

struct MultipleTaks: View {

    @Environment(\.dismiss) private var dismiss

    // المهام الحقيقية الناتجة من الـ AI
    let tasks: [PlannedTask]

    // نخزن رقم المهمة المختارة
    @State private var selectedTaskIndex: Int? = nil

    @State private var goToSelectedTask = false

    private var isTaskSelected: Bool {
        selectedTaskIndex != nil
    }

    private var selectedTask: PlannedTask? {
        guard let selectedTaskIndex,
              tasks.indices.contains(selectedTaskIndex)
        else {
            return nil
        }

        return tasks[selectedTaskIndex]
    }

    var body: some View {

        ZStack {

            Color.backgroundColor
                .ignoresSafeArea()

            VStack {

                // MARK: - Top Bar

                HStack {

                    // MARK: Back Button

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
                            .contentShape(
                                Rectangle()
                            )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // MARK: Home Button

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
                            .contentShape(
                                Rectangle()
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Spacer()
                    .frame(height: 20)

                // MARK: - Title

                Text("Your Plan for Today")
                    .font(
                        .system(
                            size: 34,
                            weight: .medium
                        )
                    )
                    .foregroundColor(.primaryText)

                Text("Ordered by priority & due date")
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryText)

                Spacer()
                    .frame(height: 25)

                // MARK: - Tasks

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 18) {

                        ForEach(
                            Array(tasks.enumerated()),
                            id: \.offset
                        ) { index, task in

                            PlannedTaskCard(
                                index: index,
                                task: task,
                                selectedTaskIndex:
                                    $selectedTaskIndex
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }

                // MARK: - Start Selected Task

                Button {

                    if selectedTask != nil {
                        goToSelectedTask = true
                    }

                } label: {

                    Text("Start Task")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                }
                .buttonStyle(
                    PressableCapsuleStyle(
                        fillColor: .primaryButton
                    )
                )
                .disabled(!isTaskSelected)
                .opacity(
                    isTaskSelected ? 1 : 0.55
                )
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }

        // MARK: - Selected Task Navigation

        .navigationDestination(
            isPresented: $goToSelectedTask
        ) {

            if let selectedTask {

                PlanOneTask(
                    task: selectedTask,
                    onBack: {
                        goToSelectedTask = false
                    }
                )
            }
        }

        .toolbar(
            .hidden,
            for: .navigationBar
        )
    }
}


// MARK: - Task Card

struct PlannedTaskCard: View {

    let index: Int
    let task: PlannedTask

    @Binding var selectedTaskIndex: Int?

    private var isSelected: Bool {
        selectedTaskIndex == index
    }

    var body: some View {

        Button {

            selectedTaskIndex = index

        } label: {

            HStack {

                Text(task.title)
                    .foregroundColor(
                        .secondaryText
                    )

                Spacer()

                Text(
                    "\(task.steps.count) Steps"
                )
                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )
                .foregroundColor(
                    .secondaryText
                )
                .padding(
                    .horizontal,
                    12
                )
                .padding(
                    .vertical,
                    6
                )
                .background(
                    isSelected
                    ? Color.offWhiteCapsule
                    : Color.selectedCard
                )
                .clipShape(
                    Capsule()
                )
            }
            .padding(.horizontal, 20)
            .frame(height: 65)
            .background(
                isSelected
                ? Color.selectedCard
                : Color.cardColor
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}
