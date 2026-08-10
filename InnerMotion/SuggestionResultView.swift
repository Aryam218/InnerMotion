//
//  SuggestionResultView.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 21/02/1448 AH.
//

import SwiftUI
import SwiftData

struct SuggestionResultView: View {

    // MARK: - User Selections

    let selectedCategory: SuggestionCategory?
    let selectedEnergy: EnergyLevel?
    let selectedTime: AvailableTime?
    let selectedLocation: UserLocation?

    // MARK: - Environment

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    // MARK: - Previous Feedback

    // نستخدم التقييمات السابقة عشان الـ AI
    // يعرف تفضيلات المستخدم مستقبلًا
    @Query(
        sort: \SuggestionActivity.createdAt,
        order: .reverse
    )
    private var suggestionHistory: [SuggestionActivity]

    // MARK: - AI Result

    @State private var generatedSuggestion: GeneratedSuggestion?

    // MARK: - Previous Suggestions In Current Session

    // الاقتراحات اللي ظهرت للمستخدم في نفس الجلسة
    // عشان Another Idea ما يكررها
    @State private var previousSuggestions: [String] = []

    // MARK: - Loading / Error

    @State private var isGenerating = false
    @State private var errorMessage: String?

    // MARK: - Navigation

    @State private var goToFeedback = false

    // النشاط الذي ضغط عليه المستخدم Start Activity
    // نمرره لصفحة Feedback
    @State private var startedActivity: SuggestionActivity?

    // يمنع التوليد الأول من التشغيل أكثر من مرة
    @State private var hasGeneratedInitialSuggestion = false

