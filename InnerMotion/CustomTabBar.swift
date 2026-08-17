//
//  CustomTabBar.swift
//  InnerMotion
//
//  Created by Renad Sameer Alharbi on 22/02/1448 AH.
//
import SwiftUI

struct CustomTabBar: View {

    @Binding var selectedTab: Int

    private let buttonColor = Color(hex: "75608E")
    private let selectedBackground = Color(hex: "EEE6FA")

    var body: some View {
        HStack(spacing: 4) {

            // MARK: - Home
            tabButton(
                index: 0,
                title: "Home",
                icon: "house.fill"
            )

            // MARK: - My Tasks
            tabButton(
                index: 1,
                title: "My Tasks",
                icon: "checklist"
            )

            // MARK: - Achievements
            tabButton(
                index: 2,
                title: "Achievements",
                icon: "star"
            )
        }
        .padding(6)
        .frame(height: 78)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .fill(Color.white.opacity(0.18))
                }
                .overlay {
                    Capsule()
                        .stroke(
                            Color.white.opacity(0.75),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: Color.black.opacity(0.09),
                    radius: 18,
                    x: 0,
                    y: 7
                )
        }
    }

    private func tabButton(
        index: Int,
        title: String,
        icon: String
    ) -> some View {

        let isSelected = selectedTab == index

        return Button {
            withAnimation(
                .easeInOut(duration: 0.22)
            ) {
                selectedTab = index
            }
        } label: {

            VStack(spacing: 3) {

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 25,
                            weight: isSelected ? .semibold : .regular
                        )
                    )
                    .foregroundStyle(buttonColor)

                Text(title)
                    .font(
                        .system(
                            size: 15,
                            weight: isSelected ? .medium : .regular
                        )
                    )
                    .foregroundStyle(buttonColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 66)
            .background {

                if isSelected {

                    RoundedRectangle(
                        cornerRadius: 22,
                        style: .continuous
                    )
                    .fill(selectedBackground)

                    RoundedRectangle(
                        cornerRadius: 22,
                        style: .continuous
                    )
                    .stroke(
                        Color.white.opacity(0.45),
                        lineWidth: 0.8
                    )
                }
            }
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {

        Color(hex: "FFF7F1")
            .ignoresSafeArea()

        VStack {

            Spacer()

            CustomTabBar(
                selectedTab: .constant(0)
            )
            .padding(.horizontal, 18)
            .padding(.bottom, 10)
        }
    }
}
