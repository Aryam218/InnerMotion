import SwiftUI

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

struct MultipleTaks: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTask: Int? = nil
    @State private var goToFocusOneStep = false

    private var isTaskSelected: Bool {
        selectedTask != nil
    }

    var body: some View {
        NavigationStack {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .buttonStyle(PressableIconStyle(normalColor: .primaryText, pressedColor: .homeActive))

                    Spacer()

                    Button {

                    } label: {
                        Image(systemName: "house")
                            .font(.title2)
                    }
                    .buttonStyle(PressableIconStyle(normalColor: .primaryText, pressedColor: .homeActive))
                }.padding(.horizontal)

                Spacer().frame(height: 20)

                Text("Your Plan for Today")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(.primaryText)

                Text("Ordered by priority & due date")
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryText)

                Spacer().frame(height: 25)

                VStack(spacing: 18) {
                    TaskCard(id: 1, title: "Make a cup of tea", steps: "4 Steps", selectedTask: $selectedTask)
                    TaskCard(id: 2, title: "Take a shower", steps: "4 Steps", selectedTask: $selectedTask)
                    TaskCard(id: 3, title: "Study for Math test", steps: "5 Steps", selectedTask: $selectedTask)
                    TaskCard(id: 4, title: "Clean the room", steps: "6 Steps", selectedTask: $selectedTask)
                }

                Spacer()

                Button {
                    goToFocusOneStep = true
                } label: {
                    Text("Start Task")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                }
                .buttonStyle(PressableCapsuleStyle(fillColor: .primaryButton))
                .disabled(!isTaskSelected)
                .opacity(isTaskSelected ? 1 : 0.55)
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                .navigationDestination(isPresented: $goToFocusOneStep) {
                    FocusOneStep()
                }
            }
            .padding(.top)
        }
        .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct TaskCard: View {
    let id: Int
    let title: String
    let steps: String
    @Binding var selectedTask: Int?

    var isSelected: Bool { selectedTask == id }

    var body: some View {
        Button {
            selectedTask = id
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(.secondaryText)
                Spacer()
                Text(steps)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isSelected ? Color.offWhiteCapsule : Color.selectedCard)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .frame(height: 65)
            .background(isSelected ? Color.selectedCard : Color.cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

#Preview {
    MultipleTaks()
}
