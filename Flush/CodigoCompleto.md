### Arquivo: \⁠ ./ViewModel/Managers/CoreDataManager.swift\ ⁠
⁠ swift
//
//  CoreDataManager.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import Foundation
import CoreData

class CoreDataManager{
    let persistentContainer: NSPersistentContainer
    static let shared = CoreDataManager()
    
    var viewContext: NSManagedObjectContext{
        return self.persistentContainer.viewContext
    }
    
    init(){
        self.persistentContainer = NSPersistentContainer(name: "Database")
        self.persistentContainer.loadPersistentStores { (description, error) in
            if let error = error{
                fatalError("Error loading persistent stores: \(error)")
            }
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/NotesViewModel.swift\ ⁠
⁠ swift
//
//  NotesViewModel.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import Foundation
import CoreData
import Combine

class NotesViewModel: ObservableObject {
    @Published var savedNotes: [Notes] = []
    
    init(){
        self.fetchNotes()
    }
    
    // funcao que carrega todos as notas do banco e atrbui na lista notes
    func fetchNotes(){
        let request = NSFetchRequest<Notes>(entityName: "Notes")
        do{
            try self.savedNotes = CoreDataManager.shared.viewContext.fetch(request)

        } catch let error{
            fatalError("Error when trying to fetch notes data:\(error)")
        }
       
    }
    
    // funcao para salvar notes (chama ela sempre que quer subir efetivamente para o banco)
    func saveNotes(){
        do{
            try CoreDataManager.shared.viewContext.save()
        } catch let error{
            CoreDataManager.shared.viewContext.rollback()
            print("Error when trying to save new book: \(error)")
        }
    }
    
    // funcao que adiciona notas com os parametros a serem recebidos pela view
    func addNote(noteTitle: String, noteDescription: String, noteCategory: String, notePhoto: String){
        let newNote = Notes(context: CoreDataManager.shared.viewContext)
        newNote.noteTitle = noteTitle
        newNote.noteDescription = noteDescription
        newNote.noteCategory = noteCategory
        newNote.notePhoto = notePhoto
        
        // funcao para salvar os notas
        self.saveNotes()
        
    }
    
    // funcao para deletar notas
    func deleteNote(indexSet: IndexSet){

        guard let index = indexSet.first else { return }
        let note = self.savedNotes[index]
        
        CoreDataManager.shared.viewContext.delete(note)
        self.saveNotes()
        self.fetchNotes()

    }
    
    func updateNote(indexSet: IndexSet,noteTitle: String?, noteDescription: String?, noteCategory: String?, notePhoto: String?){
        guard let index = indexSet.first else { return }
        let note = self.savedNotes[index]
        
        note.noteTitle = noteTitle
        note.noteDescription = noteDescription
        note.noteCategory = noteCategory
        note.notePhoto = notePhoto
        
        self.saveNotes()
        self.fetchNotes()
    }
    
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/BooksViewModel.swift\ ⁠
⁠ swift
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
    func saveBook(){
        do{
            try CoreDataManager.shared.viewContext.save()
        } catch let error{
            CoreDataManager.shared.viewContext.rollback()
            print("Error when trying to save new book: \(error)")
        }
    }
    
    // funcao que adiciona livros com os parametros a serem recebidos pela view
    func addBook(bookTitle: String, bookAuthor: String, bookCover: Data, bookCategory: String, bookTotalPages: Int16, bookCurrentPage: Int16, bookGoal: Int16, isTimerRunning: Bool, wasLastPageAdded: Bool){
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
 ⁠

---

### Arquivo: \⁠ ./CH4_BooksApp.swift\ ⁠
⁠ swift
//
//  CH4_BooksApp.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import SwiftUI
import CoreData

@main
struct CH4_BooksApp: App {
    let persistenceController = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Core/ContentView.swift\ ⁠
⁠ swift
//
//  ContentView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import SwiftUI
import CoreData

struct ContentView: View {

    
    var body: some View {
        
    }
}

#Preview {
    ContentView()
}
 ⁠

---

### Arquivo: \⁠ ./View/CreateNoteView.swift\ ⁠
⁠ swift
//
//  create-note-view.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 14/08/26.
//

import Foundation
import SwiftUI

struct CreateNoteView: View {
    var body: some View {
        Text("Create Note View")
        Button(action: {
           
        }) {
            HStack {
                Text("Crie uma nova lista")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    CreateNoteView()
        .environmentObject(CoreDataManager())
}
 ⁠

---

