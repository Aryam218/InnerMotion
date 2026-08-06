//
//  HomeView.swift
//  InnerMotion
//
//  Created by Renad Sameer Alharbi on 22/02/1448 AH.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // خلفية الصفحة البيج
            Color(red: 0.992, green: 0.973, blue: 0.949)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // 1. الترويسة والعنوان الرئيسي
                    VStack(spacing: 18) {
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "bell")
                                    .font(.system(size: 26, weight: .regular))
                                    .foregroundColor(Color(red: 0.28, green: 0.18, blue: 0.42))
                            }
                        }
                        .padding(.top, 5)
                        
                        Text("Welcome to Inner Motion")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.22, green: 0.05, blue: 0.48))
                            .multilineTextAlignment(.center)
                        
                        Text("Small steps, real progress.")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    
                    // 2. بطاقات الفيتشرز
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What would help you right now?")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.45))
                            .padding(.leading, 2)
                        
                        // البطاقة الأولى (البنفسجية) - noise
                        NavigationLink(destination: AddTaskView()) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 50, height: 48)
                                    
                                    Image("noise")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 100)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("I have a task, but I\ncan’t start")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(red: 0.22, green: 0.05, blue: 0.48))
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(2)
                                    
                                    Text("Help me begin, step by step")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.55))
                                }
                                
                                Spacer(minLength: 0)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.45))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.92, green: 0.89, blue: 0.97))
                            .cornerRadius(22)
                        }
                        
                        // البطاقة الثانية (الخضراء) - tree
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 48, height: 48)
                                
                                Image("tree")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 100)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("I don’t know what I need to\ndo right now")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.4))
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(2)
                                
                                Text("Suggest something for me to do")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.5))
                            }
                            
                            Spacer(minLength: 0)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.45))
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.86, green: 0.89, blue: 0.78))
                        .cornerRadius(22)
                    }
                    .padding(.horizontal, 20)
                    
                    // 3. قسم العودة للمهمة السابقة
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Continue where you left off")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.45))
                            .padding(.leading, 2)
                        
                        VStack(alignment: .trailing, spacing: 12) {
                            HStack(alignment: .top, spacing: 16) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.9, green: 0.86, blue: 0.94))
                                    .frame(width: 58, height: 58)
                                    .overlay(
                                        Image(systemName: "book")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color(red: 0.35, green: 0.2, blue: 0.55))
                                    )
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Study for math test")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(Color(red: 0.22, green: 0.05, blue: 0.48))
                                    
                                    Text("Step 2 of 4")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                                    
                                    // شريط التقدم
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(height: 4)
                                            
                                            Capsule()
                                                .fill(Color(red: 0.45, green: 0.35, blue: 0.6))
                                                .frame(width: geo.size.width * 0.55, height: 4)
                                            
                                            Circle()
                                                .fill(Color(red: 0.3, green: 0.15, blue: 0.45))
                                                .frame(width: 8, height: 8)
                                                .offset(x: (geo.size.width * 0.55) - 4)
                                        }
                                    }
                                    .frame(height: 8)
                                    .padding(.top, 4)
                                }
                                
                                Spacer(minLength: 0)
                            }
                            
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Text("Continue Task")
                                        .font(.system(size: 12, weight: .medium))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 9, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color(red: 0.45, green: 0.38, blue: 0.58))
                                .cornerRadius(18)
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.95, green: 0.93, blue: 0.94))
                        .cornerRadius(22)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 110)
            }
            
            // 4. شريط التنقل السفلي
            CustomTabBar()        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeView()
}
