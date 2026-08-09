//
//  DayPlan.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 26/02/1448 AH.
//

import Foundation
import SwiftData

@Model
final class DayPlan {

    var energyLevel: String
    var availableMinutes: Int
    var createdAt: Date

    // يربط اختيار الطاقة والوقت
    // بنفس جلسة المهام الحالية
    var planningSessionID: UUID?

    init(
        energyLevel: String,
        availableMinutes: Int,
        createdAt: Date = Date(),
        planningSessionID: UUID? = nil
    ) {
        self.energyLevel = energyLevel
        self.availableMinutes = availableMinutes
        self.createdAt = createdAt
        self.planningSessionID = planningSessionID
    }
}
