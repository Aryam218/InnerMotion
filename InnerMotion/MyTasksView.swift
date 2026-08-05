//
//  MyTasksView.swift
//  team15
//

import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var category: String
    var priorityLabel: String
    var priorityColor: Color
    var dueDate: String
}

struct MyTasksView: View {
    @State private var isContinuePressed = false
    @State private var isHomePressed = false

    @State private var tasks: [TaskItem] = [
        TaskItem(
            title: "Study for math test",
            category: "Study",
            priorityLabel: "High",
            priorityColor: Color(red: 0.918, green: 0.522, blue: 0.443), // coral
            dueDate: "1 Apr 2026"
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.996, green: 0.969, blue: 0.945) // FEF7F1
                    .ignoresSafeArea()

                VStack {
                    // Top bar
                    HStack {
                        Button(action: {
                            // handle back navigation
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color(red: 0.216, green: 0.0, blue: 0.541)) // 37008A
                        }

                        Spacer()

                        Button(action: {
                            // handle home navigation
                        }) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(
                                    Color(red: 0.459, green: 0.376, blue: 0.557) // 75608E
                                        .opacity(isHomePressed ? 0.5 : 1.0)
                                )
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isHomePressed = true }
                                .onEnded { _ in isHomePressed = false }
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Title
                    VStack(spacing: 4) {
                        Text("My Tasks")
                            .font(.system(size: 44, weight: .regular))
                            .foregroundStyle(Color(red: 0.216, green: 0.0, blue: 0.541)) // 37008A

                        Text("Your tasks list")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(red: 0.337, green: 0.239, blue: 0.416)) // 563D6A
                    }
                    .padding(.top, 8)

                    // Task list - swipe left on a card to reveal Delete
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(tasks) { task in
                                SwipeToDeleteTaskCard(task: task) {
                                    deleteTask(task)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    }

                    // Buttons
                    VStack(spacing: 14) {
                        NavigationLink(destination: PlanYourDayView()) {
                            Text("Continue")
                                .font(Font.title3.bold())
                                .foregroundStyle(isContinuePressed ? Color(red: 0.459, green: 0.376, blue: 0.557) : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(isContinuePressed ? Color.white : Color(red: 0.459, green: 0.376, blue: 0.557)) // 75608E
                                .clipShape(RoundedRectangle(cornerRadius: 32))
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isContinuePressed = true }
                                .onEnded { _ in isContinuePressed = false }
                        )

                        Button(action: {
                            // handle add another task
                        }) {
                            Text("Add another task")
                                .font(Font.title3.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 0.663, green: 0.592, blue: 0.741)) // A897BD
                                .clipShape(RoundedRectangle(cornerRadius: 32))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func deleteTask(_ task: TaskItem) {
        withAnimation(.easeOut(duration: 0.25)) {
            tasks.removeAll { $0.id == task.id }
        }
    }
}

// MARK: - Swipeable Task Card

private struct SwipeToDeleteTaskCard: View {
    let task: TaskItem
    var onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isSwipeOpen = false

    private let deleteButtonWidth: CGFloat = 90
    private let primary = Color(red: 0.216, green: 0.0, blue: 0.541)       // 37008A
    private let buttonColor = Color(red: 0.459, green: 0.376, blue: 0.557) // 75608E
    // Opaque, so it fully covers the Delete panel behind it when the card is closed
    private let cardBackground = Color(red: 0.956, green: 0.930, blue: 0.907)

    var body: some View {
        ZStack(alignment: .leading) {
            // Delete panel revealed behind the card
            Button(action: {
                onDelete()
            }) {
                VStack {
                    Text("Delete")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(red: 0.8, green: 0.2, blue: 0.2))
                }
                .frame(width: deleteButtonWidth, height: 120)
                .background(Color.black.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            // Task card content, slides right to reveal Delete
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(task.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(primary)

                    Spacer()

                    NavigationLink(destination: EditTaskView()) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundStyle(buttonColor)
                    }
                }

                HStack(spacing: 6) {
                    Text(task.category)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    Text("•")
                        .foregroundStyle(.gray)
                    Text(task.priorityLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(task.priorityColor)
                }

                Text(task.dueDate)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(primary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation.width
                        if isSwipeOpen {
                            // already open, allow dragging back closed
                            offset = min(max(deleteButtonWidth + translation, 0), deleteButtonWidth)
                        } else {
                            // closed, only allow rightward drag to open
                            offset = min(max(translation, 0), deleteButtonWidth)
                        }
                    }
                    .onEnded { value in
                        let translation = value.translation.width
                        withAnimation(.easeOut(duration: 0.25)) {
                            if isSwipeOpen {
                                if translation < -20 {
                                    offset = 0
                                    isSwipeOpen = false
                                } else {
                                    offset = deleteButtonWidth
                                    isSwipeOpen = true
                                }
                            } else {
                                if translation > 20 {
                                    offset = deleteButtonWidth
                                    isSwipeOpen = true
                                } else {
                                    offset = 0
                                    isSwipeOpen = false
                                }
                            }
                        }
                    }
            )
        }
    }
}

#Preview {
    MyTasksView()
}
