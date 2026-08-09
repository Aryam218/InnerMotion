//
//  MainTabView.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 24/02/1448 AH.
//

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: Int

    // تقدرين تمررين تاب ابتدائي (مثلاً لما توصلين من صفحة ثانية وتبين تفتح على تاب معين)
    // الافتراضي 0 (Home) لو ما مررتي شي.
    init(initialTab: Int = 0) {
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // الصفحة الحالية
            Group {
                switch selectedTab {

                    
                case 0:
                    HomeView()

                case 1:
                    TaskListView()

                case 2:
                    MyAchievmentJar()

                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Navbar واحد ثابت
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 28)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainTabView()
}
