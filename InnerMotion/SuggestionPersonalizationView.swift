//
//  SuggestionPersonalizationView.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 21/02/1448 AH.
//

import SwiftUI

struct SuggestionPersonalizationView: View {

    let selectedCategory: SuggestionCategory?

    @Environment(\.dismiss) private var dismiss

    @State private var selectedEnergy: EnergyLevel?
    @State private var selectedTime: AvailableTime?
    @State private var selectedLocation: UserLocation?

    private var isFormComplete: Bool {
        selectedEnergy != nil &&
        selectedTime != nil &&
        selectedLocation != nil
    }

    var body: some View {
        ZStack {
            Color(hex: "FFF7F1")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // أعلى الصفحة: رجوع + هوم
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color(hex: "75608E"))
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        // لاحقًا نربطه بالهوم الأساسي
                    } label: {
                        Image(systemName: "house")
                            .font(.system(size: 27, weight: .semibold))
                            .foregroundStyle(Color(hex: "75608E"))
                            .frame(width: 38, height: 38)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                // العنوان
                Text("Let’s personalize\nyour suggestion")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundStyle(Color(hex: "37008A"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)

                // الطاقة
                VStack(alignment: .leading, spacing: 20) {
                    Text("How is your energy right now?")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color(hex: "37008A"))

                    HStack(spacing: 8) {
                        ForEach(EnergyLevel.allCases) { energy in
                            energyCard(energy)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 26)
                .padding(.top, 44)

                // الوقت
                VStack(alignment: .leading, spacing: 18) {
                    Text("How much time do you have?")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color(hex: "37008A"))

                    HStack(spacing: 12) {
                        ForEach(AvailableTime.allCases) { time in
                            optionCard(
                                title: time.title,
                                isSelected: selectedTime == time
                            ) {
                                selectedTime = time
                            }
                        }
                    }
                }
                .padding(.horizontal, 26)
                .padding(.top, 34)

                // المكان
                VStack(alignment: .leading, spacing: 18) {
                    Text("Where are you?")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color(hex: "37008A"))

                    HStack(spacing: 12) {
                        ForEach(UserLocation.allCases) { location in
                            optionCard(
                                title: location.title,
                                isSelected: selectedLocation == location
                            ) {
                                selectedLocation = location
                            }
                        }
                    }
                }
                .padding(.horizontal, 26)
                .padding(.top, 30)

                Spacer()

                // ينتقل للصفحة الثالثة
                NavigationLink {
                    SuggestionResultView(
                        selectedCategory: selectedCategory,
                        selectedEnergy: selectedEnergy,
                        selectedTime: selectedTime,
                        selectedLocation: selectedLocation
                    )
                } label: {
                    Text("Find Something for Me")
                        .font(.system(size: 21, weight: .regular))
                        .foregroundStyle(.white)
                        .frame(width: 300, height: 50)
                        .background(
                            Capsule()
                                .fill(Color(hex: "75608E"))
                        )
                }
                .disabled(!isFormComplete)
                .opacity(isFormComplete ? 1 : 0.55)
                .padding(.bottom, 32)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Energy Card

    private func energyCard(_ energy: EnergyLevel) -> some View {
        let isSelected = selectedEnergy == energy

        return Button {
            selectedEnergy = energy
        } label: {
            VStack(spacing: 7) {

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            isSelected
                                ? Color(hex: energy.selectedColor)
                                : Color(hex: "F5F0F0")
                        )
                        .frame(height: 76)

                    EnergyFaceView(
                        mood: energy.mood,
                        color: Color(hex: "37008A")
                    )
                    .frame(width: 53, height: 53)
                }

                Text(energy.title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex: "37008A"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Time and Location Cards

    private func optionCard(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(hex: "37008A"))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            isSelected
                                ? Color(hex: "E8DDF6")
                                : Color(hex: "F5F0F0")
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Face Drawing

private struct EnergyFaceView: View {

    let mood: FaceMood
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                Circle()
                    .stroke(color, lineWidth: 2.7)

                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
                    .position(
                        x: width * 0.36,
                        y: height * 0.42
                    )

                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
                    .position(
                        x: width * 0.64,
                        y: height * 0.42
                    )

                mouthPath(
                    width: width,
                    height: height
                )
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 2.7,
                        lineCap: .round
                    )
                )
            }
        }
    }

    private func mouthPath(
        width: CGFloat,
        height: CGFloat
    ) -> Path {
        var path = Path()

        let start = CGPoint(
            x: width * 0.32,
            y: height * 0.60
        )

        let end = CGPoint(
            x: width * 0.68,
            y: height * 0.60
        )

        path.move(to: start)

        switch mood {
        case .happy:
            path.addQuadCurve(
                to: end,
                control: CGPoint(
                    x: width * 0.50,
                    y: height * 0.79
                )
            )

        case .softSmile:
            path.addQuadCurve(
                to: end,
                control: CGPoint(
                    x: width * 0.50,
                    y: height * 0.71
                )
            )

        case .sad:
            path.addQuadCurve(
                to: end,
                control: CGPoint(
                    x: width * 0.50,
                    y: height * 0.47
                )
            )

        case .verySad:
            path.addQuadCurve(
                to: end,
                control: CGPoint(
                    x: width * 0.50,
                    y: height * 0.41
                )
            )
        }

        return path
    }
}

// MARK: - Energy

enum EnergyLevel: String, CaseIterable, Identifiable {
    case high
    case medium
    case low
    case veryLow

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .high:
            return "High"

        case .medium:
            return "Medium"

        case .low:
            return "Low"

        case .veryLow:
            return "Very Low"
        }
    }

    var selectedColor: String {
        switch self {
        case .high:
            return "CBD5B3"

        case .medium:
            return "F8F3C6"

        case .low:
            return "F7D3B1"

        case .veryLow:
            return "FFCDCD"
        }
    }

    var mood: FaceMood {
        switch self {
        case .high:
            return .happy

        case .medium:
            return .softSmile

        case .low:
            return .sad

        case .veryLow:
            return .verySad
        }
    }
}

enum FaceMood {
    case happy
    case softSmile
    case sad
    case verySad
}

// MARK: - Time

enum AvailableTime: String, CaseIterable, Identifiable {
    case fiveMinutes
    case tenMinutes
    case twentyPlusMinutes

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .fiveMinutes:
            return "5 min"

        case .tenMinutes:
            return "10 min"

        case .twentyPlusMinutes:
            return "20 min"
        }
    }
}

// MARK: - Location

enum UserLocation: String, CaseIterable, Identifiable {
    case home
    case work
    case outside

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .home:
            return "At Home"

        case .work:
            return "At Work"

        case .outside:
            return "Outside"
        }
    }
}

#Preview {
    NavigationStack {
        SuggestionPersonalizationView(
            selectedCategory: .calm
        )
    }
}
