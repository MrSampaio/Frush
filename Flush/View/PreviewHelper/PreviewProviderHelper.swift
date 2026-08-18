//
//  test.swift
//  CH4-Books
//

import Foundation
import SwiftUI
import CoreData

struct PreviewProviderHelper {
    static let sharedContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Database")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Erro ao carregar container de teste: \(error)")
            }
        }
        return container
    }()
    
    static var sampleBook: Books {
        let context = sharedContainer.viewContext
        
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

#Preview {
    ZStack {
        HStack(spacing: 16) {
            BookCardView(
                book: PreviewProviderHelper.sampleBook
            )
        }
    }
    .environment(\.managedObjectContext, PreviewProviderHelper.sharedContainer.viewContext)
}
