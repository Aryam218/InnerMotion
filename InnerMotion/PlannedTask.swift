//
//  PlannedTask.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 26/02/1448 AH.
//

import Foundation
import SwiftData

@Model
final class PlannedTask {
    var title: String
    var priority: String
    var dueDate: Date?
    var order: Int

    @Relationship(deleteRule: .cascade)
    var steps: [TaskStep]

    init(
        title: String,
        priority: String,
        dueDate: Date? = nil,
        order: Int,
        steps: [TaskStep] = []
    ) {
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.order = order
        self.steps = steps
    }
}
