//
//  UserTask.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 26/02/1448 AH.
//

import Foundation
import SwiftData

@Model
final class UserTask {

    var title: String
    var priority: String
    var dueDate: Date?
    var status: String
    var createdAt: Date

    // يحدد أي جلسة إضافة تنتمي لها المهمة
    var planningSessionID: UUID?

    // false = المستخدم أضافها لكن AI ما خلص تخطيطها
    // true = AI أنشأ لها خطة بنجاح
    // nil = مهمة قديمة من قبل هذا التعديل
    var isPlanned: Bool?

    init(
        title: String,
        priority: String,
        dueDate: Date? = nil,
        status: String = "Not Started",
        createdAt: Date = Date(),
        planningSessionID: UUID? = nil,
        isPlanned: Bool? = nil
    ) {
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.status = status
        self.createdAt = createdAt
        self.planningSessionID = planningSessionID
        self.isPlanned = isPlanned
    }
}
