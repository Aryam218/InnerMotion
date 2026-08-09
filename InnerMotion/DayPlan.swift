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

    init(
        energyLevel: String,
        availableMinutes: Int,
        createdAt: Date = Date()
    ) {
        self.energyLevel = energyLevel
        self.availableMinutes = availableMinutes
        self.createdAt = createdAt
    }
}
