//
//  UserSettingsModel.swift
//  CH4-Books
//
//  Created by Lucas on 23/08/26.
//

import Foundation
import SwiftData

final class UserSettingsModel {
    @Attribute(.unique) var id: UUID
    var dailyGoalMinutes: Int16
    //------------------refazer essa opcao usando o Codable------------------
    //var lastBookSelected:
    var lastReadingDate: Date?
    var minutesReadToday: Int16
    
    init(id: UUID, dailyGoalMinutes: Int16, lastReadingDate: Date?, minutesReadToday: Int16) {
        self.id = id
        self.dailyGoalMinutes = dailyGoalMinutes
        self.lastReadingDate = lastReadingDate
        self.minutesReadToday = minutesReadToday
    }
}
