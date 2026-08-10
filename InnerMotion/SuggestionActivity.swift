//
//  SuggestionActivity.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 27/02/1448 AH.
//

import Foundation
import SwiftData

@Model
final class SuggestionActivity {

    var category: String
    var energyLevel: String
    var availableTime: String
    var location: String

    var activityText: String
    var estimatedMinutes: Int
    var difficulty: String

    var feedback: String?

    var createdAt: Date

    init(
        category: String,
        energyLevel: String,
        availableTime: String,
        location: String,
        activityText: String,
        estimatedMinutes: Int,
        difficulty: String,
        feedback: String? = nil,
        createdAt: Date = Date()
    ) {
        self.category = category
        self.energyLevel = energyLevel
        self.availableTime = availableTime
        self.location = location

        self.activityText = activityText
        self.estimatedMinutes = estimatedMinutes
        self.difficulty = difficulty

        self.feedback = feedback
        self.createdAt = createdAt
    }
}
