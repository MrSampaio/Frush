//
//  BooksViewModel.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//
// test
import Foundation
import CoreData
import Combine

class BooksViewModel: ObservableObject {
    @Published var savedBooks: [Books] = []
    
    enum BookError: LocalizedError {
        case invalidTitle
        //case invalidAuthor
        case invalidTotalPages
        case invalidCurrentPage
        case invalidGoal
        case invalidPageLogic
        case savingError
        
        var errorDescription: String? {
            switch self {
            case .invalidTitle:
                return "Insira um título válido."
//            case .invalidAuthor:
//                return "Insira um autor válido."
            case .invalidTotalPages:
                return "Número de páginas inválido."
            case .invalidCurrentPage:
                return "Página atual inválida."
            case .invalidGoal:
                return "Escolha uma meta de leitura."
            case .invalidPageLogic:
                return "Página atual deve ser menor que o total de páginas."
            case .savingError:
                return "Houve um erro ao salvar o livro. Tente novamente."
                
            }
        }
    }
    
    let goalOptions = ["5", "10", "15", "20", "30", "45", "60"]
    
    let bookCategories = ["Romance", "Suspense", "Ação", "Terror", "Drama", "Literatura", "Educativo", "Infantil", "Infantojuvenil"]
    
    init(){
        self.fetchBooks()
    }
    
    // funcao que carrega todos os livros do banco e atrbui na lista books
    func fetchBooks(){
        let request = NSFetchRequest<Books>(entityName: "Books")
        do{
            try self.savedBooks = CoreDataManager.shared.viewContext.fetch(request)

        } catch let error{
            fatalError("Error when trying to fetch books data: \(error)")
        }
       
    }
    
    // funcao para salvar livros (chama ela sempre que quer subir efetivamente para o banco)
    func saveBook() throws{
        do{
            try CoreDataManager.shared.viewContext.save()
        } catch let error{
            CoreDataManager.shared.viewContext.rollback()
            print("Error when trying to save new book: \(error)")
            throw BookError.savingError
        }
    }
    
    // funcao que adiciona livros com os parametros a serem recebidos pela view
    func addBook(bookTitle: String, bookAuthor: String, bookCover: Data, bookCategory: String, bookTotalPages: Int16, bookCurrentPage: Int16, bookGoal: Int16) throws{
        
        let cleanTitle = bookTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                
        if cleanTitle.isEmpty {
            throw BookError.invalidTitle
        }
        
        if bookTotalPages <= 0 {
            throw BookError.invalidTotalPages
        }
        
        if bookCurrentPage < 0{
            throw BookError.invalidCurrentPage
        }
        
        if bookCurrentPage > bookTotalPages {
            throw BookError.invalidPageLogic
        }
        
        if bookGoal <= 0{
            throw BookError.invalidGoal
        }
        
        let newBook = Books(context: CoreDataManager.shared.viewContext)
        newBook.bookTitle = cleanTitle
        newBook.bookAuthor = bookAuthor.isEmpty ? "Desconhecido" : bookAuthor
        newBook.bookCover = bookCover
        newBook.bookCategory = bookCategory.isEmpty ? "Sem categoria" : bookCategory
        newBook.bookTotalPages = bookTotalPages
        newBook.bookCurrentPage = bookCurrentPage
        newBook.bookGoal = bookGoal
        newBook.isTimerRunning = false
        newBook.wasLastPageAdded = true
        
        // funcao para salvar os livros
        try self.saveBook()
        
        //return true
        
    }
    
    // funcao para deletar livros
    func deleteBook(indexSet: IndexSet) throws{

        guard let index = indexSet.first else { return }
        let book = self.savedBooks[index]
        
        CoreDataManager.shared.viewContext.delete(book)
        
        try self.saveBook()
        
        self.fetchBooks()

    }
    
    func updateBook(IndexSet: IndexSet,bookTitle: String?, bookAuthor: String?, bookCover: Data?, bookCategory: String?, bookTotalPages: Int16, bookCurrentPage: Int16, bookGoal: Int16) throws{
        guard let index = IndexSet.first else { return }
        let book = self.savedBooks[index]
        
        book.bookTitle = bookTitle == book.bookTitle ? book.bookTitle : bookTitle
        book.bookAuthor = bookAuthor == book.bookAuthor ? book.bookAuthor : bookAuthor
        book.bookCover = bookCover == book.bookCover ? book.bookCover : bookCover
        book.bookCategory = bookCategory == book.bookCategory ? book.bookCategory : bookCategory
        book.bookTotalPages = bookTotalPages == book.bookTotalPages ? book.bookTotalPages : bookTotalPages
        book.bookCurrentPage = bookCurrentPage == book.bookCurrentPage ? book.bookCurrentPage : bookCurrentPage
        book.bookGoal = bookGoal == book.bookGoal ? book.bookGoal : bookGoal
                
        try self.saveBook()
        self.fetchBooks()
    }
}
