import SwiftUI

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

struct breakTime: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        ZStack {

            Color.backgroundColor
                .ignoresSafeArea()

            VStack {

                // Top Bar (هوم بس، بدون سهم رجوع)
                HStack {
                    Spacer()

                    Button {

                    } label: {
                        Image(systemName: "house")
                            .font(.system(size: 28))
                    }
                    .buttonStyle(PressableIconStyle(normalColor: .primaryButton, pressedColor: .secondaryButton))
                }
                .padding(.horizontal, 25)
                .padding(.top, 15)

                Spacer().frame(height: 15)

                // الرسمة (كوب الشاي)
                Image("break")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 320)

                Spacer().frame(height: 30)

                // العنوان
                Text("Taking a Break is Okay")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer().frame(height: 20)

                // النص الفرعي
                VStack(spacing: 8) {
                    Text("Take a moment to rest.")
                    Text("We'll be here when you're ready.")
                }
                .font(.system(size: 17))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)

                Spacer()

                // زر الرجوع للخطوات (يرجعك لصفحة Focus One Step)
                Button {
                    dismiss()
                } label: {
                    Text("Back to My Steps")
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                }
                .buttonStyle(PressableCapsuleStyle(fillColor: .primaryButton, cornerRadius: 29))
                .padding(.horizontal, 35)
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    breakTime()
}
