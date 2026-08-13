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
    @Published var savedBooks: [Books] = []
    
    init(){
        self.fetchBooks()
    }
    
    // funcao que carrega todos os livros do banco e atrbui na lista books
    func fetchBooks(){
        let request = NSFetchRequest<Books>(entityName: "Books")
        do{
            try self.savedBooks = CoreDataManager.shared.viewContext.fetch(request)

        } catch let error{
            fatalError("Error when trying to fetch books data:\(error)")
        }
       
    }
    
    // funcao para salvar livros (chama ela sempre que quer subir efetivamente para o banco)
    func saveBook(){
        do{
            try CoreDataManager.shared.viewContext.save()
        } catch let error{
            CoreDataManager.shared.viewContext.rollback()
            print("Error when trying to save new book: \(error)")
        }
    }
    
    // funcao que adiciona livros com os parametros a serem recebidos pela view
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
        
        // funcao para salvar os livros
        self.saveBook()
        
    }
    
    // funcao para deletar livros
    func deleteBook(indexSet: IndexSet){

        guard let index = indexSet.first else { return }
        let book = self.savedBooks[index]
        
        CoreDataManager.shared.viewContext.delete(book)
        self.saveBook()
        self.fetchBooks()

    }
    

}
