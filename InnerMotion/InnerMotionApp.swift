//
//  InnerMotionApp.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 21/02/1448 AH.
//

import SwiftUI
import SwiftData

@main
struct InnerMotionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            UserTask.self,
            DayPlan.self,
            PlannedTask.self,
            TaskStep.self
        ])
    }
}

