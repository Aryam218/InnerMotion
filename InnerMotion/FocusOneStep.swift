import SwiftUI

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

struct FocusOneStep: View {

    @Environment(\.dismiss) private var dismiss

    @State private var showCompletionPopup = false
    @State private var goToBreakTime = false

    var body: some View {

        ZStack {

            // خلفية اللون الأساسي
            Color.backgroundColor
                .ignoresSafeArea()

            // صورة الخلفية (الجبال) — لازم تضيفينها بالـ Assets باسم "background"
            VStack {
                Spacer()
                Image("background")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea()

            VStack {

                // Top Bar
                HStack {
                    Button {

                        dismiss()

                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .buttonStyle(PressableIconStyle(normalColor: .primaryText, pressedColor: .secondaryButton))

                    Spacer()

                    Button {

                    } label: {
                        Image(systemName: "house")
                            .font(.system(size: 28))
                    }
                    .buttonStyle(PressableIconStyle(normalColor: .primaryText, pressedColor: .secondaryButton))
                }
                .padding(.horizontal, 25)
                .padding(.top, 15)

                Spacer().frame(height: 25)

                // Title
                Text("Focus one step")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(.primaryText)

                Text("You've got this")
                    .font(.system(size: 17))
                    .foregroundColor(.secondaryText)

                Spacer()

                // الدائرة الكبيرة بالنص
                ZStack {
                    Circle()
                        .fill(Color.stepCircleColor.opacity(0.7))
                        .frame(width: 320, height: 320)

                    VStack(spacing: 14) {
                        Text("Step 2 of 4")
                            .font(.system(size: 17))
                            .foregroundColor(.secondaryText)

                        Text("Open the book and read\nthe title only")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Text("Estimated time")
                            .font(.system(size: 15))
                            .foregroundColor(.secondaryText)
                            .padding(.top, 22)

                        Text("About\n2 minutes")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                // Bottom sheet (Done / Take a Break)
                HStack(spacing: 55) {

                    VStack(spacing: 10) {
                        Button {
                            showCompletionPopup = true
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30, weight: .bold))
                                .frame(width: 90, height: 90)
                        }
                        .buttonStyle(PressableCircleIconStyle(fillColor: .primaryButton))

                        Text("Done")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primaryText)
                    }

                    VStack(spacing: 10) {
                        Button {

                            goToBreakTime = true

                        } label: {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 28))
                                .frame(width: 90, height: 90)
                        }
                        .buttonStyle(PressableCircleIconStyle(fillColor: .secondaryButton))

                        Text("Take a Break")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primaryText)
                    }
                }
                .padding(.top, 25)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
                .background(
                    Color.backgroundColor
                        .clipShape(RoundedCorner(radius: 35, corners: [.topLeft, .topRight]))
                        .ignoresSafeArea(edges: .bottom)
                )
                .navigationDestination(isPresented: $goToBreakTime) {
                    breakTime()
                }
            }

            // البوب أب اللي يطلع لما تضغطين Done
            if showCompletionPopup {

                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture { } // يمنع التفاعل مع الخلفية

                VStack(spacing: 22) {

                    ZStack {
                        Circle()
                            .fill(Color.successGreen)
                            .frame(width: 95, height: 95)

                        Image(systemName: "checkmark")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.secondaryText)
                    }

                    Text("Nice work!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primaryText)

                    Text("You completed your first step")
                        .font(.system(size: 17))
                        .foregroundColor(.secondaryText)

                    Button {
                        showCompletionPopup = false
                    } label: {
                        Text("Continue")
                            .font(.system(size: 20, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                    }
                    .buttonStyle(PressableCapsuleStyle(fillColor: .primaryButton, cornerRadius: 27.5))
                    .padding(.top, 8)
                }
                .padding(30)
                .frame(maxWidth: 340)
                .background(Color.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showCompletionPopup)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// شكل يسمح بتدوير زوايا محددة بس (فوق يمين ويسار بس مثلاً)
struct RoundedCorner: Shape {
    var radius: CGFloat = 25
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


#Preview {
    FocusOneStep()
}
