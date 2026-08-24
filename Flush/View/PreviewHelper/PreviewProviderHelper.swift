////
////  test.swift
////  CH4-Books
////
//
//import Foundation
//import SwiftUI
//import SwiftData
//
////essa mudanca e para que o codigo rode na thread principal
//@MainActor
//struct PreviewProviderHelper {
//    //    static let sharedContainer: NSPersistentContainer = {
//    //        let container = NSPersistentContainer(name: "Database")
//    //        let description = NSPersistentStoreDescription()
//    //        description.type = NSInMemoryStoreType
//    //        container.persistentStoreDescriptions = [description]
//    //
//    //        container.loadPersistentStores { _, error in
//    //            if let error = error {
//    //                print("Erro ao carregar container de teste: \(error)")
//    //            }
//    //        }
//    //        return container
//    //    }()
//    
//    static let sharedContainer: ModelContainer = {
//        do {
//            let config = ModelConfiguration(isStoredInMemoryOnly: true)
//            // Nota: Se Books tiver relacionamento com Notes, coloque Notes.self aqui também
//            let container = try ModelContainer(for: Books.self, Notes.self, configurations: config)
//            return container
//        } catch {
//            fatalError("Erro ao carregar container de teste: \(error)")
//        }
//    }()
//    
//    static var sampleBook: Books {
//        let context = sharedContainer.mainContext
//        
////        let book = Books(
////            bookAuthor: "Robert C. Martin",
////            bookCategory: "Tecnologia",
////            bookCurrentPage: 45,
////            bookGoal: 200,
////            bookTitle: "Clean Code",
////            bookTotalPages: 425,
////            isTimerRunning: false,
////            wasLastPageAdded: false
////        )
//        
//        //        book.bookTitle = "Clean Code"
//        //        book.bookAuthor = "Robert C. Martin"
//        //        book.bookCategory = "Tecnologia"
//        //        book.bookCurrentPage = 45
//        //        book.bookGoal = 200
//        //        book.bookTotalPages = 425
//        //        book.isTimerRunning = false
//        //        book.wasLastPageAdded = false
//        
//        
//        
//        return book
//    }
//    
//}
//
//#Preview {
//    ZStack {
//        HStack(spacing: 16) {
//            BookCardView(
//                book: PreviewProviderHelper.sampleBook
//            )
//        }
//    }
//    // 👇 4. Injetamos o contêiner do SwiftData na View
//    .modelContainer(PreviewProviderHelper.sharedContainer)
//}
