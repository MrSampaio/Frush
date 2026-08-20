//
//  BooksViewModel.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//
// test
import Foundation
import SwiftUI
import CoreData
import Combine
import PhotosUI

class BooksViewModel: ObservableObject {
    
//    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @Published var savedBooks: [Books] = []
    
    enum BookError: LocalizedError {
        case invalidTitle
        case invalidAuthor
        case invalidTotalPages
        case invalidCurrentPage
        //case invalidGoal
        case invalidPageLogic
        case savingError
        
        var errorDescription: String? {
            switch self {
            case .invalidTitle:
                return "Insira um título válido."
            case .invalidAuthor:
                return "Insira um autor válido."
            case .invalidTotalPages:
                return "Número de páginas inválido."
            case .invalidCurrentPage:
                return "Página atual inválida."
//            case .invalidGoal:
//                return "Escolha uma meta de leitura."
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
    
    func countReadedPages() -> Int16{
        var totalReadedPages: Int16 = 0
        for book in self.savedBooks{
            totalReadedPages += book.bookCurrentPage
        }
        
        return totalReadedPages
    }
    
    // funcao que carrega todos os livros do banco e atrbui na lista books
    func fetchBooks(){
        let request = NSFetchRequest<Books>(entityName: "Books")
        do{
            try self.savedBooks = CoreDataManager.shared.viewContext.fetch(request)
            countReadedPages()

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
    func addBook(bookTitle: String, bookAuthor: String, bookCover: UIImage?, bookCategory: String, bookTotalPages: String) throws{
        
        
        let totalPagesInt = Int16(bookTotalPages) ?? 0
//        let currentePageInt = Int16(bookCurrentPage) ?? 0
        //let lastPageInt = Int16(bookLastPage) ?? 0
        
        let cleanTitle = bookTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanAuthor = bookAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanTitle.isEmpty {
            throw BookError.invalidTitle
        }
        
        if cleanAuthor.isEmpty {
            throw BookError.invalidAuthor
        }
        
        if totalPagesInt <= 0 {
            throw BookError.invalidTotalPages
        }
        
        let defaultImageData = UIImage(named: "defaultBook")?.jpegData(compressionQuality: 1) ?? Data()
        let coverData = bookCover?.jpegData(compressionQuality: 1) ?? defaultImageData
        
        let newBook = Books(context: CoreDataManager.shared.viewContext)
        newBook.bookTitle = cleanTitle
        newBook.bookAuthor = cleanAuthor.isEmpty ? "Desconhecido" : cleanAuthor
        newBook.bookCover = coverData
        newBook.bookCategory = bookCategory.isEmpty ? "Sem categoria" : bookCategory
        newBook.bookTotalPages = totalPagesInt
//        newBook.bookCurrentPage = bookCurrentPage
//        newBook.bookGoal = bookGoal
        newBook.isTimerRunning = false
        newBook.wasLastPageAdded = true

        
//        if currentePageInt <= 0 {
//            throw BookError.invalidCurrentPage
//        }
        
        
//        if bookCurrentPage < 0{
//            throw BookError.invalidCurrentPage
//        }
//        
//        if bookCurrentPage > bookTotalPages {
//            throw BookError.invalidPageLogic
//        }
        
//        if bookGoal <= 0{
//            throw BookError.invalidGoal
//        }

        
        try self.saveBook()
        
        self.fetchBooks()
    }
    
    // funcao para deletar livros
    func deleteBook(book: Books) throws{

//        guard let index = indexSet.first else { return }
//        let book = self.savedBooks[index]
        
        CoreDataManager.shared.viewContext.delete(book)
        self.savedBooks.removeAll(where: { $0.objectID == book.objectID })
        
        try self.saveBook()
        self.fetchBooks()

    }
    
    func updateBook(book: Books, bookTitle: String, bookAuthor: String, bookCover: UIImage?, bookCategory: String, bookTotalPages: String) throws {
        
//        guard let index = IndexSet.first else { return }
//        
//        let book = self.savedBooks[index]
        
        let totalPagesInt = Int16(bookTotalPages) ?? 0
        
        let finalTitle = (bookTitle.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let defaultImageData = UIImage(named: "defaultBook")?.jpegData(compressionQuality: 1) ?? Data()
        
        let coverData = bookCover?.jpegData(compressionQuality: 1) ?? defaultImageData

        if finalTitle.isEmpty {
            throw BookError.invalidTitle
        }
        
        if totalPagesInt <= 0 {
            throw BookError.invalidTotalPages
        }
        
        
        //let finalTotalPages = bookTotalPages ?? book.bookTotalPages
        

//        let finalCurrentPage = bookCurrentPage ?? book.bookCurrentPage
//        let finalGoal = bookGoal ?? book.bookGoal
        
//        if finalTotalPages <= 0 {
//            throw BookError.invalidTotalPages
//        }
       
        
//        if finalCurrentPage < 0 {
//            throw BookError.invalidCurrentPage
//        }
//        
//        if finalCurrentPage > finalTotalPages {
//            throw BookError.invalidPageLogic
//        }
        
//        if finalGoal <= 0 {
//            throw BookError.invalidGoal
//        }
        
        // só aplica as mudanças se passou em todas as validações
//        book.id = UUID()
        
        if(book.bookTitle != finalTitle){
            book.bookTitle = finalTitle
        }
        
        if(book.bookAuthor != bookAuthor){
            book.bookAuthor = bookAuthor
        }
        
        if(book.bookCategory != bookCategory){
            book.bookCategory = bookCategory
        }
        
        if(book.bookTotalPages != totalPagesInt){
            book.bookTotalPages = totalPagesInt
        }
        
        if(book.bookCover != coverData){
            book.bookCover = coverData
        }
        
        try self.saveBook()
        self.fetchBooks()
    }
}
