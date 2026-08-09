//
//  PlanYourDayView.swift
//  team15
//

import SwiftUI
import SwiftData

enum TaskEnergyLevel: String, CaseIterable {

    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case veryLow = "Very low"

    var iconName: String {

        switch self {

        case .high, .medium:
            return "face.smiling"

        case .low, .veryLow:
            return "face.dashed"
        }
    }

    var highlightColor: Color {

        switch self {

        case .high:

            return Color(
                red: 0.796,
                green: 0.835,
                blue: 0.702
            )

        case .medium:

            return Color(
                red: 0.973,
                green: 0.953,
                blue: 0.776
            )

        case .low:

            return Color(
                red: 0.969,
                green: 0.827,
                blue: 0.694
            )

        case .veryLow:

            return Color(
                red: 1.0,
                green: 0.804,
                blue: 0.804
            )
        }
    }
}


enum TimeOption: Equatable {

    case fifteenMin
    case thirtyMin
    case oneHour
    case more(minutes: Int?)

    var label: String {

        switch self {

        case .fifteenMin:
            return "15 minutes"

        case .thirtyMin:
            return "30 minutes"

        case .oneHour:
            return "1 hour"

        case .more(let minutes):

            if let minutes {
                return "\(minutes) minutes"
            }

            return "More"
        }
    }

    var baseCase: Int {

        switch self {

        case .fifteenMin:
            return 0

        case .thirtyMin:
            return 1

        case .oneHour:
            return 2

        case .more:
            return 3
        }
    }

    var minutes: Int? {

        switch self {

        case .fifteenMin:
            return 15

        case .thirtyMin:
            return 30

        case .oneHour:
            return 60

        case .more(let minutes):
            return minutes
        }
    }
}


