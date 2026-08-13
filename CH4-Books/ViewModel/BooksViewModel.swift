//
//  BooksViewModel.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import Foundation
import CoreData
import Combine

class BooksViewModel: ObservableObject {
    @Published var books: [Books] = []
    
    init(){
        self.fetchBooks()
    }
    
    func fetchBooks(){
        let request = NSFetchRequest<Books>(entityName: "Books")
        do{
            try self.books = CoreDataManager.shared.viewContext.fetch(request)

        } catch let error{
            print("Error when trying to fetch books data:\(error)")
        }
       
    }
    
    func addBook(bookTitle: String, bookAuthor: String, bookCover: String, bookCategory: String, bookTotalPages: Int16, bookCurrentPage: Int16, bookGoal: Int16, isTimerRunning: Bool, wasLastPageAdded: Bool){
        let newBook = Books(context: CoreDataManager.shared.viewContext)
        newBook.bookTitle = bookTitle
        newBook.bookAuthor = bookAuthor
        newBook.bookCover = bookCover
        newBook.bookCategory = bookCategory
        newBook.bookTotalPages = bookTotalPages
        newBook.bookCurrentPage = bookCurrentPage
        newBook.bookGoal = bookGoal
        newBook.isTimerRunning = isTimerRunning
        newBook.wasLastPageAdded = wasLastPageAdded
        
        
    }
}
