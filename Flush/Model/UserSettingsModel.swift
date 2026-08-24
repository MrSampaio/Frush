//
//  UserSettingsModel.swift
//  CH4-Books
//
//  Created by Lucas on 23/08/26.
//

import Foundation
import SwiftData

@Model
final class UserSettings1 {
    var dailyGoalMinutes: Int16
    var lastReadingDate: Date?
    var minutesReadToday: Int16
    
    
    @Attribute(.transformable(by: NSSecureUnarchiveFromDataTransformer.self))
    var lastBookSelected: Data?
    
    @Relationship(inverse: \Books1.userSetttings)
    var lastBookReaded: Books1?
    
    init(dailyGoalMinutes: Int16, lastReadingDate: Date? = nil, minutesReadToday: Int16, lastBookSelected: Data? = nil) {
        self.dailyGoalMinutes = dailyGoalMinutes
        self.lastReadingDate = lastReadingDate
        self.minutesReadToday = minutesReadToday
        self.lastBookSelected = lastBookSelected
    }
}
