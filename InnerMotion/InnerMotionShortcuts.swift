//
//  InnerMotionShortcuts.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 28/02/1448 AH.
//

import AppIntents

struct InnerMotionShortcuts: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {

        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task to \(.applicationName)",
                "Add task in \(.applicationName)",
                "Create a task in \(.applicationName)"
            ],
            shortTitle: "Add Task",
            systemImageName: "plus.circle"
        )
    }
}
