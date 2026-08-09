import SwiftUI
import SwiftData

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

struct PlanOneTask: View {

    @Environment(\.dismiss) private var dismiss

    // المهمة الحقيقية الناتجة من AI
    let task: PlannedTask

    // اختياري للتحكم بزر الرجوع
    var onBack: (() -> Void)? = nil

    @State private var goToFocusOneStep = false

    private var orderedSteps: [TaskStep] {
        task.steps.sorted {
            $0.order < $1.order
        }
    }

    var body: some View {

        ZStack {

            Color.backgroundColor
                .ignoresSafeArea()

            VStack {

                // MARK: - Top Bar

                HStack {

                    Button {

                        if let onBack {
                            onBack()
                        } else {
                            dismiss()
                        }

                    } label: {

                        Image(
                            systemName: "chevron.left"
                        )
                        .font(.title2)
                    }
                    .buttonStyle(
                        PressableIconStyle(
                            normalColor: .primaryText,
                            pressedColor: .secondaryButton
                        )
                    )

                    Spacer()

                    NavigationLink {
                        MainTabView()
                    } label: {

                        Image(
                            systemName: "house"
                        )
                        .font(
                            .system(size: 28)
                        )
                    }
                    .buttonStyle(
                        PressableIconStyle(
                            normalColor: .primaryText,
                            pressedColor: .secondaryButton
                        )
                    )
                }
                .padding(.horizontal, 25)
                .padding(.top, 15)

                Spacer()
                    .frame(height: 25)

                // MARK: - Title

                Text("Your first steps")
                    .font(
                        .system(
                            size: 34,
                            weight: .medium
                        )
                    )
                    .foregroundColor(
                        .primaryText
                    )

                Text(
                    "Tiny steps to get you moving"
                )
                .font(.system(size: 17))
                .foregroundColor(
                    .secondaryText
                )

                Spacer()
                    .frame(height: 35)

                // MARK: - Task Title

                RoundedRectangle(
                    cornerRadius: 18
                )
                .fill(Color.cardColor)
                .frame(height: 65)
                .overlay(

                    HStack {

                        Text(task.title)
                            .foregroundColor(
                                .secondaryText
                            )
                            .font(
                                .system(size: 21)
                            )

                        Spacer()
                    }
                    .padding(
                        .horizontal,
                        20
                    )
                )
                .padding(.horizontal)

                Spacer()
                    .frame(height: 25)

                // MARK: - AI Generated Steps

                ScrollView(
                    showsIndicators: false
                ) {

                    VStack(spacing: 12) {

                        ForEach(
                            orderedSteps
                        ) { step in

                            StepCard(
                                number:
                                    "\(step.order)",
                                text:
                                    step.text,
                                highlight:
                                    step.order == 1
                            )
                        }
                    }
                }

                Spacer(
                    minLength: 20
                )

                // MARK: - Start First Step

                Button {

                    if !orderedSteps.isEmpty {
                        goToFocusOneStep = true
                    }

                } label: {

                    Text("Start First Step")
                        .font(
                            .system(size: 28)
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                        .frame(height: 60)
                }
                .buttonStyle(
                    PressableCapsuleStyle(
                        fillColor: .primaryButton
                    )
                )
                .disabled(
                    orderedSteps.isEmpty
                )
                .opacity(
                    orderedSteps.isEmpty
                    ? 0.55
                    : 1
                )
                .padding(
                    .horizontal,
                    35
                )

                .navigationDestination(
                    isPresented:
                        $goToFocusOneStep
                ) {

                    // بنعدله بعدين ليستقبل
                    // الخطوة الحقيقية
                    FocusOneStep(task: task)
                }

                // MARK: - Make It Easier

                Button {

                    // بنربطه لاحقًا بالـ AI
                    // لإعادة تقسيم نفس المهمة
                    // إلى خطوات أسهل

                } label: {

                    Text("Make it Easier")
                        .font(
                            .system(size: 28)
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                        .frame(height: 60)
                }
                .buttonStyle(
                    PressableCapsuleStyle(
                        fillColor:
                            .secondaryButton
                    )
                )
                .padding(
                    .horizontal,
                    35
                )
                .padding(
                    .bottom,
                    35
                )
            }
        }
        .toolbar(
            .hidden,
            for: .navigationBar
        )
    }
}


// MARK: - Step Card

struct StepCard: View {

    var number: String
    var text: String
    var highlight = false

    var body: some View {

        RoundedRectangle(
            cornerRadius: 18
        )
        .fill(
            highlight
            ? Color.selectedCard
            : Color.cardColor
        )
        .frame(height: 70)
        .overlay(

            HStack(spacing: 18) {

                Circle()
                    .stroke(
                        Color.secondaryText,
                        lineWidth: 2
                    )
                    .frame(
                        width: 38,
                        height: 38
                    )
                    .overlay(

                        Text(number)
                            .foregroundColor(
                                .secondaryText
                            )
                    )

                Text(text)
                    .foregroundColor(
                        .secondaryText
                    )
                    .font(
                        .system(size: 20)
                    )

                Spacer()
            }
            .padding(
                .horizontal,
                18
            )
        )
        .padding(.horizontal)
    }
}
