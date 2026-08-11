//
//  FeedbackView.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 21/02/1448 AH.
//

import SwiftUI
import SwiftData

struct FeedbackView: View {

    // النشاط الذي بدأه المستخدم
    // ونبغى نحفظ الـ Feedback عليه
    let activity: SuggestionActivity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @State private var selectedFeedback: FeedbackOption?

    // MARK: - Saved Banner

    @State private var showSavedBanner = false

    // MARK: - Navigation

    @State private var goToHome = false

    var body: some View {

        ZStack(alignment: .top) {

            Color(hex: "FFF7F1")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Back

                HStack {

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
                }
                .padding(
                    .horizontal,
                    24
                )
                .padding(
                    .top,
                    6
                )

                // MARK: - Title

                Text("How did that feel?")
                    .font(
                        .system(
                            size: 36,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(
                        Color(hex: "37008A")
                    )
                    .multilineTextAlignment(
                        .center
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(
                        .top,
                        34
                    )

                // MARK: - Robot

                Image("feedbackRobot")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 240,
                        height: 240
                    )
                    .padding(
                        .top,
                        14
                    )

                // MARK: - Feedback Options

                VStack(spacing: 14) {

                    ForEach(
                        FeedbackOption.allCases
                    ) { option in

                        feedbackCard(
                            option
                        )
                    }
                }
                .padding(
                    .horizontal,
                    34
                )
                .padding(
                    .top,
                    28
                )

                Spacer(
                    minLength: 24
                )
            }

            // MARK: - Feedback Saved Banner

            if showSavedBanner {

                HStack(spacing: 10) {

                    Image(
                        systemName:
                            "checkmark.circle.fill"
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .medium
                        )
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {

                        Text(
                            "Feedback saved"
                        )
                        .font(
                            .system(
                                size: 15,
                                weight: .semibold
                            )
                        )

                        Text(
                            "We'll use it to personalize your suggestions."
                        )
                        .font(
                            .system(
                                size: 12,
                                weight: .regular
                            )
                        )
                    }

                    Spacer()
                }
                .foregroundStyle(
                    Color(hex: "563D6A")
                )
                .padding(
                    .horizontal,
                    16
                )
                .frame(
                    width: 340,
                    height: 62
                )
                .background(
                    RoundedRectangle(
                        cornerRadius: 14
                    )
                    .fill(
                        Color(hex: "F5F0F0")
                    )
                    .shadow(
                        color:
                            .black.opacity(0.10),
                        radius: 8,
                        x: 0,
                        y: 3
                    )
                )
                .padding(
                    .top,
                    10
                )
                .transition(
                    .move(edge: .top)
                    .combined(
                        with: .opacity
                    )
                )
                .zIndex(10)
            }
        }
        .toolbar(
            .hidden,
            for: .navigationBar
        )

        // MARK: - Navigate Home After Saving

        .navigationDestination(
            isPresented:
                $goToHome
        ) {

            MainTabView()
        }

        // لو كان النشاط عليه Feedback محفوظ سابقًا
        // نظهر اختياره عند فتح الصفحة
        .onAppear {

            if let savedFeedback =
                activity.feedback {

                selectedFeedback =
                    FeedbackOption(
                        rawValue:
                            savedFeedback
                    )
            }
        }
    }


    // MARK: - Feedback Card

    private func feedbackCard(
        _ option: FeedbackOption
    ) -> some View {

        let isSelected =
            selectedFeedback
            ==
            option

        return Button {

            saveFeedback(
                option
            )

        } label: {

            HStack(spacing: 16) {

                FeedbackFaceView(
                    type:
                        option.faceType,
                    color:
                        Color(hex: "75608E")
                )
                .frame(
                    width: 36,
                    height: 36
                )

                Text(
                    option.title
                )
                .font(
                    .system(
                        size: 17,
                        weight: .regular
                    )
                )
                .foregroundStyle(
                    Color(hex: "37008A")
                )
                .multilineTextAlignment(
                    .leading
                )

                Spacer()
            }
            .padding(
                .horizontal,
                20
            )
            .frame(
                maxWidth: .infinity
            )
            .frame(
                height: 64
            )
            .background(

                RoundedRectangle(
                    cornerRadius: 12
                )
                .fill(
                    isSelected
                    ? option.selectedColor
                    : Color(hex: "F5F0F0")
                )
            )
        }
        .buttonStyle(.plain)
    }


    // MARK: - Save Feedback

    @MainActor
    private func saveFeedback(
        _ option: FeedbackOption
    ) {

        // يظهر الاختيار على الكارد
        selectedFeedback =
            option

        // نحفظه على نفس النشاط
        activity.feedback =
            option.rawValue

        do {

            try modelContext.save()

            print(
                """
                Feedback saved:
                \(option.rawValue)

                Activity:
                \(activity.activityText)
                """
            )

            // MARK: Show Banner

            withAnimation(
                .easeInOut(
                    duration: 0.25
                )
            ) {

                showSavedBanner =
                    true
            }

            // MARK: - Return Home Automatically

            DispatchQueue
                .main
                .asyncAfter(
                    deadline:
                        .now() + 1.5
                ) {

                    withAnimation(
                        .easeInOut(
                            duration: 0.25
                        )
                    ) {

                        showSavedBanner =
                            false
                    }

                    goToHome =
                        true
                }

        } catch {

            print(
                "Failed to save feedback: \(error)"
            )
        }
    }
}


// MARK: - Custom Feedback Icon

private struct FeedbackFaceView: View {

