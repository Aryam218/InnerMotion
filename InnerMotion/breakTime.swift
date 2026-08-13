import SwiftUI

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

struct breakTime: View {

    @Environment(\.dismiss) private var dismiss

    // MARK: - Button Press State

    @State private var isBackPressed = false

    var body: some View {

        ZStack {

            Color.backgroundColor
                .ignoresSafeArea()

            VStack {

                // MARK: - Top Bar

                // هوم فقط، بدون زر باك
                HStack {

                    Spacer()

                    NavigationLink {
                        MainTabView()
                    } label: {

                        Image(systemName: "house")
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
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Spacer()
                    .frame(height: 15)

                // MARK: - Break Image

                Image("break")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 320,
                        height: 320
                    )

                Spacer()
                    .frame(height: 30)

                // MARK: - Title

                Text("Taking a Break is Okay")
                    .font(
                        .system(
                            size: 30,
                            weight: .medium
                        )
                    )
                    .foregroundColor(
                        .primaryText
                    )
                    .multilineTextAlignment(
                        .center
                    )
                    .padding(
                        .horizontal,
                        20
                    )

                Spacer()
                    .frame(height: 20)

                // MARK: - Subtitle

                VStack(spacing: 8) {

                    Text(
                        "Take a moment to rest."
                    )

                    Text(
                        "We'll be here when you're ready."
                    )
                }
                .font(
                    .system(size: 17)
                )
                .foregroundColor(
                    .secondaryText
                )
                .multilineTextAlignment(
                    .center
                )

                Spacer()

                // MARK: - Back to My Steps

                Button {

                    dismiss()

                } label: {

                    Text("Back to My Steps")
                        .font(
                            .system(
                                size: 20,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(.white)
                        .frame(
                            maxWidth: .infinity
                        )
                        .frame(
                            height: 58
                        )
                        .background(

                            isBackPressed

                            ? Color(
                                red: 0.337,
                                green: 0.239,
                                blue: 0.416
                            )

                            : Color.primaryButton
                        )
                        .clipShape(
                            Capsule()
                        )
                }
                .buttonStyle(.plain)
                .simultaneousGesture(

                    DragGesture(
                        minimumDistance: 0
                    )
                    .onChanged { _ in

                        isBackPressed = true
                    }
                    .onEnded { _ in

                        isBackPressed = false
                    }
                )
                .padding(
                    .horizontal,
                    35
                )
                .padding(
                    .bottom,
                    40
                )
            }
        }
        .toolbar(
            .hidden,
            for: .navigationBar
        )
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {
        breakTime()
    }
}
