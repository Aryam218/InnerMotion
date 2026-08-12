//
//  PlanYourDayView.swift
//  team15
//

import SwiftUI
import SwiftData


// MARK: - Task Energy Level

enum TaskEnergyLevel: String, CaseIterable {

    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case veryLow = "Very low"

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


// MARK: - Time Option

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


// MARK: - Plan Your Day View

struct PlanYourDayView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Current Planning Session

    let sessionID: UUID

    // MARK: - Selections

    @State private var selectedEnergy: TaskEnergyLevel? = nil
    @State private var selectedTime: TimeOption? = nil

    @State private var showCustomTimePicker = false
    @State private var customMinutes: Int = 45

    // بعد الحفظ يروح للـ Loading
    @State private var navigateToLoading = false

    // MARK: - Form Validation

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

    // MARK: - Time Options

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

    // MARK: - Display Label

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


    // MARK: - Body

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

                    // MARK: - Back Button

                    Button {

                        dismiss()

                    } label: {

                        Image(
                            systemName: "chevron.left"
                        )
                        .font(
                            .system(
                                size: 20,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            Color(
                                red: 117 / 255,
                                green: 96 / 255,
                                blue: 142 / 255
                            )
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

                    // MARK: - Home Button

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
                            Color(
                                red: 117 / 255,
                                green: 96 / 255,
                                blue: 142 / 255
                            )
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
                    10
                )


                // MARK: - Scrollable Content

                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 0
                    ) {

                        // MARK: - Title

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
                            .foregroundStyle(
                                primary
                            )

                            Text(
                                "This helps us create the best plan for you."
                            )
                            .font(
                                .system(
                                    size: 16
                                )
                            )
                            .foregroundStyle(
                                secondary
                            )
                            .multilineTextAlignment(
                                .center
                            )
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(
                            .top,
                            12
                        )


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
                        .foregroundStyle(
                            primary
                        )
                        .padding(
                            .top,
                            44
                        )


                        // MARK: - Energy Cards

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

                                        ZStack {

                                            RoundedRectangle(
                                                cornerRadius: 18
                                            )
                                            .fill(
                                                selectedEnergy == level
                                                ? level.highlightColor
                                                : fieldBackground
                                            )
                                            .frame(
                                                height: 84
                                            )

                                            // الوجه
                                            // نفسه الموجود في
                                            // SuggestionPersonalizationView

                                            TaskEnergyFaceView(
                                                level: level,
                                                color: buttonColor
                                            )
                                            .frame(
                                                width: 53,
                                                height: 53
                                            )
                                        }

                                        Text(
                                            level.rawValue
                                        )
                                        .font(
                                            .system(
                                                size: 14
                                            )
                                        )
                                        .foregroundStyle(
                                            primary
                                        )
                                    }
                                }
                                .buttonStyle(
                                    .plain
                                )
                            }
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(
                            .top,
                            18
                        )


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
                        .foregroundStyle(
                            primary
                        )
                        .padding(
                            .top,
                            52
                        )


                        // MARK: - Time Cards

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
                                        .system(
                                            size: 18
                                        )
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
                                .buttonStyle(
                                    .plain
                                )
                            }
                        }
                        .padding(
                            .top,
                            18
                        )
                    }
                    .padding(
                        .horizontal,
                        24
                    )
                    .padding(
                        .bottom,
                        24
                    )
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
                    .foregroundStyle(
                        .white
                    )
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
                .buttonStyle(
                    .plain
                )
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

        .navigationBarHidden(
            true
        )


        // MARK: - Custom Time Picker

        .sheet(
            isPresented:
                $showCustomTimePicker
        ) {

            VStack(spacing: 20) {

                Text(
                    "Custom time"
                )
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    primary
                )
                .padding(
                    .top,
                    24
                )


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
                .pickerStyle(
                    .wheel
                )


                Button {

                    selectedTime =
                        .more(
                            minutes:
                                customMinutes
                        )

                    showCustomTimePicker =
                        false

                } label: {

                    Text(
                        "Done"
                    )
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        .white
                    )
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
                .buttonStyle(
                    .plain
                )
                .padding(
                    .horizontal
                )
                .padding(
                    .bottom,
                    24
                )
            }
            .presentationDetents(
                [
                    .height(320)
                ]
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


// MARK: - Task Energy Face

private struct TaskEnergyFaceView: View {

    let level: TaskEnergyLevel
    let color: Color

    var body: some View {

        GeometryReader { geometry in

            let width =
                geometry.size.width

            let height =
                geometry.size.height

            ZStack {

                // MARK: - Face Circle

                Circle()
                    .stroke(
                        color,
                        lineWidth: 2.7
                    )


                // MARK: - Left Eye

                Circle()
                    .fill(
                        color
                    )
                    .frame(
                        width: 5,
                        height: 5
                    )
                    .position(
                        x:
                            width * 0.36,
                        y:
                            height * 0.42
                    )


                // MARK: - Right Eye

                Circle()
                    .fill(
                        color
                    )
                    .frame(
                        width: 5,
                        height: 5
                    )
                    .position(
                        x:
                            width * 0.64,
                        y:
                            height * 0.42
                    )


                // MARK: - Mouth

                mouthPath(
                    width: width,
                    height: height
                )
                .stroke(
                    color,
                    style:
                        StrokeStyle(
                            lineWidth: 2.7,
                            lineCap: .round
                        )
                )
            }
        }
    }


    // MARK: - Mouth Path

    private func mouthPath(
        width: CGFloat,
        height: CGFloat
    ) -> Path {

        var path = Path()

        let start = CGPoint(
            x:
                width * 0.32,
            y:
                height * 0.60
        )

        let end = CGPoint(
            x:
                width * 0.68,
            y:
                height * 0.60
        )

        path.move(
            to: start
        )

        switch level {

        case .high:

            // Happy

            path.addQuadCurve(
                to: end,
                control:
                    CGPoint(
                        x:
                            width * 0.50,
                        y:
                            height * 0.79
                    )
            )


        case .medium:

            // Soft Smile

            path.addQuadCurve(
                to: end,
                control:
                    CGPoint(
                        x:
                            width * 0.50,
                        y:
                            height * 0.71
                    )
            )


        case .low:

            // Sad

            path.addQuadCurve(
                to: end,
                control:
                    CGPoint(
                        x:
                            width * 0.50,
                        y:
                            height * 0.47
                    )
            )


        case .veryLow:

            // Very Sad

            path.addQuadCurve(
                to: end,
                control:
                    CGPoint(
                        x:
                            width * 0.50,
                        y:
                            height * 0.41
                    )
            )
        }

        return path
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        PlanYourDayView(
            sessionID:
                UUID()
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