    let type: FeedbackFaceType
    let color: Color

    var body: some View {

        GeometryReader { geometry in

            let width =
                geometry.size.width

            let height =
                geometry.size.height

            ZStack {

                Circle()
                    .stroke(
                        color,
                        lineWidth: 2
                    )

                if type == .easier {

                    Image(
                        systemName:
                            "arrow.down"
                    )
                    .font(
                        .system(
                            size: 17,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        color
                    )

                } else {

                    // العين اليسرى

                    Circle()
                        .fill(color)
                        .frame(
                            width: 3.5,
                            height: 3.5
                        )
                        .position(
                            x: width * 0.36,
                            y: height * 0.41
                        )

                    // العين اليمنى

                    Circle()
                        .fill(color)
                        .frame(
                            width: 3.5,
                            height: 3.5
                        )
                        .position(
                            x: width * 0.64,
                            y: height * 0.41
                        )

                    // الفم

                    mouthPath(
                        width: width,
                        height: height
                    )
                    .stroke(
                        color,
                        style:
                            StrokeStyle(
                                lineWidth: 2,
                                lineCap: .round,
                                lineJoin: .round
                            )
                    )
                }
            }
        }
    }


    private func mouthPath(
        width: CGFloat,
        height: CGFloat
    ) -> Path {

        var path =
            Path()

        let startPoint =
            CGPoint(
                x: width * 0.32,
                y: height * 0.61
            )

        let endPoint =
            CGPoint(
                x: width * 0.68,
                y: height * 0.61
            )

        path.move(
            to: startPoint
        )

        switch type {

        case .happy:

            path.addQuadCurve(
                to: endPoint,
                control:
                    CGPoint(
                        x: width * 0.50,
                        y: height * 0.78
                    )
            )

        case .neutral:

            path.addLine(
                to: endPoint
            )

        case .sad:

            path.addQuadCurve(
                to: endPoint,
                control:
                    CGPoint(
                        x: width * 0.50,
                        y: height * 0.45
                    )
            )

        case .easier:

            break
        }

        return path
    }
}


// MARK: - Feedback Options

enum FeedbackOption:
    String,
    CaseIterable,
    Identifiable {

    case helpful
    case somewhatHelpful
    case notForMe
    case needSomethingEasier

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .helpful:

            return "Helpful"

        case .somewhatHelpful:

            return "Somewhat Helpful"

        case .notForMe:

            return "Not for Me"

        case .needSomethingEasier:

            return "I Need Something Easier"
        }
    }

    var faceType:
        FeedbackFaceType {

        switch self {

        case .helpful:

            return .happy

        case .somewhatHelpful:

            return .neutral

        case .notForMe:

            return .sad

        case .needSomethingEasier:

            return .easier
        }
    }

    // لون الكارد عند الاختيار

    var selectedColor: Color {

        switch self {

        case .helpful:

            return Color(
                hex: "CBD5B3"
            )

        case .somewhatHelpful:

            return Color(
                hex: "F7D3B1"
            )

        case .notForMe:

            return Color(
                hex: "FFCDCD"
            )

        case .needSomethingEasier:

            return Color(
                hex: "E8DDF6"
            )
        }
    }
}


enum FeedbackFaceType {

    case happy
    case neutral
    case sad
    case easier
}


// MARK: - Preview

#Preview {

    let sampleActivity =
        SuggestionActivity(
            category: "calm",
            energyLevel: "low",
            availableTime: "fiveMinutes",
            location: "home",
            activityText:
                "Take a few slow breaths.",
            estimatedMinutes: 2,
            difficulty:
                "Very Easy"
        )

    NavigationStack {

        FeedbackView(
            activity:
                sampleActivity
        )
    }
    .modelContainer(
        for: [
            SuggestionActivity.self
        ],
        inMemory: true
    )
}
