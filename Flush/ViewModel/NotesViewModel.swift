//
//  NotesViewModel.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 14/08/26.
//
 
import Foundation
import Combine
import UIKit
import SwiftData
import SwiftUI
 
class NotesViewModel: ObservableObject {
    @Published var savedNotes: [Notes] = []
    @Environment(\.modelContext) private var modelContext

    enum NoteError: LocalizedError {
        case invalidTitle
        case invalidDescription
        //case invalidCategory
        case invalidBook
        case savingError
        
        var errorDescription: String? {
            switch self {
            case .invalidTitle:
                return "Insira um título válido."
            case .invalidDescription:
                return "Escreva o conteúdo da nota."
            //case .invalidCategory:
              //  return "Escolha uma categoria para a nota."
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
    }
    
    // funcao que carrega todas as notas do banco e atribui na lista savedNotes
    func fetchNotes(context: ModelContext) {
        //let request = NSFetchRequest<Notes>(entityName: "Notes")
        let descriptor = FetchDescriptor<Notes>()
        do {
            try self.savedNotes = context.fetch(descriptor)
        } catch let error {
            fatalError("Error when trying to fetch notes data: \(error)")
        }
    }
    
    //depois avaliar se realemtne e necessaria
    func fetchNotes(for book: Books?, context: ModelContext) {
        guard let targetBook = book else {
            self.savedNotes = []
            return
        }
        
        let descriptor = FetchDescriptor<Notes>()
        
        do {
            let allNotes = try context.fetch(descriptor)
            self.savedNotes = allNotes.filter { $0.book?.persistentModelID == targetBook.persistentModelID }
        } catch let error {
            print("Erro ao buscar anotações do livro: \(error)")
        }
    }
    
    // funcao que adiciona notas com os parametros a serem recebidos pela view
    func addNote(noteTitle: String, noteDescription: String, noteCategory: String, notePhotos: [UIImage], to book: Books?, context: ModelContext) throws {
        
        let cleanTitle = noteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = noteDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanTitle.isEmpty { throw NoteError.invalidTitle }
        if cleanDescription.isEmpty { throw NoteError.invalidDescription }
        //if noteCategory.isEmpty { throw NoteError.invalidCategory }
        guard let book else { throw NoteError.invalidBook }
        
        var photosDataArray: [Data] = []
        for photo in notePhotos {
            if let data = photo.jpegData(compressionQuality: 0.8) {
                photosDataArray.append(data)
            }
        }
        
        let newNote = Notes(
            noteCategory: noteCategory,
            noteDescription: cleanDescription,
            noteTitle: cleanTitle,
            notePhoto: photosDataArray
        )
        newNote.noteTitle = cleanTitle
        newNote.noteDescription = cleanDescription
        newNote.noteCategory = noteCategory
        newNote.book = book
        
//        var photosDataArray: [Data] = []
//        for photo in notePhotos {
//            if let data = photo.jpegData(compressionQuality: 0.8) {
//                photosDataArray.append(data)
//            }
//        }
        //--------------------------depois resolver notephoto--------------------------
        //newNote.notePhoto = photosDataArray
        
        //try self.saveNote(context: context)
        self.fetchNotes(context: context)
    }
    
    func updateNote(note: Notes, noteTitle: String, noteDescription: String, notePhotos: [UIImage], context: ModelContext) throws {

        
//        let totalPagesInt = Int16(bookTotalPages) ?? 0
        
        
        
//        let defaultImageData = UIImage(named: "defaultBook")?.jpegData(compressionQuality: 1) ?? Data()
//        
//        let coverData = bookCover?.jpegData(compressionQuality: 1) ?? defaultImageData

        let finalTitle = (noteTitle.trimmingCharacters(in: .whitespacesAndNewlines))
        let finalDescription = (noteDescription.trimmingCharacters(in: .whitespacesAndNewlines))
        
        if finalTitle.isEmpty {
            throw NoteError.invalidTitle
        }
        
        if finalDescription.isEmpty {
            throw NoteError.invalidDescription
        }
        
        if(note.noteTitle != finalTitle){
            note.noteTitle = finalTitle
        }
        
        if(note.noteDescription != noteDescription){
            note.noteDescription = noteDescription
        }
        
        var photosDataArray: [Data] = []
        for photo in notePhotos {
            if let data = photo.jpegData(compressionQuality: 0.8) {
                photosDataArray.append(data)
            }
        }
        
//        if(note.notePhoto != photosDataArray as NSObject){
//            note.notePhoto = photosDataArray as NSObject
//        }
        //--------------------------resolver comparacao depois--------------------------
//        if(note.notePhoto != photosDataArray){
//                    note.notePhoto = photosDataArray
//                }
        
        
//        if(book.bookCover != coverData){
//            book.bookCover = coverData
//        }
        
        //try self.saveNote(context: context)
        note.notePhoto = photosDataArray
        try? context.save()
        self.fetchNotes(context: context)
    }
    
    // funcao para deletar notas
    func deleteNote(note: Notes, context: ModelContext) throws{
//        CoreDataManager.shared.viewContext.delete(note)
//        self.savedNotes.removeAll(where: { $0.objectID == note.objectID })
        
        
        context.delete(note)
        //objectID vira persistentModelID no SwiftData
        self.savedNotes.removeAll(where: { $0.persistentModelID == note.persistentModelID })
        //try self.saveNote(context: context)
        self.fetchNotes(context: context)
    
    }
}

//    private func savePhotoToDisk(_ image: UIImage?) -> String? {
//        guard let image, let data = image.jpegData(compressionQuality: 0.8) else { return nil }
//        
//        let fileName = "\(UUID().uuidString).jpg"
//        let url = FileManager.default
//            .urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent(fileName)
//        
//        do {
//            try data.write(to: url)
//            return fileName
//        } catch {
//            print("Erro ao salvar imagem no disco: \(error)")
//            return nil
//        }
//    }
    
