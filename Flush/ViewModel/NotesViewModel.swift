//
//  NotesViewModel.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 14/08/26.
//
 
import Foundation
import CoreData
import Combine
import UIKit
 
class NotesViewModel: ObservableObject {
    @Published var savedNotes: [Notes] = []
    
    enum NoteError: LocalizedError {
        case invalidTitle
        case invalidDescription
        case invalidCategory
        case invalidBook
        case savingError
        
        var errorDescription: String? {
            switch self {
            case .invalidTitle:
                return "Insira um título válido."
            case .invalidDescription:
                return "Escreva o conteúdo da nota."
            case .invalidCategory:
                return "Escolha uma categoria para a nota."
            case .invalidBook:
                return "Selecione o livro relacionado a essa nota."
            case .savingError:
                return "Houve um erro ao salvar a nota. Tente novamente."
            }
        }
    }
    
    // mesma lista usada no CategoryMenuView da sheet
    let noteCategories = ["Citação", "Resumo", "Pensamento", "Crítica", "Conceito", "Lição", "Pergunta", "Favorito"]
    
    init() {
        self.fetchNotes()
    }
    
    // funcao que carrega todas as notas do banco e atribui na lista savedNotes
    func fetchNotes() {
        let request = NSFetchRequest<Notes>(entityName: "Notes")
        do {
            try self.savedNotes = CoreDataManager.shared.viewContext.fetch(request)
        } catch let error {
            fatalError("Error when trying to fetch notes data: \(error)")
        }
    }
    
    // funcao para salvar notas (chama ela sempre que quer subir efetivamente para o banco)
    func saveNote() throws {
        do {
            try CoreDataManager.shared.viewContext.save()
        } catch let error {
            CoreDataManager.shared.viewContext.rollback()
            print("Error when trying to save new note: \(error)")
            throw NoteError.savingError
        }
    }
    
    // funcao que adiciona notas com os parametros a serem recebidos pela view
    func addNote(noteTitle: String, noteDescription: String, noteCategory: String, notePhotos: [UIImage], to book: Books?) throws {
            
            let cleanTitle = noteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanDescription = noteDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if cleanTitle.isEmpty { throw NoteError.invalidTitle }
            if cleanDescription.isEmpty { throw NoteError.invalidDescription }
            if noteCategory.isEmpty { throw NoteError.invalidCategory }
            guard let book else { throw NoteError.invalidBook }
            
            let newNote = Notes(context: CoreDataManager.shared.viewContext)
            newNote.noteTitle = cleanTitle
            newNote.noteDescription = cleanDescription
            newNote.noteCategory = noteCategory
            newNote.book = book
            
            for photo in notePhotos {
                if let fileName = self.savePhotoToDisk(photo) {
                    
                    let noteImage = NoteImage(context: CoreDataManager.shared.viewContext)
                    noteImage.id = UUID()
                    noteImage.fileName = fileName
                    
                    noteImage.note = newNote
                }
            }
            try self.saveNote()
        }
    
    // funcao para deletar notas
    func deleteNote(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let note = self.savedNotes[index]
        
        CoreDataManager.shared.viewContext.delete(note)
        
        do {
            try self.saveNote()
        } catch let error {
            print("Erro ao deletar nota: \(error)")
        }
        
        self.fetchNotes()
    }
    
    private func savePhotoToDisk(_ image: UIImage?) -> String? {
        guard let image, let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let fileName = "\(UUID().uuidString).jpg"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
            return fileName
        } catch {
            print("Erro ao salvar imagem no disco: \(error)")
            return nil
        }
    }
}
