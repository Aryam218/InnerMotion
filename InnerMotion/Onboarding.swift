//
//  Onboarding.swift
//  InnerMotion
//
//  Created by Renad Sameer Alharbi on 22/02/1448 AH.
//


import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ZStack {
            // 1. الصورة كخلفية كاملة لكل الشاشة
            Image("OnboardingIllustration") // اسم الصورة في Assets
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // 2. المحتوى المكتوب والأزرار فوق الخلفية
            VStack {
                // العنوان والوصف في الأعلى
                VStack(spacing: 10) {
                    Text("When starting feels hard")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(red: 0.215, green: 0.0, blue: 0.541))
                    
                    Text("Break overwhelming tasks\ninto tiny first steps.")
                        .font(.system(size: 15, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.337, green: 0.239, blue: 0.416))
                }
                .padding(.top, 110) // مسافة علوية لترتيب النص فوق الرسمة
                
                Spacer() // يدفع الزر للأسفل
                
                // زر Get Started في الأسفل
                NavigationLink(destination: HomeView()) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.459, green: 0.376, blue: 0.557))
                        .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OnboardingView()
}
