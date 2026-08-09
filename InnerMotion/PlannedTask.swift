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

    // يربط الخطة بنفس جلسة التخطيط
    var planningSessionID: UUID?

    @Relationship(deleteRule: .cascade)
    var steps: [TaskStep]

    init(
        title: String,
        priority: String,
        dueDate: Date? = nil,
        order: Int,
        planningSessionID: UUID? = nil,
        steps: [TaskStep] = []
    ) {
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.order = order
        self.planningSessionID = planningSessionID
        self.steps = steps
    }
}
