//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 23/08/26.
//

import Foundation
import SwiftData

@Model
final class Books {
    var bookAuthor: String
    var bookCategory: String
    var bookCover: Data?
    var bookCurrentPage: Int16
    var bookGoal: Int16
    var bookTitle: String
    var bookTotalPages: Int16
    var isTimerRunning: Bool
    var wasLastPageAdded: Bool
    
    @Relationship(inverse: \Notes.book)
    var notes: [Notes]? = []
    
    var userSetttings: UserSettings?
    
    init(bookAuthor: String, bookCategory: String, bookCover: Data? = nil, bookCurrentPage: Int16, bookGoal: Int16, bookTitle: String, bookTotalPages: Int16, isTimerRunning: Bool, wasLastPageAdded: Bool) {
        self.bookAuthor = bookAuthor
        self.bookCategory = bookCategory
        self.bookCover = bookCover
        self.bookCurrentPage = bookCurrentPage
        self.bookGoal = bookGoal
        self.bookTitle = bookTitle
        self.bookTotalPages = bookTotalPages
        self.isTimerRunning = isTimerRunning
        self.wasLastPageAdded = wasLastPageAdded
    }
}

