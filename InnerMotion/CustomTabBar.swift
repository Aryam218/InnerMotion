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

    var body: some View {
        HStack(spacing: 4) {

            // MARK: - Home
            tabButton(
                index: 0,
                title: "Home",
                icon: "house.fill",
                iconSize: 32
            )

            // MARK: - My Tasks
            tabButton(
                index: 1,
                title: "My Tasks",
                icon: "checklist",
                iconSize: 29
            )

            // MARK: - Achievements
            tabButton(
                index: 2,
                title: "Achievements",
                icon: "star.fill",
                iconSize: 32
            )
        }
        .padding(6)
        .frame(height: 70)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .stroke(
                            Color.white.opacity(0.65),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: Color.black.opacity(0.10),
                    radius: 14,
                    x: 0,
                    y: 5
                )
        }
    }

    private func tabButton(
        index: Int,
        title: String,
        icon: String,
        iconSize: CGFloat
    ) -> some View {

        let isSelected = selectedTab == index

        return Button {
            withAnimation(.easeInOut(duration: 0.22)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 3) {

                Image(systemName: icon)
                    .font(
                        .system(
                            size: iconSize,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(buttonColor)

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(buttonColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 74)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.white.opacity(0.40))
                        .overlay {
                            Capsule()
                                .stroke(
                                    Color.white.opacity(0.65),
                                    lineWidth: 0.8
                                )
                        }
                        .shadow(
                            color: Color.black.opacity(0.05),
                            radius: 5,
                            x: 0,
                            y: 2
                        )
                }
            }
            .contentShape(Capsule())
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
