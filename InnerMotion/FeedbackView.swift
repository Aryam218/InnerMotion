//
//  FeedbackView.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 21/02/1448 AH.
//

import SwiftUI

struct FeedbackView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedFeedback: FeedbackOption?

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
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color(hex: "75608E"))
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    NavigationLink {
                        MainTabView()
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
                .padding(.top, 6)

                // MARK: - Title

                Text("How did that feel?")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundStyle(Color(hex: "37008A"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 34)

                // MARK: - Robot

                Image("feedbackRobot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .padding(.top, 14)

                // MARK: - Feedback Options

                VStack(spacing: 14) {
                    ForEach(FeedbackOption.allCases) { option in
                        feedbackCard(option)
                    }
                }
                .padding(.horizontal, 34)
                .padding(.top, 28)

                Spacer(minLength: 24)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Feedback Card

    private func feedbackCard(
        _ option: FeedbackOption
    ) -> some View {

        let isSelected = selectedFeedback == option

        return Button {
            selectedFeedback = option
        } label: {
            HStack(spacing: 16) {

                FeedbackFaceView(
                    type: option.faceType,
                    color: Color(hex: "75608E")
                )
                .frame(width: 36, height: 36)

                Text(option.title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color(hex: "37008A"))
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                        ? option.selectedColor
                        : Color(hex: "F5F0F0")
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Feedback Icon

private struct FeedbackFaceView: View {

    let type: FeedbackFaceType
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                Circle()
                    .stroke(color, lineWidth: 2)

                if type == .easier {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(color)

                } else {
                    // العين اليسرى
                    Circle()
                        .fill(color)
                        .frame(width: 3.5, height: 3.5)
                        .position(
                            x: width * 0.36,
                            y: height * 0.41
                        )

                    // العين اليمنى
                    Circle()
                        .fill(color)
                        .frame(width: 3.5, height: 3.5)
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
                        style: StrokeStyle(
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

        var path = Path()

        let startPoint = CGPoint(
            x: width * 0.32,
            y: height * 0.61
        )

        let endPoint = CGPoint(
            x: width * 0.68,
            y: height * 0.61
        )

        path.move(to: startPoint)

        switch type {

        case .happy:
            path.addQuadCurve(
                to: endPoint,
                control: CGPoint(
                    x: width * 0.50,
                    y: height * 0.78
                )
            )

        case .neutral:
            path.addLine(to: endPoint)

        case .sad:
            path.addQuadCurve(
                to: endPoint,
                control: CGPoint(
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

enum FeedbackOption: String, CaseIterable, Identifiable {
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

    var faceType: FeedbackFaceType {
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
            return Color(hex: "CBD5B3")

        case .somewhatHelpful:
            return Color(hex: "F7D3B1")

        case .notForMe:
            return Color(hex: "FFCDCD")

        case .needSomethingEasier:
            return Color(hex: "E8DDF6")
        }
    }
}

enum FeedbackFaceType {
    case happy
    case neutral
    case sad
    case easier
}

#Preview {
    NavigationStack {
        FeedbackView()
    }
}

