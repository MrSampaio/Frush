//
//  UserSettingsModel.swift
//  CH4-Books
//
//  Created by Lucas on 23/08/26.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    var dailyGoalMinutes: Int16
    var lastReadingDate: Date?
    var minutesReadToday: Int16 = 0
    
    
    @Attribute(.transformable(by: NSSecureUnarchiveFromDataTransformer.self))
    var lastBookSelected: Data?
    
    @Relationship(inverse: \Books.userSetttings)
    var lastBookReaded: Books?
    
    init(dailyGoalMinutes: Int16) {
        self.dailyGoalMinutes = dailyGoalMinutes
        //        self.lastReadingDate = lastReadingDate
        //        self.minutesReadToday = minutesReadToday
        //        self.lastBookSelected = lastBookSelected
        
    }
}