struct PlanYourDayView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Current Planning Session

    let sessionID: UUID

    // MARK: - Selections

    @State private var selectedEnergy: TaskEnergyLevel? = nil
    @State private var selectedTime: TimeOption? = nil

    @State private var isHomePressed = false

    @State private var showCustomTimePicker = false
    @State private var customMinutes: Int = 45

    // بعد الحفظ يروح للـ Loading
    @State private var navigateToLoading = false

    private var isFormComplete: Bool {

        selectedEnergy != nil &&
        selectedTime != nil
    }

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

    private let selectedTimeBackground = Color(
        red: 0.910,
        green: 0.867,
        blue: 0.965
    )

    private let timeOptions: [TimeOption] = [
        .fifteenMin,
        .thirtyMin,
        .oneHour,
        .more(minutes: nil)
    ]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private func displayLabel(
        for option: TimeOption
    ) -> String {

        if option.baseCase == 3,
           let selectedTime,
           selectedTime.baseCase == 3 {

            return selectedTime.label
        }

        return option.label
    }

    var body: some View {

        ZStack {

            pageBackground
                .ignoresSafeArea()

            // MARK: - Loading Navigation

            NavigationLink(
                destination:
                    LoadingPlanView(
                        sessionID: sessionID
                    ),
                isActive:
                    $navigateToLoading
            ) {

                EmptyView()
            }

            VStack(spacing: 0) {

                // MARK: - Top Bar

                HStack {

                    // Back
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

                    // Home
                    NavigationLink {

                        MainTabView()

                    } label: {

                        Image(
                            systemName: "house"
                        )
                        .font(
                            .system(size: 24)
                        )
                        .foregroundStyle(
                            buttonColor.opacity(
                                isHomePressed
                                ? 0.5
                                : 1.0
                            )
                        )
                    }
                    .simultaneousGesture(

                        DragGesture(
                            minimumDistance: 0
                        )
                        .onChanged { _ in

                            isHomePressed = true
                        }
                        .onEnded { _ in

                            isHomePressed = false
                        }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // MARK: - Scrollable Content

                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 0
                    ) {

                        // MARK: Title

                        VStack(spacing: 6) {

                            Text(
                                "Let's plan your day"
                            )
                            .font(
                                .system(
                                    size: 36,
                                    weight: .regular
                                )
                            )
                            .foregroundStyle(primary)

                            Text(
                                "This helps us create the best plan for you."
                            )
                            .font(
                                .system(size: 16)
                            )
                            .foregroundStyle(secondary)
                            .multilineTextAlignment(
                                .center
                            )
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(.top, 12)

                        // MARK: - Energy Level

                        Text(
                            "How is your energy level right now?"
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(primary)
                        .padding(.top, 44)

                        HStack(spacing: 14) {

                            ForEach(
                                TaskEnergyLevel.allCases,
                                id: \.self
                            ) { level in

                                Button {

                                    selectedEnergy =
                                        level

                                } label: {

                                    VStack(spacing: 10) {

                                        Image(
                                            systemName:
                                                level.iconName
                                        )
                                        .font(
                                            .system(size: 40)
                                        )
                                        .foregroundStyle(
                                            buttonColor
                                        )
                                        .frame(
                                            maxWidth: .infinity
                                        )
                                        .frame(height: 84)
                                        .background(
                                            selectedEnergy == level
                                            ? level.highlightColor
                                            : fieldBackground
                                        )
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 18
                                            )
                                        )

                                        Text(
                                            level.rawValue
                                        )
                                        .font(
                                            .system(size: 14)
                                        )
                                        .foregroundStyle(
                                            primary
                                        )
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(.top, 18)

                        // MARK: - Available Time

                        Text(
                            "How much time do you have today?"
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(primary)
                        .padding(.top, 52)

                        LazyVGrid(
                            columns: columns,
                            spacing: 16
                        ) {

                            ForEach(
                                Array(
                                    timeOptions.enumerated()
                                ),
                                id: \.offset
                            ) { _, option in

                                Button {

                                    if case .more = option {

                                        showCustomTimePicker =
                                            true

                                    } else {

                                        selectedTime =
                                            option
                                    }

                                } label: {

                                    Text(
                                        displayLabel(
                                            for: option
                                        )
                                    )
                                    .font(
                                        .system(size: 18)
                                    )
                                    .foregroundStyle(
                                        secondary
                                    )
                                    .frame(
                                        maxWidth: .infinity
                                    )
                                    .padding(
                                        .vertical,
                                        26
                                    )
                                    .background(
                                        selectedTime?.baseCase
                                            == option.baseCase
                                        ? selectedTimeBackground
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
                        .padding(.top, 18)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                // MARK: - Create My Plan

                Button {

                    saveDayPlan()

                } label: {

                    Text(
                        "Create My Plan"
                    )
                    .font(
                        .system(
                            size: 19,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(
                        .vertical,
                        20
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
                .disabled(
                    !isFormComplete
                )
                .opacity(
                    isFormComplete
                    ? 1
                    : 0.55
                )
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

        // MARK: - Custom Time Picker

        .sheet(
            isPresented:
                $showCustomTimePicker
        ) {

            VStack(spacing: 20) {

                Text("Custom time")
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(primary)
                    .padding(.top, 24)

                Picker(
                    "Minutes",
                    selection:
                        $customMinutes
                ) {

                    ForEach(
                        Array(
                            stride(
                                from: 5,
                                through: 240,
                                by: 5
                            )
                        ),
                        id: \.self
                    ) { minute in

                        Text(
                            "\(minute) minutes"
                        )
                        .tag(minute)
                    }
                }
                .pickerStyle(.wheel)

                Button {

                    selectedTime =
                        .more(
                            minutes:
                                customMinutes
                        )

                    showCustomTimePicker =
                        false

                } label: {

                    Text("Done")
                        .font(
                            .system(
                                size: 16,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(.white)
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
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .presentationDetents(
                [.height(320)]
            )
        }
    }

    // MARK: - Save Day Plan

    private func saveDayPlan() {

        guard
            let selectedEnergy,
            let selectedTime,
            let availableMinutes =
                selectedTime.minutes
        else {
            return
        }

        let newPlan = DayPlan(

            energyLevel:
                selectedEnergy.rawValue,

            availableMinutes:
                availableMinutes,

            // أهم شيء:
            // نفس Session المهام
            planningSessionID:
                sessionID
        )

        modelContext.insert(
            newPlan
        )

        do {

            try modelContext.save()

            print(
                "DayPlan saved for session \(sessionID): \(selectedEnergy.rawValue), \(availableMinutes) minutes"
            )

            navigateToLoading =
                true

        } catch {

            print(
                "Failed to save DayPlan: \(error)"
            )
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        PlanYourDayView(
            sessionID: UUID()
        )
    }
    .modelContainer(
        for: [
            UserTask.self,
            DayPlan.self
        ],
        inMemory: true
    )
}
