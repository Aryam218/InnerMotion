//
//  SuggestionCategoryView.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 21/02/1448 AH.
//

import SwiftUI

struct SuggestionCategoryView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: SuggestionCategory?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FFF7F1")
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // سهم الرجوع بدون دائرة أو خلفية
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(Color(hex: "75608E"))
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 8)

                    // العنوان كامل بدون نقاط
                    Text("What do you need\nright now?")
                        .font(.system(size: 36, weight: .regular))
                        .foregroundStyle(Color(hex: "37008A"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 43)

                    // قللنا المسافة بين العنوان والوصف
                    Text("Select what feels most helpful at this moment.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(hex: "37008A"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 35)
                        .padding(.top, 50)

                    // رفعنا الكاردات للأعلى
                    LazyVGrid(
                        columns: [
                            GridItem(.fixed(159), spacing: 14),
                            GridItem(.fixed(159))
                        ],
                        spacing: 20
                    ) {
                        categoryCard(for: .calm)
                        categoryCard(for: .lightMovement)
                        categoryCard(for: .gentleConnection)
                        categoryCard(for: .notSure)
                    }
                    .padding(.top, 35)

                    Spacer(minLength: 20)

                    // الزر صار أنزل قليلًا
                    NavigationLink {
                        SuggestionPersonalizationView(
                            selectedCategory: selectedCategory
                        )
                    } label: {
                        Text("Continue")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(.white)
                            .frame(width: 270, height: 45)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "75608E"))
                            )
                    }
                    .disabled(selectedCategory == nil)
                    .opacity(selectedCategory == nil ? 0.55 : 1)
                    .padding(.bottom, 30)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func categoryCard(
        for category: SuggestionCategory
    ) -> some View {

        let isSelected = selectedCategory == category

        return Button {
            selectedCategory = category
        } label: {
            VStack(spacing: category.textSpacing) {

                Image(category.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: category.imageWidth,
                        height: category.imageHeight
                    )

                Text(category.title)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color(hex: "37008A"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(0)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 159, height: 148)
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

// MARK: - Categories

enum SuggestionCategory: String {
    case calm
    case lightMovement
    case gentleConnection
    case notSure

    var title: String {
        switch self {
        case .calm:
            return "Calm"

        case .lightMovement:
            return "Light\nMovement"

        case .gentleConnection:
            return "Gentle\nConnection"

        case .notSure:
            return "Not Sure"
        }
    }

    var imageName: String {
        switch self {
        case .calm:
            return "calmIcon"

        case .lightMovement:
            return "movementIcon"

        case .gentleConnection:
            return "connectionIcon"

        case .notSure:
            return "notSureIcon"
        }
    }

    // كبرنا الصور داخل الكاردات
    var imageWidth: CGFloat {
        switch self {
        case .calm:
            return 100

        case .lightMovement:
            return 100

        case .gentleConnection:
            return 100

        case .notSure:
            return 100
        }
    }

    var imageHeight: CGFloat {
        switch self {
        case .calm:
            return 73

        case .lightMovement:
            return 76

        case .gentleConnection:
            return 72

        case .notSure:
            return 75
        }
    }

    var textSpacing: CGFloat {
        switch self {
        case .lightMovement, .gentleConnection:
            return 3

        default:
            return 7
        }
    }
}

// MARK: - Hex Color

extension Color {
    init(hex: String) {
        let cleanedHex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )

        var value: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&value)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch cleanedHex.count {
        case 8:
            red = value >> 24
            green = value >> 16 & 0xFF
            blue = value >> 8 & 0xFF
            alpha = value & 0xFF

        default:
            red = value >> 16
            green = value >> 8 & 0xFF
            blue = value & 0xFF
            alpha = 255
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

#Preview {
    SuggestionCategoryView()
}
