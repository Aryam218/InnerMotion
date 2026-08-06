//
//  CustomTabBar.swift
//  InnerMotion
//
//  Created by Renad Sameer Alharbi on 22/02/1448 AH.
//
import SwiftUI

struct CustomTabBar: View {
    // حالة لمتابعة التبويب المتبوع حالياً
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            // 1. Home Button
            Button(action: { selectedTab = 0 }) {
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .font(.system(size: 18))
                    Text("Home")
                        .font(.system(size: 11, weight: selectedTab == 0 ? .bold : .regular))
                }
                .foregroundColor(selectedTab == 0 ? Color(red: 0.215, green: 0.0, blue: 0.541) : Color(red: 0.337, green: 0.239, blue: 0.416).opacity(0.6))
            }
            
            Spacer()
            
            // 2. My Tasks Button
            Button(action: { selectedTab = 1 }) {
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == 1 ? "clipboard.fill" : "clipboard")
                        .font(.system(size: 18))
                    Text("My Tasks")
                        .font(.system(size: 11, weight: selectedTab == 1 ? .bold : .regular))
                }
                .foregroundColor(selectedTab == 1 ? Color(red: 0.215, green: 0.0, blue: 0.541) : Color(red: 0.337, green: 0.239, blue: 0.416).opacity(0.6))
            }
            
            Spacer()
            
            // 3. Achievements Button
            Button(action: { selectedTab = 2 }) {
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == 2 ? "star.fill" : "star")
                        .font(.system(size: 18))
                    Text("Achievements")
                        .font(.system(size: 11, weight: selectedTab == 2 ? .bold : .regular))
                }
                .foregroundColor(selectedTab == 2 ? Color(red: 0.215, green: 0.0, blue: 0.541) : Color(red: 0.337, green: 0.239, blue: 0.416).opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.95))
        .cornerRadius(25)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: -4)
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0))
}
