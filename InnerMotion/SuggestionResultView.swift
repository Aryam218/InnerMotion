//
//  SuggestionResultView.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 21/02/1448 AH.
//

import SwiftUI

struct SuggestionResultView: View {

    let selectedCategory: SuggestionCategory?
    let selectedEnergy: EnergyLevel?
    let selectedTime: AvailableTime?
    let selectedLocation: UserLocation?

    @Environment(\.dismiss) private var dismiss

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
                .padding(.top, 4)

                // MARK: - Title

                Text("A Suggestion for You!")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(Color(hex: "37008A"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 34)

                // MARK: - Fixed Image

                Image("suggestionActivityImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 220)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                    .padding(.top, 70)

                // MARK: - Suggestion Card

                VStack(spacing: 14) {

                    Text(
                        "Drink a glass of water and sit\nby the window for 2 minutes"
                    )
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color(hex: "563D6A"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 20) {

                        HStack(spacing: 7) {
                            Image(systemName: "clock")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color(hex: "7049DD"))

                            Text("2 min")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color(hex: "563D6A"))
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                        .background(
                            Capsule()
                                .fill(Color(hex: "EDEBEB"))
                        )

                        HStack(spacing: 7) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(hex: "7049DD"))

                            Text("Very Easy")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color(hex: "563D6A"))
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                        .background(
                            Capsule()
                                .fill(Color(hex: "EDEBEB"))
                        )
                    }
                }
                .frame(width: 300)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "F5F0F0"))
                )
                .padding(.top, 50)

                Spacer(minLength: 24)

                // MARK: - Buttons

                VStack(spacing: 10) {

                    // Start Activity
                    NavigationLink {
                        FeedbackView()
                    } label: {
                        Text("Start Activity")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(.white)
                            .frame(width: 300, height: 50)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "75608E"))
                            )
                    }
                    .buttonStyle(.plain)

                    // Another Idea
                    Button {
                        // لاحقًا هنا نطلب اقتراح جديد من الـ AI
                    } label: {
                        Text("Another Idea")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(.white)
                            .frame(width: 300, height: 50)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "A897BD"))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        SuggestionResultView(
            selectedCategory: .calm,
            selectedEnergy: .low,
            selectedTime: .fiveMinutes,
            selectedLocation: .home
        )
    }
}
