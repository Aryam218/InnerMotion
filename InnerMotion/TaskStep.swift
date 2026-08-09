//
//  TaskStep.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 26/02/1448 AH.
//

import Foundation
import SwiftData

@Model
final class TaskStep {
    var order: Int
    var text: String
    var estimatedMinutes: Int
    var isCompleted: Bool

    init(
        order: Int,
        text: String,
        estimatedMinutes: Int,
        isCompleted: Bool = false
    ) {
        self.order = order
        self.text = text
        self.estimatedMinutes = estimatedMinutes
        self.isCompleted = isCompleted
    }
}
