//
//  ContentView.swift
//  InnerMotion
//
//  Created by renad Alharbi on 21/02/1448 AH.
//

import SwiftUI

struct ContentView: View {

    @State private var isActive = false

    // حالات التحكم بأنيميشن ظهور النص
    @State private var textOpacity = 0.0
    @State private var textScale: CGFloat = 0.94
    @State private var textOffset: CGFloat = 14

    var body: some View {
        NavigationStack {

            if isActive {

                OnboardingView()

            } else {

                ZStack(alignment: .center) {

                    // صورة الخلفية (تغطي الشاشة بالكامل وبداخلها اللوجو)
                    Image("SplashBackground")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    // اسم التطبيق - تم إزاحته للأسفل ليكون تحت اللوجو مباشرة
                    Text("Inner Motion")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.appPrimary)
                        .opacity(textOpacity)
                        .scaleEffect(textScale)
                        .offset(y: textOffset)
                        .padding(.top, 140)
                }
                .onAppear {

                    // حركة ظهور الاسم
                    withAnimation(
                        .spring(
                            response: 1.25,
                            dampingFraction: 0.88
                        )
                    ) {
                        textOpacity = 1.0
                        textScale = 1.0
                        textOffset = 0
                    }

                    // الانتقال بعد انتهاء السبلاش
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
