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
    
    enum NoteError: LocalizedError {
        case invalidTitle
        //case invalidAuthor
        case invalidTotalPages
        case invalidCurrentPage
        case invalidGoal
        case invalidPageLogic
        
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
                
            }
        }
    }
    
    let noteCategories = ["Citação", "Resumo", "Pensamento", "Crítica", "Conceito", "Lição", "Pergunta", "Favorito"]
    
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
    func addNote(noteTitle: String, noteDescription: String, noteCategory: String, notePhoto: String, to book: Books){
        let newNote = Notes(context: CoreDataManager.shared.viewContext)
        newNote.noteTitle = noteTitle
        newNote.noteDescription = noteDescription
        newNote.noteCategory = noteCategory
        newNote.notePhoto = notePhoto
        
        newNote.book = book
        
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