    var body: some View {

        ZStack {

            Color(hex: "FFF7F1")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Back and Home

                HStack {

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

                    NavigationLink {

                        MainTabView()

                    } label: {

                        Image(
                            systemName: "house"
                        )
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
                .padding(
                    .horizontal,
                    24
                )
                .padding(
                    .top,
                    4
                )

                // MARK: - Title

                Text(
                    "A Suggestion for You!"
                )
                .font(
                    .system(
                        size: 34,
                        weight: .regular
                    )
                )
                .foregroundStyle(
                    Color(hex: "37008A")
                )
                .multilineTextAlignment(
                    .center
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .frame(
                    maxWidth: .infinity
                )
                .padding(
                    .top,
                    34
                )

                // MARK: - Fixed Image

                Image(
                    "suggestionActivityImage"
                )
                .resizable()
                .scaledToFill()
                .frame(
                    width: 220,
                    height: 220
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12
                    )
                )
                .padding(
                    .top,
                    70
                )

                // MARK: - Suggestion Area

                if isGenerating {

                    // MARK: Loading

                    VStack(spacing: 16) {

                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(
                                Color(hex: "75608E")
                            )

                        Text(
                            "Finding something for you..."
                        )
                        .font(
                            .system(
                                size: 16,
                                weight: .regular
                            )
                        )
                        .foregroundStyle(
                            Color(hex: "563D6A")
                        )
                    }
                    .frame(
                        width: 300,
                        height: 115
                    )
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                        .fill(
                            Color(hex: "F5F0F0")
                        )
                    )
                    .padding(
                        .top,
                        50
                    )

                } else if let suggestion =
                            generatedSuggestion {

                    // MARK: AI Suggestion Card

                    VStack(spacing: 14) {

                        Text(
                            suggestion.activity
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .regular
                            )
                        )
                        .foregroundStyle(
                            Color(hex: "563D6A")
                        )
                        .multilineTextAlignment(
                            .center
                        )
                        .lineSpacing(2)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                        HStack(
                            spacing: 20
                        ) {

                            // MARK: Estimated Time

                            HStack(spacing: 7) {

                                Image(
                                    systemName:
                                        "clock"
                                )
                                .font(
                                    .system(
                                        size: 15,
                                        weight: .medium
                                    )
                                )
                                .foregroundStyle(
                                    Color(
                                        hex:
                                            "7049DD"
                                    )
                                )

                                Text(
                                    "\(suggestion.estimatedMinutes) min"
                                )
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .regular
                                    )
                                )
                                .foregroundStyle(
                                    Color(
                                        hex:
                                            "563D6A"
                                    )
                                )
                            }
                            .padding(
                                .horizontal,
                                12
                            )
                            .frame(
                                height: 30
                            )
                            .background(
                                Capsule()
                                    .fill(
                                        Color(
                                            hex:
                                                "EDEBEB"
                                        )
                                    )
                            )

                            // MARK: Difficulty

                            HStack(spacing: 7) {

                                Image(
                                    systemName:
                                        "chart.bar.fill"
                                )
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .medium
                                    )
                                )
                                .foregroundStyle(
                                    Color(
                                        hex:
                                            "7049DD"
                                    )
                                )

                                Text(
                                    suggestion.difficulty
                                )
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .regular
                                    )
                                )
                                .foregroundStyle(
                                    Color(
                                        hex:
                                            "563D6A"
                                    )
                                )
                            }
                            .padding(
                                .horizontal,
                                12
                            )
                            .frame(
                                height: 30
                            )
                            .background(
                                Capsule()
                                    .fill(
                                        Color(
                                            hex:
                                                "EDEBEB"
                                        )
                                    )
                            )
                        }
                    }
                    .frame(
                        width: 300
                    )
                    .padding(
                        .vertical,
                        18
                    )
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                        .fill(
                            Color(hex: "F5F0F0")
                        )
                    )
                    .padding(
                        .top,
                        50
                    )

                } else {

                    // MARK: Error / Empty State

                    VStack(spacing: 12) {

                        if let errorMessage {

                            Text(
                                errorMessage
                            )
                            .font(
                                .system(
                                    size: 14,
                                    weight: .regular
                                )
                            )
                            .foregroundStyle(
                                .red
                            )
                            .multilineTextAlignment(
                                .center
                            )

                            Button {

                                Task {

                                    await generateSuggestion(
                                        isAnotherIdea:
                                            false
                                    )
                                }

                            } label: {

                                Text(
                                    "Try Again"
                                )
                                .font(
                                    .system(
                                        size: 16,
                                        weight: .medium
                                    )
                                )
                                .foregroundStyle(
                                    Color(
                                        hex:
                                            "75608E"
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(width: 300)
                    .frame(minHeight: 115)

                    .padding(
                        .vertical,
                        18
                    )
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                        .fill(
                            Color(hex: "F5F0F0")
                        )
                    )
                    .padding(
                        .top,
                        50
                    )
                }

                Spacer(
                    minLength: 24
                )

                // MARK: - Buttons

                VStack(spacing: 10) {

                    // MARK: Start Activity

                    Button {

                        startActivity()

                    } label: {

                        Text(
                            "Start Activity"
                        )
                        .font(
                            .system(
                                size: 22,
                                weight: .regular
                            )
                        )
                        .foregroundStyle(
                            .white
                        )
                        .frame(
                            width: 300,
                            height: 50
                        )
                        .background(
                            Capsule()
                                .fill(
                                    Color(
                                        hex:
                                            "75608E"
                                    )
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        generatedSuggestion == nil
                        ||
                        isGenerating
                    )
                    .opacity(
                        generatedSuggestion == nil
                        ||
                        isGenerating
                        ? 0.55
                        : 1
                    )

                    // MARK: Another Idea

                    Button {

                        Task {

                            await generateSuggestion(
                                isAnotherIdea:
                                    true
                            )
                        }

                    } label: {

                        HStack(
                            spacing: 8
                        ) {

                            if isGenerating {

                                ProgressView()
                                    .tint(.white)

                            } else {

                                Text(
                                    "Another Idea"
                                )
                            }
                        }
                        .font(
                            .system(
                                size: 22,
                                weight: .regular
                            )
                        )
                        .foregroundStyle(
                            .white
                        )
                        .frame(
                            width: 300,
                            height: 50
                        )
                        .background(
                            Capsule()
                                .fill(
                                    Color(
                                        hex:
                                            "A897BD"
                                    )
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        generatedSuggestion == nil
                        ||
                        isGenerating
                    )
                    .opacity(
                        generatedSuggestion == nil
                        ||
                        isGenerating
                        ? 0.55
                        : 1
                    )
                }
                .padding(
                    .bottom,
                    30
                )
            }
        }

        // MARK: - Generate First Suggestion

        .task {

            guard
                !hasGeneratedInitialSuggestion
            else {
                return
            }

            hasGeneratedInitialSuggestion =
                true

            await generateSuggestion(
                isAnotherIdea:
                    false
            )
        }

        // MARK: - Feedback Navigation

        .navigationDestination(
            isPresented:
                $goToFeedback
        ) {

            if let startedActivity {

                FeedbackView(
                    activity:
                        startedActivity
                )
            }
        }

        .toolbar(
            .hidden,
            for: .navigationBar
        )
    }


    // MARK: - Generate Suggestion

    @MainActor
    private func generateSuggestion(
        isAnotherIdea: Bool
    ) async {

        guard
            let selectedCategory,
            let selectedEnergy,
            let selectedTime,
            let selectedLocation
        else {

            errorMessage =
                "Some information is missing."

            return
        }

        guard !isGenerating else {
            return
        }

        // إذا المستخدم ضغط Another Idea
        // نحفظ الاقتراح الحالي مؤقتًا
        // عشان AI ما يعيده
        if isAnotherIdea,
           let currentSuggestion =
                generatedSuggestion {

            let currentText =
                currentSuggestion.activity
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )

            if !currentText.isEmpty,
               !previousSuggestions.contains(
                    currentText
               ) {

                previousSuggestions.append(
                    currentText
                )
            }
        }

        isGenerating = true

        errorMessage = nil

        do {

            let suggestion =
                try await
                SuggestionService
                    .shared
                    .generateSuggestion(

                        category:
                            selectedCategory,

                        energy:
                            selectedEnergy,

                        availableTime:
                            selectedTime,

                        location:
                            selectedLocation,

                        previousSuggestions:
                            previousSuggestions,

                        feedbackHistory:
                            suggestionHistory
                    )

            generatedSuggestion =
                suggestion

        } catch {

            print(
                "Suggestion generation failed: \(error)"
            )

            errorMessage =
                "We couldn’t find a suggestion right now. Please try again."
        }

        isGenerating = false
    }


    // MARK: - Start Activity

    @MainActor
    private func startActivity() {

        guard
            let suggestion =
                generatedSuggestion,

            let selectedCategory,
            let selectedEnergy,
            let selectedTime,
            let selectedLocation

        else {
            return
        }

        // MARK: Save Chosen Activity

        let activity =
            SuggestionActivity(

                category:
                    selectedCategory
                        .rawValue,

                energyLevel:
                    selectedEnergy
                        .rawValue,

                availableTime:
                    selectedTime
                        .rawValue,

                location:
                    selectedLocation
                        .rawValue,

                activityText:
                    suggestion.activity,

                estimatedMinutes:
                    suggestion
                        .estimatedMinutes,

                difficulty:
                    suggestion
                        .difficulty,

                feedback:
                    nil
            )

        modelContext.insert(
            activity
        )

        do {

            try modelContext.save()

            print(
                "Suggestion activity saved: \(suggestion.activity)"
            )

            // نخزن نفس النشاط الذي بدأه المستخدم
            // عشان نمرره لصفحة Feedback
            startedActivity =
                activity

            goToFeedback =
                true

        } catch {

            print(
                "Failed to save suggestion activity: \(error)"
            )

            errorMessage =
                "We couldn’t save this activity. Please try again."
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        SuggestionResultView(
            selectedCategory:
                .calm,
            selectedEnergy:
                .low,
            selectedTime:
                .fiveMinutes,
            selectedLocation:
                .home
        )
    }
    .modelContainer(
        for: [
            UserTask.self,
            DayPlan.self,
            PlannedTask.self,
            TaskStep.self,
            SuggestionActivity.self
        ],
        inMemory: true
    )
}

