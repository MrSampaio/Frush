//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 23/08/26.
//

import Foundation
import SwiftData

@Model
final class Book{
    @Attribute(.unique) var id: UUID
    var bookAuthor: String
    var bookCategory: String
    var bookCover: Data?
    var bookcurrentPage: Int16
    var bookGoal: Int16
    var bookTitle: String
    var bookTotalPages: Int16
    var isTimeRunning: Bool
    var wasLastPageAdded: Bool
    
    init(id: UUID, bookAuthor: String, bookCategory: String, bookCover: Data? = nil, bookcurrentPage: Int16, bookGoal: Int16, bookTitle: String, bookTotalPages: Int16, isTimeRunning: Bool, wasLastPageAdded: Bool) {
        self.id = id
        self.bookAuthor = bookAuthor
        self.bookCategory = bookCategory
        self.bookCover = bookCover
        self.bookcurrentPage = bookcurrentPage
        self.bookGoal = bookGoal
        self.bookTitle = bookTitle
        self.bookTotalPages = bookTotalPages
        self.isTimeRunning = isTimeRunning
        self.wasLastPageAdded = wasLastPageAdded
    }
    
    
}
