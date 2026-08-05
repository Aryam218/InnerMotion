//
//  LoadingPlanView.swift
//  InnerMotion
//
//  Created by sabaalzuqzuq on 22/02/1448 AH.
//


//
//  LoadingPlanView.swift
//  team15
//

import SwiftUI

struct LoadingPlanView: View {
    // handle back navigation
    var onComplete: () -> Void = {}

    @State private var visibleItemCount = 0
    @State private var progress: CGFloat = 0

    private let checklistItems = [
        "Prioritizing them based on importance",
        "Considering your available time and energy",
        "Breaking them into small, manageable steps",
        "Creating a plan tailored for you"
    ]

    private let primary = Color(red: 0.471, green: 0.392, blue: 0.533)     // 786488
    private let pageBackground = Color(red: 0.996, green: 0.969, blue: 0.945) // FEF7F1
    private let trackBackground = Color(red: 0.910, green: 0.867, blue: 0.965) // E8DDF6
    private let checkCircleBackground = Color.black.opacity(0.06)

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            GeometryReader { screen in
                ScrollView {
                    VStack(spacing: 0) {
                        // Robot illustration
                        // Add this PNG as a regular Image Set in Assets.xcassets named "robotIcon"
                        // (not the App Icon slot - that's reserved for the home screen icon).
                        Image("robotIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 350)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.03))
                                    .frame(width: 210, height: 210)
                            )
                        Text("Understanding your tasks....")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(primary)
                            .padding(.top, 28)

                        // Checklist - items reveal one after another
                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(Array(checklistItems.enumerated()), id: \.offset) { index, item in
                                HStack(alignment: .top, spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(checkCircleBackground)
                                            .frame(width: 28, height: 28)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(primary)
                                    }

                                    Text(item)
                                        .font(.system(size: 16))
                                        .foregroundStyle(primary)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Spacer()
                                }
                                .opacity(visibleItemCount > index ? 1 : 0)
                                .offset(y: visibleItemCount > index ? 0 : 8)
                            }
                        }
                        .padding(.top, 36)
                        .padding(.horizontal, 32)

                        Spacer(minLength: 40)

                        // Progress bar
                        VStack(spacing: 14) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(trackBackground)
                                        .frame(height: 6)
                                    Capsule()
                                        .fill(primary)
                                        .frame(width: geo.size.width * progress, height: 6)
                                }
                            }
                            .frame(height: 6)

                            Text("Preparing your plan...")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    }
                    .frame(minHeight: screen.size.height)
                }
            }
        }
        .onAppear {
            runSequence()
        }
    }

    private func runSequence() {
        // Reveal each checklist item one after another
        for index in 0..<checklistItems.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.6) {
                withAnimation(.easeOut(duration: 0.4)) {
                    visibleItemCount = index + 1
                }
            }
        }

        // Fill the progress bar once all items are visible
        let allItemsRevealedDelay = Double(checklistItems.count) * 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + allItemsRevealedDelay) {
            withAnimation(.easeInOut(duration: 1.2)) {
                progress = 1.0
            }
        }

        // Call onComplete once the whole sequence has finished
        DispatchQueue.main.asyncAfter(deadline: .now() + allItemsRevealedDelay + 1.4) {
            onComplete()
        }
    }
}

#Preview {
    LoadingPlanView()
}
