//
//  test.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 17/08/26.
//

import Foundation
import SwiftUI
import CoreData

struct PreviewProviderHelper {
    static var sampleBook: Books {
        let container = NSPersistentContainer(name: "Database")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Erro ao carregar container de teste: \(error)")
            }
        }
        
        let context = container.viewContext
        let book = Books(context: context)
        book.bookTitle = "Clean Code"
        book.bookAuthor = "Robert C. Martin"
        book.bookCategory = "Tecnologia"
        book.bookCurrentPage = 45
        book.bookGoal = 200
        book.bookTotalPages = 425
        book.isTimerRunning = false
        book.wasLastPageAdded = false
        
        return book
    }
}
