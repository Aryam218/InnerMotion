//
//  MyTasksView.swift
//  InnerMotion
//
//  Created by sabaalzuqzuq on 22/02/1448 AH.
//


//
//  MyTasksView.swift
//  team15
//

import SwiftUI

struct MyTasksView: View {
    @State private var isContinuePressed = false
    @State private var isHomePressed = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.996, green: 0.969, blue: 0.945) // FEF7F1
                    .ignoresSafeArea()

                VStack {
                    // Top bar
                    HStack {
                        Button(action: {
                            // handle back navigation
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color(red: 0.216, green: 0.0, blue: 0.541)) // 37008A
                        }

                        Spacer()

                        Button(action: {
                            // handle home navigation
                        }) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(
                                    Color(red: 0.459, green: 0.376, blue: 0.557) // 75608E
                                        .opacity(isHomePressed ? 0.5 : 1.0)
                                )
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isHomePressed = true }
                                .onEnded { _ in isHomePressed = false }
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Title
                    VStack(spacing: 4) {
                        Text("My Tasks")
                            .font(.system(size: 44, weight: .regular))
                            .foregroundStyle(Color(red: 0.216, green: 0.0, blue: 0.541)) // 37008A

                        Text("Your tasks list")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(red: 0.337, green: 0.239, blue: 0.416)) // 563D6A
                    }
                    .padding(.top, 8)

                    // Task card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Study for math test")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color(red: 0.216, green: 0.0, blue: 0.541)) // 37008A

                            Spacer()

                            NavigationLink(destination: EditTaskView()) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(red: 0.459, green: 0.376, blue: 0.557)) // 75608E
                            }
                        }

                        HStack(spacing: 6) {
                            Text("Study")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                            Text("•")
                                .foregroundStyle(.gray)
                            Text("High")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(red: 0.918, green: 0.522, blue: 0.443)) // coral
                        }

                        Text("1 Apr 2026")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(red: 0.216, green: 0.0, blue: 0.541)) // 37008A
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    Spacer()

                    // Buttons
                    VStack(spacing: 14) {
                        NavigationLink(destination: PlanYourDayView()) {
                            Text("Continue")
                                .font(Font.title3.bold())
                                .foregroundStyle(isContinuePressed ? Color(red: 0.459, green: 0.376, blue: 0.557) : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(isContinuePressed ? Color.white : Color(red: 0.459, green: 0.376, blue: 0.557)) // 75608E
                                .clipShape(RoundedRectangle(cornerRadius: 32))
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isContinuePressed = true }
                                .onEnded { _ in isContinuePressed = false }
                        )

                        Button(action: {
                            // handle add another task
                        }) {
                            Text("Add another task")
                                .font(Font.title3.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 0.663, green: 0.592, blue: 0.741)) // A897BD
                                .clipShape(RoundedRectangle(cornerRadius: 32))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MyTasksView()
}
