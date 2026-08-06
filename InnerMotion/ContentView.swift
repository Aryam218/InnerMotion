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
    @State private var textScale: CGFloat = 0.95

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
                        .padding(.top, 140)
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        textOpacity = 1.0
                        textScale = 1.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
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
