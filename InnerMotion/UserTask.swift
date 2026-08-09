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

    init(
        title: String,
        priority: String,
        dueDate: Date? = nil,
        status: String = "Not Started",
        createdAt: Date = Date()
    ) {
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.status = status
        self.createdAt = createdAt
    }
}
