### Arquivo: \⁠ ./ViewModel/StopwatchViewModel.swift\ ⁠
⁠ swift
//
//  stopwatchViewModel.swift
//  CH4-Books
//
//  Created by Lucas on 15/08/26.
//
import Combine
import Foundation

enum TimerState {
    case stopped
    case running
    case paused
}

class StopwatchViewModel: ObservableObject {
    @Published var timerState: TimerState = .stopped
    @Published var elapsedTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var timer: Timer? = nil
    
    // controle de Páginas do Livro
    @Published var currentPage: Int = 45
    @Published var totalPages: Int = 300
    
    // progresso do Cronômetro (0.0 a 1.0) para os Anéis
    var timeProgress: Double {
        guard totalTime > 0 else { return 0 }
        return (totalTime - elapsedTime) / totalTime
    }
    
    // progresso do Livro (0.0 a 1.0) independente do timer
    var bookProgress: Double {
        guard totalPages > 0 else { return 0 }
        return min(max(Double(currentPage) / Double(totalPages), 0.0), 1.0)
    }
    
    // configura a duração inicial (chamado ao rolar o Picker)
    func setDuration(_ duration: TimeInterval) {
        self.totalTime = duration
        self.elapsedTime = duration
    }
        
    func startTimer() {
        timerState = .running
        isRunning = true
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.elapsedTime > 0 {
                self.elapsedTime -= 0.1
            } else {
                self.stop()
            }
        }
    }
    
    func pauseTimer() {
        timerState = .paused
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    // para a contagem ao finalizar o tempo
    func stop() {
        timerState = .stopped
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    // Abandona a leitura e reseta o cronômetro para o valor original
    func abandonTimer() {
        stop()
        elapsedTime = totalTime
    }
    
    func updatePage(to newPage: Int) {
        self.currentPage = newPage
    }
    
    /*
    func timerFormater() -> String{
        let current = max(0, Int(elapsedTime))
        return String(format: "%02d:%02d", current / 60, current % 60)
    }
    */
    func timerFormater() -> String {
        let current = max(0, Int(elapsedTime))
        let hours = current / 3600
        let minutes = (current % 3600) / 60
        let seconds = current % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/Managers/CoreDataManager.swift\ ⁠
⁠ swift
//
//  CoreDataManager.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

//import Foundation
//import CoreData
//
//class CoreDataManager{
//    let persistentContainer: NSPersistentContainer
//    static let shared = CoreDataManager()
//    
//    var viewContext: NSManagedObjectContext{
//        return self.persistentContainer.viewContext
//    }
//    
//    init(){
//        self.persistentContainer = NSPersistentContainer(name: "Database")
//        self.persistentContainer.loadPersistentStores { (description, error) in
//            if let error = error{
//                print("Error loading persistent stores: \(error)")
//            }
//        }
//        
//        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
//    }
//}

//
//  CoreDataManager.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import Foundation
import CoreData

class CoreDataManager {
    let persistentContainer: NSPersistentContainer
    static let shared = CoreDataManager()
    
    var viewContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    init() {
        self.persistentContainer = NSPersistentContainer(name: "Database")
        
        // Configurar para usar memória RAM
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType  // ← Aqui é a mágica
        self.persistentContainer.persistentStoreDescriptions = [description]
        
        self.persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading persistent stores: \(error)")
            } else {
                print("Core Data loaded in memory ✅")
            }
        }
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
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
    
    //depois avaliar se realemtne e necessaria
    func fetchNotes(for book: Books?) {
        guard let book = book else {
            self.savedNotes = []
            return
        }
        
        let request = NSFetchRequest<Notes>(entityName: "Notes")
        // Filtra para pegar apenas anotações onde o relacionamento 'book' é o livro atual
        request.predicate = NSPredicate(format: "book == %@", book)
        
        do {
            self.savedNotes = try CoreDataManager.shared.viewContext.fetch(request)
        } catch let error {
            print("Erro ao buscar anotações do livro: \(error)")
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
        //if noteCategory.isEmpty { throw NoteError.invalidCategory }
        guard let book else { throw NoteError.invalidBook }
        
        let newNote = Notes(context: CoreDataManager.shared.viewContext)
        newNote.noteTitle = cleanTitle
        newNote.noteDescription = cleanDescription
        newNote.noteCategory = noteCategory
        newNote.book = book
        
        var photosDataArray: [Data] = []
        for photo in notePhotos {
            if let data = photo.jpegData(compressionQuality: 0.8) {
                photosDataArray.append(data)
            }
        }
        
        newNote.notePhoto = photosDataArray as NSObject
        
        try self.saveNote()
        
        self.fetchNotes()
    }
    
    func updateNote(note: Notes, noteTitle: String, noteDescription: String, notePhotos: [UIImage]) throws {

        
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
        
        if(note.notePhoto != photosDataArray as NSObject){
            note.notePhoto = photosDataArray as NSObject
        }
        
        
//        if(book.bookCover != coverData){
//            book.bookCover = coverData
//        }
        
        try self.saveNote()
        self.fetchNotes()
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
    
 ⁠

---

### Arquivo: \⁠ ./ViewModel/CameraPicker.swift\ ⁠
⁠ swift
//
//  CameraPicker.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 17/08/26.
//

import Foundation
import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/PhotoLibraryViewModel.swift\ ⁠
⁠ swift
//
//  PhotoLibraryViewModel.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 14/08/26.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI
import UIKit
import CoreData

struct SelectableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

class PhotoLibraryViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            Task {
                await loadImage()
            }
        }
    }
    
    //@Published var selectedImage: UIImage? = UIImage(named: "defaultBook")
    
    @Published var selectedCoverImage: UIImage? = UIImage(named: "defaultBook") ?? UIImage()
    
    @Published var selectedImage: UIImage? = nil
    
    @Published var noteImages: [SelectableImage] = []
    
    private let maxNoteImages = 3
    
    func loadImage() async {
        guard let item = selectedItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.selectedCoverImage = image
            }
        }
    }
    
    func loadExistingImages(_ images: [UIImage]) {
        for image in images.prefix(maxNoteImages) {
            noteImages.append(SelectableImage(image: image))
        }
    }
    
    func saveImageToCoreData(image: UIImage){
        let newPhoto = Books(context: CoreDataManager.shared.viewContext)
        
        let defaultImageData = UIImage(named: "defaultBook")?.jpegData(compressionQuality: 1) ?? Data()
        let imageData = image.jpegData(compressionQuality: 1) ?? defaultImageData
        
        newPhoto.bookCover = imageData
        
        do {
            try CoreDataManager.shared.viewContext.save()
            print("Sucesso ao salvar a capa do livro.")
        } catch let error {
            print("Erro ao tentar salvar a capa do livro: \(error)")
        }
    }
    
    func convertImageToData(image: UIImage) -> Data?{

        let defaultImageData = UIImage(named: "defaultBook")?.jpegData(compressionQuality: 1) ?? Data()
        let imageData = image.jpegData(compressionQuality: 1) ?? defaultImageData
        
        return imageData
    }
    
    func getCoverImage(for book: Books) -> UIImage? {
        if book.entity.attributesByName.keys.contains("bookCover") {
            
            if let imageData = book.value(forKey: "bookCover") as? Data, let uiImage = UIImage(data: imageData) {
                return uiImage
            }
            
            if let imageName = book.value(forKey: "bookCover") as? String, !imageName.isEmpty, let uiImage = UIImage(named: imageName) {
                return uiImage
            }
        }
        
        if book.entity.attributesByName.keys.contains("bookImage") {
            if let imageData = book.value(forKey: "bookImage") as? Data, let uiImage = UIImage(data: imageData) {
                return uiImage
            }
        }
        return nil
    }
    
    func loadPickedItems(_ items: [PhotosPickerItem]) {
        Task {
            for item in items {
                guard noteImages.count < maxNoteImages else { break }
                
                guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
                guard let uiImage = UIImage(data: data) else { continue }
                
                await MainActor.run {
                    noteImages.append(SelectableImage(image: uiImage))
                }
            }
        }
    }
    
    func appendCapturedImage(_ image: UIImage?) {
        guard let image, noteImages.count < maxNoteImages else { return }
        noteImages.append(SelectableImage(image: image))
    }
    
    func removeNoteImage(id: UUID) {
        noteImages.removeAll { $0.id == id }
    }
    
    func resetNoteImages() {
        noteImages.removeAll()
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
    @StateObject var photoViewModel = PhotoLibraryViewModel()
    @StateObject private var booksViewModel = BooksViewModel()
    @StateObject private var notesViewModel = NotesViewModel()
    @StateObject private var stopWatchViewModel = StopwatchViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(photoViewModel)
                .environmentObject(booksViewModel)
                .environmentObject(notesViewModel)
                .environmentObject(stopWatchViewModel)
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./Extensions/FontTypography.swift\ ⁠
⁠ swift
//
//  FontTypography.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 15/08/26.
//

import SwiftUI

extension Font {
    enum BitterWeight: String {
        case regular = "Bitter-Regular"
        case medium = "Bitter-Medium"
        case bold = "Bitter-Bold"
        case semibold = "Bitter-SemiBold"
    }
    
    // aplica a fonte Bitter com peso específico ajustada ao Dynamic Type
    static func bitter(_ weight: BitterWeight = .medium, style: TextStyle) -> Font {
        let uiStyle: UIFont.TextStyle = switch style {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        @unknown default: .body
        }
        
        let pointSize = UIFont.preferredFont(forTextStyle: uiStyle).pointSize
        return Font.custom(weight.rawValue, size: pointSize, relativeTo: style)
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/PreviewHelper/PreviewProviderHelper.swift\ ⁠
⁠ swift
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
 ⁠

---

### Arquivo: \⁠ ./View/BookSearchView.swift\ ⁠
⁠ swift
//
//  BookSearchView.swift
//  CH4-Books
//
//  Created by Lucas on 16/08/26.
//

import SwiftUI

struct BookSearchView: View {
    @EnvironmentObject var booksViewModel: BooksViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @State private var searchText = ""
    @State private var isSearchPresented = false
    @State private var selectedBook: Books?
    @State private var selectedNote: Notes?

    var filteredBooks: [Books] {
        if searchText.isEmpty {
            return booksViewModel.savedBooks
        } else {
            return booksViewModel.savedBooks.filter { book in
                book.bookTitle?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var filteredNotes: [Notes] {
        if searchText.isEmpty {
            return notesViewModel.savedNotes
        } else {
            return notesViewModel.savedNotes.filter { note in
                note.noteTitle?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !filteredBooks.isEmpty {
                    Section("Livros") {
                        ForEach(filteredBooks, id: \.self) { book in
                            Button {
                                selectedBook = book
                            } label: {
                                BookCellView(book: book)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                if !filteredNotes.isEmpty {
                    Section("Notas") {
                        ForEach(filteredNotes, id: \.self) { note in
                            Button {
                                selectedNote = note
                            } label: {
                                NoteCellView(note: note)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .overlay {
                if filteredBooks.isEmpty && filteredNotes.isEmpty {
                    ContentUnavailableView(
                        "Nenhum resultado encontrado",
                        systemImage: "magnifyingglass",
                        description: Text("Tente buscar por outro título de livro ou nota.")
                            .font(.custom("Bitter-Regular", size: 15))
                    )
                }
            }
            .navigationTitle("Buscar")
            .searchable(
                text: $searchText,
                isPresented: $isSearchPresented,
                prompt: "Buscar livros ou notas"
            )
            .onAppear {
                isSearchPresented = true
                booksViewModel.fetchBooks()
                notesViewModel.fetchNotes()
            }
            .sheet(item: $selectedBook, onDismiss: {
                booksViewModel.fetchBooks()
                notesViewModel.fetchNotes()
            }) { book in
                BookDetailView(bookViewModel: booksViewModel, book: book)
            }
            .sheet(item: $selectedNote, onDismiss: {
                booksViewModel.fetchBooks()
                notesViewModel.fetchNotes()
            }) { note in
                NoteDetailSheetView(note: note)
            }
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Sheets/SelectBookSheetView.swift\ ⁠
⁠ swift
//
//  SelectBookSheetView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI
import CoreData

struct SelectBookSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var booksViewModel: BooksViewModel
    
    // Binding do livro selecionado enviado de volta para a view chamadora
    @Binding var selectedBook: Books?
    
    @State private var showingDiscardAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(booksViewModel.savedBooks, id: \.objectID) { book in
                            let isSelected = selectedBook == book
                            
                            Button(action: {
                                selectedBook = book
                                dismiss()
                            }) {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text(book.bookTitle ?? "Sem título")
                                            .font(.body)
                                            .fontWeight(isSelected ? .semibold : .regular)
                                            .foregroundColor(isSelected ? Color("ActionColor") : Color("Texts"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                                    }

                                    Rectangle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 1)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 14)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                SheetHeaderView(
                    title: "Livros salvos",
                    actionIcon: "checkmark",
                    showingDiscardAlert: $showingDiscardAlert,
                    onCancel: { dismiss() },
                    onConfirm: { dismiss() },
                    onDiscard: { dismiss() }
                )
            }
            .onAppear {
                booksViewModel.fetchBooks()
            }
        }
    }
}

// Extension para dados fictícios no Preview
extension BooksViewModel {
    static var preview: BooksViewModel {
        let viewModel = BooksViewModel()
        let context = CoreDataManager.shared.viewContext
        
        // Cria instâncias temporárias para exibir no Canvas
        let book1 = Books(context: context)
        book1.bookTitle = "Hush, Hush"
        book1.bookAuthor = "Becca Fitzpatrick"
        
        let book2 = Books(context: context)
        book2.bookTitle = "É Assim que Acaba"
        book2.bookAuthor = "Colleen Hoover"
        
        let book3 = Books(context: context)
        book3.bookTitle = "O Hobbit"
        book3.bookAuthor = "J.R.R. Tolkien"
        
        viewModel.savedBooks = [book1, book2, book3]
        return viewModel
    }
}

#Preview {
    let previewVM = BooksViewModel.preview
    
    // Passa o primeiro livro do mock como selecionado para testar o indicador visual
    SelectBookSheetView(selectedBook: .constant(previewVM.savedBooks.first))
        .environmentObject(previewVM)
}
 ⁠

---

### Arquivo: \⁠ ./View/Sheets/NoteSheetView.swift\ ⁠
⁠ swift
//
//  SheetNotes.swift
//  CH4-Books
//
//  Created by Lucas on 14/08/26.
//

import SwiftUI
import PhotosUI
import CoreData

struct NoteSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    
    @State private var hasLoaded = false
    
    @State var showingDiscardAlert: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var noteTitle: String = ""
    @State private var noteDescription: String = ""
    @State var image: UIImage? = nil
    @State var selectedCategory: String = ""
    
    @State private var selectedBook: Books? = nil
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCameraPicker = false
    @State private var capturedImage: UIImage? = nil
    @State private var showMediaSourceMenu = false
    @State private var showPhotoPicker = false
    
    var book: Books
    var noteToEdit: Notes?
    
    private var toolbarTitle: String {
        if noteToEdit != nil {
            return "Editar nota"
        } else {
            return "Adicionar nota"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 17) {
                            noteContentHeader
                            titleField
                            noteTextEditor
                            selectedImagePreview
                            mediaSection
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    SheetHeaderView(
                        title: toolbarTitle,
                        actionIcon: "checkmark",
                        showingDiscardAlert: $showingDiscardAlert,
                        onCancel: {
                            // Força a remoção do foco do teclado antes de fechar a sheet
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            dismiss()
                        },
                        onConfirm: handleConfirm,
                        onDiscard: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            dismiss()
                        }
                    )
                }
            }
            .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
                Button("Tentar novamente", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: selectedItems) { newItems in
                photoLibraryViewModel.loadPickedItems(newItems)
                selectedItems.removeAll()
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $capturedImage)
                    .ignoresSafeArea()
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedItems,
                maxSelectionCount: 3 - photoLibraryViewModel.noteImages.count,
                matching: .images
            )
            .onChange(of: capturedImage) { newImage in
                photoLibraryViewModel.appendCapturedImage(newImage)
                capturedImage = nil
            }
            
            .confirmationDialog("Selecione a origem da imagem", isPresented: $showMediaSourceMenu, titleVisibility: .hidden) {
                Button("Tirar foto com a Câmera") {
                    showCameraPicker = true
                }
                Button("Escolher da Galeria") {
                    showPhotoPicker = true
                }
                Button("Cancelar", role: .cancel) { }
            }
            
            .onAppear {
                guard !hasLoaded else { return }
                hasLoaded = true
                
                photoLibraryViewModel.resetNoteImages()
                
                if let note = noteToEdit {
                    noteTitle = note.noteTitle ?? ""
                    noteDescription = note.noteDescription ?? ""
                    
                    if let photosData = note.notePhoto as? [Data] {
                        let existingImages = photosData.compactMap { UIImage(data: $0) }
                        photoLibraryViewModel.loadExistingImages(existingImages)
                    }
                }
            }
        }
    }
    
    private func handleConfirm() {
        do {
            if let note = noteToEdit {
                try notesViewModel.updateNote(
                    note: note,
                    noteTitle: noteTitle,
                    noteDescription: noteDescription,
                    notePhotos: photoLibraryViewModel.noteImages.map(\.image)
                )
            } else {
                try notesViewModel.addNote(
                    noteTitle: noteTitle,
                    noteDescription: noteDescription,
                    noteCategory: selectedCategory,
                    notePhotos: photoLibraryViewModel.noteImages.map(\.image),
                    to: book
                )
            }
            
            notesViewModel.fetchNotes(for: book)
            photoLibraryViewModel.resetNoteImages()
            
            dismiss()
            
        } catch let error as LocalizedError {
            errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
            showErrorAlert = true
        } catch {
            errorMessage = "Erro inesperado."
            showErrorAlert = true
        }
    }
    
    private var noteContentHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Livro: \(book.bookTitle ?? "Sem título")")
                .font(.system(.title3))
                .foregroundColor(Color("TextFieldPlaceholderColor"))
                .padding(.bottom, 6)
                .padding(.leading, 4)
            
            Text("Conteúdo da nota")
                .font(.system(.title, weight: .medium))
                .foregroundColor(Color("Texts"))
                .padding(.bottom, 6)
                .padding(.leading, 4)
            
            TipsComponent(
                content: "Adicione um título e um conteúdo para a sua nota."
            )
        }
    }
    
    private var titleField: some View {
        
        //        var let titleText = noteToEdit != nil ?? noteToEdit?.noteTitle : "Adicione o título"
        TextFieldSheets(
            text: $noteTitle,
            placeholder: "Adicione o título",
            label: nil
        )
    }
    
    private var noteTextEditor: some View {
        ZStack(alignment: .topLeading) {
            if noteDescription.isEmpty {
                Text("Escreva sua nota...")
                    .foregroundColor(Color("TextFieldPlaceholderColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .zIndex(1)
                    .allowsHitTesting(false)
                    .font(.system(.body, weight: .regular))
            }
            
            TextEditor(text: $noteDescription)
                .padding(8)
                .scrollContentBackground(.hidden)
                .cornerRadius(10)
                .frame(height: 250)
                .foregroundStyle(.white)
                .font(.system(.body, weight: .regular))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("LinesColor"), lineWidth: 0.5)
                )
        }
    }
    
    @ViewBuilder
    private var selectedImagePreview: some View {
        if let selectedImage = photoLibraryViewModel.selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(10)
        }
    }
    
    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            if !photoLibraryViewModel.noteImages.isEmpty {
                mediaThumbnailsRow
            }
            
            mediaPickerMenu
            
            TipsComponent(
                content: "Você pode adicionar até 3 fotos em uma mesma nota."
            )
        }
    }
    
    private var mediaThumbnailsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(photoLibraryViewModel.noteImages) { item in
                    MediaThumbnailView(image: item.image) {
                        photoLibraryViewModel.removeNoteImage(id: item.id)
                    }
                }
            }
        }
    }
    
    private var mediaPickerMenu: some View {
        let imagesCount = photoLibraryViewModel.noteImages.count
        let isLimitReached = imagesCount >= 3
        let mediaButtonText: String = imagesCount == 0
        ? "Adicionar fotos"
        : "Adicionar mais fotos (\(imagesCount)/3)"
        
        return Button {
            showMediaSourceMenu = true
        } label: {
            HStack {
                Image(systemName: "camera.viewfinder")
                    .foregroundColor(Color("AddNoteImage"))
                
                Text(mediaButtonText)
                    .foregroundColor(Color("AddNoteImage"))
                    .font(.system(.body, weight: .regular))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("AddNoteImage"))
            }
            .padding()
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color("LinesColor"), lineWidth: 0.5)
            )
        }
        .disabled(isLimitReached)
        .opacity(isLimitReached ? 0.5 : 1.0)
    }
}
#Preview {
    NoteSheetView(book: PreviewProviderHelper.sampleBook)
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(NotesViewModel())
}
 ⁠

---

### Arquivo: \⁠ ./View/Sheets/NoteDetailSheetView.swift\ ⁠
⁠ swift
//
//  NoteDetailSheetView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct NoteDetailSheetView: View {
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    
    var note: Notes
    
    @Environment(\.dismiss) var dismiss
    
    @State var isShowingEditSheet: Bool = false
    
    private var noteImages: [UIImage] {
        if let photosData = note.notePhoto as? [Data] {
            return photosData.compactMap { UIImage(data: $0) }
        }
        return []
    }
    
    var body: some View {
        
        NavigationStack{
            ZStack(alignment: .top) {
                Color(.backgroundColorViews)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            if !noteImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(0..<noteImages.count, id: \.self) { index in
                                            Image(uiImage: noteImages[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 240, height: 300)
                                                .cornerRadius(16)
                                                .clipped()
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text(note.noteTitle ?? "Sem título")
                                    .font(.system(.title, weight: .medium))
                                    .foregroundColor(.title)
                                    .multilineTextAlignment(.leading)
                                
                                Text(note.noteDescription ?? "Sem descrição")
                                    .font(.system(.body, weight: .light))
                                    .foregroundColor(Color(.title))
                                    .lineSpacing(5)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 24)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 40)
                    }
                }
                .toolbar{
                    NotesToolBar(
                        title: "Nota",
                        onClose: {
                            notesViewModel.fetchNotes(for: note.book)
                            dismiss()
                        },
                        onEdit: {
                            isShowingEditSheet.toggle()
                        }
                    ) 
                }
                
                .sheet(isPresented: $isShowingEditSheet, onDismiss: {
                    
                }){
                    NoteSheetView(book: note.book!, noteToEdit: note)
                }
            }
        }

    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Sheets/BookSheetView.swift\ ⁠
⁠ swift
//
//  AddBookSheetView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 15/08/26.
//

import Foundation
import SwiftUI
import PhotosUI

struct BookSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    
    @State var bookToEdit: Books? 
    
    private var toolbarTitle: String{
        if bookToEdit != nil {
            return "Editar livro"
        } else {
            return "Adicionar livro"
        }
    }
    
    @State private var showingDiscardAlert: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var bookTitle = ""
//    @State private var selectedGoal: String = ""
    @State private var selectedCategory: String = ""
    @State private var bookTotalPages: String = ""
//    @State private var bookLastPage: String = ""
    @State private var bookAuthor: String = ""
    
    @ViewBuilder
    private var SelectCategoryField: some View {
        if let currentBook = bookToEdit {
            MenuSheetPicker(
                    title: "Categoria",
                    placeholder: "Adicione a categoria",
                    selectedValue: Binding(
                        get: { bookToEdit != nil ? (bookToEdit?.bookCategory ?? "") : selectedCategory },
                        set: { newValue in
                            if bookToEdit != nil { bookToEdit?.bookCategory = newValue }
                            else { selectedCategory = newValue }
                        }
                    ),
                    options: booksViewModel.bookCategories
                )
        }
    }
    
    
    @ViewBuilder
    private var TitleField: some View {
        if let currentBook = bookToEdit {
            TextFieldSheets(
                text: Binding(
                    get: { currentBook.bookTitle ?? "" },
                    set: { bookToEdit?.bookTitle = $0 }
                ),
                placeholder: "Edite o título",
                label: "Título"
            )
        } else {
            TextFieldSheets(
                text: $bookTitle,
                placeholder: "Adicione o título",
                label: "Título"
            )
        }
    }
    
    @ViewBuilder
    private var AuthorField: some View {
        if let currentBook = bookToEdit {
            TextFieldSheets(
                text: Binding(
                    get: { currentBook.bookAuthor ?? "" },
                    set: { bookToEdit?.bookAuthor = $0 }
                ),
                placeholder: "Edite o título",
                label: "Título"
            )
        } else {
            TextFieldSheets(
                text: $bookAuthor,
                placeholder: "Adicione o título",
                label: "Título"
            )
        }
    }
    
    @ViewBuilder
    private var TotalPagesField: some View {
        if let currentBook = bookToEdit {
            TextFieldSheets(
                text: Binding(
                    get: { String(currentBook.bookTotalPages) },
                    set: { if let value = Int16($0) { bookToEdit?.bookTotalPages = value } }
                ),
                placeholder: "Edite a quantidade de páginas",
                label: "Páginas"
            )
            .keyboardType(.numberPad)
        } else {
            TextFieldSheets(
                text: $bookTotalPages,
                placeholder: "Adicione a quantidade de páginas",
                label: "Páginas"
            )
            .keyboardType(.numberPad)
        }
    }

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ScrollView(showsIndicators: false){
                        VStack(spacing: 17) {
                            
                            //capa do livro
                            VStack {
                                PhotosPicker(selection: $photoLibraryViewModel.selectedItem, matching: .images) {
                                    ZStack(alignment: .bottomTrailing) {
                                        Group {
                                            if let selectedImage = photoLibraryViewModel.selectedCoverImage {
                                                Image(uiImage: selectedImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 150, height: 210)
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                            } else {
                                                Image("defaultBook")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 172, height: 243)
                                                    .background(Color(uiColor: .systemGray4))
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                            }
                                        }
                                        
                                        
                                        Image(systemName: "plus")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.title)
                                            .frame(width: 44, height: 44)
                                            .background(.ultraThinMaterial, in: Circle())
                                            .clipShape(Circle())
                                            .overlay(
                                                    Circle()
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1) 
                                            )
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 6)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.bottom, 12)
                                .padding(.trailing, 12)
                            }
                            
                            if photoLibraryViewModel.selectedCoverImage != nil {
                                Button(action: {
                                    withAnimation {
                                        photoLibraryViewModel.selectedCoverImage = nil
                                        photoLibraryViewModel.selectedItem = nil
                                    }
                                }) {
                                    Text("Remover capa")
                                        .font(.body)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            //detalhes do livro

                            TextFieldSheets(text: $bookTitle, placeholder: "Adicione o título", label: "Título")
                            TextFieldSheets(text: $bookAuthor, placeholder: "Adicione o autor(a)", label: "Autor(a)")

                            MenuSheetPicker(
                                title: "Categoria",
                                placeholder: "Adicione a categoria",
                                selectedValue: $selectedCategory,
                                options: booksViewModel.bookCategories
                            )

                            TextFieldSheets(text: $bookTotalPages, placeholder: "Adicione a quantidade de páginas", label: "Páginas")
                                .keyboardType(.numberPad)
                            
//                            TextFieldSheets(text: $bookLastPage, placeholder: "Exemplo: 125", label: "Última página lida")
//                                .keyboardType(.numberPad)
                            
//                            MenuSheetPicker(
//                                title: "Objetivo diário",
//                                placeholder: "Objetivo diário (minutos)",
//                                selectedValue: $selectedGoal,
//                                options: booksViewModel.goalOptions,
//                                formatOption: { "\($0) minutos" }
//                            )
                            
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        SheetHeaderView(
                            title: toolbarTitle,
                            actionIcon: "checkmark",
                            showingDiscardAlert: $showingDiscardAlert,
                            onCancel: {},
                            onConfirm: {
                                
                                if let book = bookToEdit {
                                    do{
                                        try booksViewModel.updateBook(
                                            book: book,
                                            bookTitle: bookTitle,
                                            bookAuthor: bookAuthor,
                                            bookCover: photoLibraryViewModel.selectedCoverImage,
                                            bookCategory: selectedCategory,
                                            bookTotalPages: bookTotalPages
                                        )
                                        
                                        booksViewModel.fetchBooks()
                                        dismiss()
                                        
                                    } catch let error as LocalizedError{
                                        errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                                        showErrorAlert = true
                                    } catch {
                                        errorMessage = "Erro inesperado."
                                        showErrorAlert = true
                                    }
                                } else{
                                    do{
                                        try booksViewModel.addBook(
                                            bookTitle: bookTitle,
                                            bookAuthor: bookAuthor,
                                            bookCover: photoLibraryViewModel.selectedCoverImage,
                                            bookCategory: selectedCategory,
                                            bookTotalPages: bookTotalPages
                                        )
                                        
                                        booksViewModel.fetchBooks()
                                        dismiss()
                                        
                                    } catch let error as LocalizedError{
                                        errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                                        showErrorAlert = true
                                    } catch {
                                        errorMessage = "Erro inesperado."
                                        showErrorAlert = true
                                    }
                                }

                            },
                            onDiscard: { dismiss() }
                        )
                    }
                    
                    .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
                        Button("Tentar novamente", role: .cancel) { }
                    } message: {
                        Text(errorMessage)
                    }
                    .onAppear {
                        if let book = bookToEdit {
                            bookTitle = book.bookTitle ?? ""
                            bookAuthor = book.bookAuthor ?? ""
                            selectedCategory = book.bookCategory ?? ""
                            bookTotalPages = book.bookTotalPages > 0 ? String(book.bookTotalPages) : ""
                            
                            if let imageData = book.bookCover, let image = UIImage(data: imageData) {
                                photoLibraryViewModel.selectedCoverImage = image
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    BookSheetView(bookToEdit: nil)
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
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
    @State private var searchText = ""
    
    var body: some View {
        TabView {
            Tab("Estante", systemImage: "book"){
                BookCaseView(bookViewModel: BooksViewModel())
                    .environmentObject(PhotoLibraryViewModel())
            }
            Tab("Cronômetro", systemImage: "timer"){
               // StopwatchInicialView()
            }
            Tab(role: .search){
                BookSearchView()
            }
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BooksViewModel())
        .environmentObject(StopwatchViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(NotesViewModel())
}
 ⁠

---

### Arquivo: \⁠ ./View/BookDetailsView.swift\ ⁠
⁠ swift
//
//  BookDetailView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI
import CoreData

struct BookDetailView: View {
    @ObservedObject var bookViewModel: BooksViewModel
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var isPresentedAddNote: Bool = false
    @State private var isPresentedEditBook: Bool = false
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    
    var book: Books? = nil
    //apagar assim que possivel
    private var currentBook: Books? {
        book ?? bookViewModel.savedBooks.first
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color(.orange)
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                if let currentBook = currentBook {
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            BookInstanceDetailView(book: currentBook)
                                .environmentObject(PhotoLibraryViewModel())
                                .id(currentBook.bookCover ?? Data())
                            
                            CardTotalPages(totalPages: 100)
                                .padding(.horizontal)

                            VStack(spacing: 16) {
                                NotesHeaderview(isPresentedAddNote: $isPresentedAddNote)
                                
                                NotesSectionView(notes: Array(notesViewModel.savedNotes.prefix(3)))
                                
                                NavigationLink(destination: MyNotesListView(book: currentBook)) {
                                    
                                    Text(notesViewModel.savedNotes.isEmpty ? "Ver anotações" : "Ver todas as anotações")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(.action))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal)
                            VStack(spacing: 16) {
                                Button(action: {
                                }) {
                                    Text("Adicionar leitura")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
    //                                    .background(
    //                                        RoundedRectangle(cornerRadius: 24)
    //                                    )
    //                                    .overlay(
    //                                        RoundedRectangle(cornerRadius: 24)
    //                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
    //                                    )
                                }
                                .buttonStyle(.glass)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                                
                                Button(action: {
                                }) {
                                    Text("Iniciar leitura")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                       
    //
                                        .cornerRadius(24)
                                }
                                //.background(Color(.action))
                                .buttonStyle(.glass)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                                
                            }
           
                            
                        }
                        .padding(.bottom, 40)
                    }
                } else {
                    Text("Nenhum livro encontrado.")
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                notesViewModel.fetchNotes(for: currentBook)
            }
            .onDisappear {
                bookViewModel.fetchBooks()
            }
            .sheet(isPresented: $isPresentedAddNote, onDismiss: {
                notesViewModel.fetchNotes(for: currentBook)
            }) {
                if let currentBook {
                    NoteSheetView(book: currentBook)
                        .environmentObject(notesViewModel)
                }
            }
            .sheet(isPresented: $isPresentedEditBook, onDismiss: {
                bookViewModel.fetchBooks()
            }){
                BookSheetView(bookToEdit: book)
                    .environmentObject(photoLibraryViewModel)
                    .environmentObject(bookViewModel)
            }
            .toolbar{
                BooksDetailsToolbar(onEdit: {
                    isPresentedEditBook.toggle()
                    
                })
            }
        }

    }
}
#Preview {
    BookDetailView(bookViewModel: BooksViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(NotesViewModel())
}
 ⁠

---

### Arquivo: \⁠ ./View/SimulatedSheet.swift\ ⁠
⁠ swift
//
//  SimulatedSheet.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 18/08/26.
//

import SwiftUI

struct SimulatedSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder var sheetContent: () -> SheetContent
    
    @State private var dragOffset: CGFloat = 0
    
    private let dismissThreshold: CGFloat = 500
    private let sheetHeightRatio: CGFloat = 0.92
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        Color.black
                            .opacity(backgroundOpacity(in: geo))
                            .ignoresSafeArea()
                            .onTapGesture { close() }
                        
                        VStack(spacing: 0) {
                            sheetContent()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: geo.size.height * sheetHeightRatio)
                        .background(Color("BackgroundColorViews"))
                        .offset(y: max(dragOffset * 0.3, 0))
                        .simultaneousGesture(dragGesture)
                        .transition(.move(edge: .bottom))
                    }
                }
                .ignoresSafeArea()
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPresented)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > dismissThreshold {
                    close()
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    private func backgroundOpacity(in geo: GeometryProxy) -> Double {
        let maxDrag = geo.size.height * sheetHeightRatio
        let progress = min(max((dragOffset * 0.3) / maxDrag, 0), 1)
        return 0.4 * (1 - progress)
    }
    
    private func close() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            dragOffset = 0
            isPresented = false
        }
    }
}

extension View {
    /// Aplica uma "sheet falsa": sobe por cima da view atual e pode ser
    /// fechada arrastando pra baixo. Ao contrário de .sheet(), o conteúdo
    /// fica na mesma hierarquia de view, então @EnvironmentObject já
    /// configurados continuam disponíveis automaticamente dentro dela.
    func fakeSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(SimulatedSheet(isPresented: isPresented, sheetContent: content))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = 24
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/PageProgressSheet.swift\ ⁠
⁠ swift
//
//  PageProgressSheet.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//

import SwiftUI

struct PageProgressSheetView: View {
    let bookTitle: String
    let totalPages: Int
    
    @Binding var currentPage: Int
    @State private var tempPage: Int
    @State private var showAlert = false
    
    var onDismiss: () -> Void = {}
    var onSave: (Int) -> Void = { _ in }
    
    init(bookTitle: String, totalPages: Int, currentPage: Binding<Int>, onDismiss: @escaping () -> Void = {}, onSave: @escaping (Int) -> Void = { _ in }) {
        self.bookTitle = bookTitle
        self.totalPages = max(totalPages, 1)
        self._currentPage = currentPage
        self._tempPage = State(initialValue: currentPage.wrappedValue)
        self.onDismiss = onDismiss
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text("Em qual página você parou no livro")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("“\(bookTitle)”?")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                TextFieldSheets(
                    text: .constant(""),
                    placeholder: "Digite o número da página...",
                )
                .padding(.horizontal)

            }
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal, 20)
            .toolbar {
                SheetHeaderView(
                    title: "",
                    actionIcon: "checkmark",
                    showingDiscardAlert: $showAlert,
                    onCancel: { onDismiss() },
                    onConfirm: {
                        currentPage = tempPage
                        onSave(tempPage)
                        onDismiss()
                    },
                    onDiscard: { onDismiss() }
                )
            }
        }
    }
}

#Preview("Page Progress Sheet") {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        @State private var page = 42

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                Button("Abrir Mini Sheet") {
                    isPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $isPresented) {
                PageProgressSheetView(
                    bookTitle: "Hush, Hush",
                    totalPages: 384,
                    currentPage: $page,
                    onDismiss: { isPresented = false },
                    onSave: { newPage in
                        print("Nova página salva: \(newPage)")
                    }
                )
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color("BackgroundColorViews"))
            }
        }
    }

    return PreviewWrapper()
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/StopwatchComponents/ConcentricRingsView.swift\ ⁠
⁠ swift
//
//  ConcentricRingsView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 16/08/26.
//

import SwiftUI

struct ConcentricRingsView: View {
    var progress: Double
    private let totalRings = 5

    var body: some View {
        GeometryReader { geometry in
            let baseWidth = geometry.size.width * 0.60
            let baseHeight = geometry.size.height * 0.40

            ZStack {
                ForEach(0..<totalRings, id: \.self) { index in
                    //espaçamento entre cada anel
                    let step = CGFloat(index) * 38.0
                    let cornerRadius = 70.0 + CGFloat(index) * 16.0
                    let isAcendido = isRingActive(for: index)

                    //opacidade bem para não cansar a vista
                    let ringOpacity = isAcendido ? max(0.25, 0.7 - (Double(index) * 0.12)) : 0.08

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color("StopWatchColor1"),
                                    Color("StopWatchColor2")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: index == 0 ? 3.5 : 2.0 
                        )
                        .opacity(ringOpacity)
                        .frame(
                            width: baseWidth + (step * 2),
                            height: baseHeight + (step * 2)
                        )
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func isRingActive(for index: Int) -> Bool {
        if index == 0 { return true }
        let stepProgress = 1.0 / Double(totalRings - 1)
        let threshold = Double(index) * stepProgress
        return progress >= threshold
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/NotesComponents/NoteCardView.swift\ ⁠
⁠ swift
//
//  NoteCardView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 18/08/26.
//

import SwiftUI

struct NotesCardView: View {
    let imageName: String
    let tagText: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 87, height: 80)
                .cornerRadius(16)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {

                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color("Texts").opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: {
                //acao
            }) {
                Image(systemName: "chevron.forward")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .buttonBorderShape(.circle)
            .padding(.trailing, 6)
        }
        .padding(16)
        .background(Color("CardNoteColor"))
        .cornerRadius(20)
    }
}

#Preview {
    NotesCardView(
        imageName: "defaultBook",
        tagText: "Referência",
        title: "Título da nota",
        description: "Descrição inicial da primeira..."
    )
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/NotesComponents/NoteCellView.swift\ ⁠
⁠ swift
//
//  NoteCellView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct NoteCellView: View {
    let note: Notes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(note.noteCategory ?? "Geral")
                    .font(.custom("Bitter-SemiBold", size: 11))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .foregroundStyle(.blue)
                    .background(Color.blue.opacity(0.15), in: Capsule())
                
                Spacer()
            }
            
            Text(note.noteTitle ?? "Nota sem título")
                .font(.custom("Bitter-SemiBold", size: 17))
            
            if let description = note.noteDescription, !description.isEmpty {
                Text(description)
                    .font(.custom("Bitter-Regular", size: 15))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

 ⁠

---

### Arquivo: \⁠ ./View/Components/NotesComponents/MyNotesToolBar.swift\ ⁠
⁠ swift
//
//  MyNotesTollBar.swift
//  CH4-Books
//
//  Created by Lucas on 19/08/26.
//

import SwiftUI

struct MyNotesToolBar: ToolbarContent {
    var onBackClick: () -> Void
    var onAddClick: () -> Void
    
    var body: some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                onBackClick()
            }) {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .buttonBorderShape(.circle)
            .tint(Color.white.opacity(0.2))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                onAddClick()
            }) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .tint(Color("ActionColor"))
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
    }
}

 ⁠

---

### Arquivo: \⁠ ./View/Components/MenuSheetPickerOnboarding.swift\ ⁠
⁠ swift
//
//  MenuSheetPickerOnboarding.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//

import SwiftUI

struct MenuSheetPickerOnboarding: View {
    var title: String? = nil
    var placeholder: String
    @Binding var selectedValue: String
    var options: [String]
    var formatOption: (String) -> String = { $0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(Color("LinesColor"))
                    .padding(.leading, 4)
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(formatOption(option)) {
                        selectedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selectedValue.isEmpty ? placeholder : formatOption(selectedValue))
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(selectedValue.isEmpty ? Color("TextFieldPlaceholderColor") : .white)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("ActionColor"))
                }
                .padding()
                .background(
                    Capsule()
                        .fill(Color("StopwatchSelectors").opacity(0.20))
                )
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color("LinesColor"), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }
}




 ⁠

---

### Arquivo: \⁠ ./View/Components/BooksComponents/BookCellView.swift\ ⁠
⁠ swift
//
//  BookCellView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct BookCellView: View {
    let book: Books
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let coverData = book.bookCover, let uiImage = UIImage(data: coverData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("defaultBook")
                        .resizable()
                        .scaledToFill()
                        .background(Color(uiColor: .systemGray5))
                }
            }
            .frame(width: 55, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.bookTitle ?? "Sem Título")
                    .font(.custom("Bitter-SemiBold", size: 17))
                    .lineLimit(2)
                
                Text(book.bookAuthor ?? "Desconhecido")
                    .font(.custom("Bitter-Regular", size: 15))
                    .foregroundStyle(.secondary)
                
                Spacer(minLength: 0)
                
                Gauge(value: Double(book.bookCurrentPage), in: 0...Double(max(1, book.bookTotalPages))) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(book.bookCurrentPage)/\(book.bookTotalPages)")
                        // Substituindo .caption2.weight(.medium)
                        .font(.custom("Bitter-Medium", size: 12))
                        .foregroundStyle(.tertiary)
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(.blue)
            }
            .padding(.vertical, 4)
        }
    }
}

 ⁠

---

### Arquivo: \⁠ ./View/Components/BooksComponents/TitleComponent.swift\ ⁠
⁠ swift
//
//  TitleComponent.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 18/08/26.
//

import Foundation
import SwiftUI

struct TitleComponent: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.bitter(.medium, style: .largeTitle))
            .foregroundStyle(Color("TitleColor"))
    }
}


#Preview {
    TitleComponent(title: "Teste")
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/BooksComponents/BookCardView.swift\ ⁠
⁠ swift
//
//  BookCardView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 17/08/26.
//

import SwiftUI
import CoreData

struct BookCardView: View {
    @ObservedObject var book: Books
    
    @State private var isEditingSheetPresented = false
    @State private var isShowingDeleteAlert = false
    
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var bookViewModel: BooksViewModel
    
    private var percentageRead: Int {
        guard book.bookTotalPages > 0 else { return 0 }
        let percentage = (Double(book.bookCurrentPage) / Double(book.bookTotalPages)) * 100.0
        return min(max(Int(percentage), 0), 100)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            if let uiImage = photoLibraryViewModel.getCoverImage(for: book) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 240)
                    .clipped()
            } else {
                Image("defaultBook")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 240)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.bookTitle ?? "Sem título")
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(alignment: .bottom) {
                    Text("\(book.bookTotalPages) páginas")
                        .font(.system(.caption, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(percentageRead)%")
                        .font(.system(.headline, weight: .bold))
                        .foregroundColor(.addNote)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
        }
        .contextMenu {
            Button() {
                isEditingSheetPresented = true
            } label: {
                Label("Editar Livro", systemImage: "pencil")
                    .foregroundColor(.blue)
                    .font(.body)
            }
            
            Divider()
            
            Button(role: .destructive) {
                isShowingDeleteAlert = true
            } label: {
                Label("Apagar Livro", systemImage: "trash")
                    .font(.body)
            }
        }
        .frame(width: 170)
        .cornerRadius(12)
        
        .sheet(isPresented: $isEditingSheetPresented, onDismiss: {
            withAnimation{
                bookViewModel.fetchBooks()
            }
        }) {
            BookSheetView(bookToEdit: book)
        }
        
        .alert("Apagar Livro", isPresented: $isShowingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            
            Button("Apagar", role: .destructive) {
                withAnimation {
                    do {
                        try bookViewModel.deleteBook(book: book)
                    } catch {
                        print("Erro ao tentar apagar o livro: \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("Tem certeza que deseja apagar o livro '\(book.bookTitle ?? "Sem título")'? Essa ação não pode ser desfeita.")
        }
    }
}
//#Preview {
//    ZStack {
//        HStack(spacing: 16) {
//            
//            BookCardView(
//                book: PreviewProviderHelper.sampleBook
//            )
//        }
//    }
//}
//
 ⁠

---

### Arquivo: \⁠ ./View/Components/BooksComponents/CardTotalPages.swift\ ⁠
⁠ swift
//
//  CardTotalPages.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 18/08/26.
//

import Foundation
import SwiftUI

struct CardTotalPages: View {
    let totalPages: Int16
    
    var body: some View {

        HStack {
            Image("BookPagesReadCard")
                .resizable()
                .scaledToFit()
                .frame(width: 98, height: 51)
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 4){
                
                if totalPages >= 1 {
                    Text("\(totalPages) páginas lidas")
                        .font(.bitter(.bold, style: .title3))
                        .foregroundStyle(Color.black)
                    
                    Text(" continue assim!")
                        .font(.bitter(.regular, style: .footnote))
                        .foregroundStyle(Color.black)
                } else {
                    Text("Escolha um livro e comece seu novo hábito de leitura!")
                        .font(.bitter(.medium, style: .subheadline))
                        .foregroundStyle(Color.black)
                    
//                    Text("Escolha um livro abaixo e aproveite")
//                        .font(.bitter(.regular, style: .footnote))
//                        .foregroundStyle(Color.black)
                }
//                Text("\(totalPages) páginas lidas")
//                    .font(.bitter(.bold, style: .title3))
//                    .foregroundStyle(Color.black)
                

            }
            
            Spacer()
            
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color("PagesReadCard2"),
                    Color("PagesReadCard1")
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        
    }
}

#Preview {
    CardTotalPages(totalPages: 0)
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/BooksComponents/ToolBarAddButton.swift\ ⁠
⁠ swift
//
//  ToolBarAddButton.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 16/08/26.
//

import Foundation
import SwiftUI

struct BookCaseToolbar: ToolbarContent {
    var onAddClick: () -> Void
  
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                onAddClick()
            }) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color("ActionColor"))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                //onAddClick()
            }) {
                Image(systemName: "ellipsis")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .buttonBorderShape(.circle)
            //.tint(Color("ActionColor"))
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showAlert = false
        
        var body: some View {
            NavigationStack {
                Text("Conteúdo da sua Sheet aqui")
                    .toolbar {
                        BookCaseToolbar (
                            onAddClick: { print("Clicou no add") },
                        )
                    }
            }
        }
    }
    
    return PreviewWrapper()
}

 ⁠

---

### Arquivo: \⁠ ./View/Components/BooksComponents/DailyGoalCard.swift\ ⁠
⁠ swift
//
//  DailyGoalCard.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI

struct DailyGoalCardView: View {
    let pagesReadToday: Int
    let targetPages: Int
    var onEditAction: () -> Void
    
    private var progress: Double {
        guard targetPages > 0 else { return 0 }
        return min(Double(pagesReadToday) / Double(targetPages), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.system(.body, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("Meta diária de leitura")
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(.white)
                }

                Spacer()
                
                Button(action: onEditAction) {
                    Image(systemName: "pencil")
                        .font(.system(.title2))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(6)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .padding(.trailing, 0)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(targetPages)")
                    .font(.bitter(.medium, style: .largeTitle))
                    .foregroundColor(.white)
                
                Text("minutos")
                    .font(.bitter(.regular, style: .title3))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.vertical, 2)
            .padding(.bottom, 6)
            
            
            HStack {
                HStack(spacing: 4) {
                    Text("\(pagesReadToday)")
                        .font(.system(.callout))
                        .foregroundColor(.orange)
                    
                    Text("minutos de leitura hoje")
                        .font(.system(.callout))
                        .foregroundColor(Color("TextPagesColor"))
                }
                
                Spacer()
                
                Text("\(targetPages)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color("TextPagesColor"))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial) // Ou .thinMaterial / .regularMaterial
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("DailyGoalCardColor"))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
}

#Preview {
    ZStack {
        Color("BackgroundColorViews")
            .ignoresSafeArea()
        
        DailyGoalCardView(
            pagesReadToday: 12,
            targetPages: 30,
            onEditAction: {
                print("Editar meta clicado")
            }
        )
        .padding()
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/BooksDetailsComponents/BooksDetailsToolbar.swift\ ⁠
⁠ swift
//
//  BooksDetailsToolbar.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 18/08/26.
//

import Foundation

import SwiftUI

struct BooksDetailsToolbar: ToolbarContent {
    
    var onEdit: () -> Void
  
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
               onEdit()
            }) {
                Image(systemName: "pencil")
                    
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color("ActionColor"))
        }
        
    }
}
#Preview {
    struct PreviewWrapper: View {
        @State private var showAlert = false
        
        var body: some View {
            NavigationStack {
                Text("Conteúdo da sua Sheet aqui")
                    .toolbar {
                        BooksDetailsToolbar(onEdit: {})
                    }
            }
        }
    }
    
    return PreviewWrapper()
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/BooksDetailsComponents/BookInstanceDetailView.swift\ ⁠
⁠ swift
//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI

struct BookInstanceDetailView: View {
    @ObservedObject var book: Books
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    
    var readingProgress: Double {
        guard book.bookTotalPages > 0 else { return 0.0 }
            let current = Double(book.bookCurrentPage)
            let total = Double(book.bookTotalPages)
            return min(max(current / total, 0.0), 1.0)
        }
        
        var formattedReadingProgress: String {
            let percentage = readingProgress * 100
            return String(format: "%.0f%%", percentage)
        }
    
    
    var body: some View {
        VStack(spacing: 16) {
            /*
            Text(book.bookTitle ?? "Título desconhecido")
                .font(.custom("Georgia", size: 32))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
             */
            
            TitleComponent(title: book.bookTitle ?? "Título desconhecido")
            
            if let coverData = photoLibraryViewModel.getCoverImage(for: book){
                Image(uiImage: coverData)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 5)
            } else{
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray2))
                    
                    Image("defaultBook")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                .frame(width: 200, height: 300)
                .shadow(radius: 5)
            }
            
//            if let coverData = book.bookCover, let uiImage = UIImage(data: coverData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 200, height: 300)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .shadow(radius: 5)
//            } else {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color(.systemGray2))
//                    
//                    Image("defaultBook")
//                        .font(.system(size: 40))
//                        .foregroundColor(.gray)
//                }
//                .frame(width: 200, height: 300)
//                .shadow(radius: 5)
//            }
            
            Text("Autor: \(book.bookAuthor ?? "Erro")")
                .font(.body)
                .foregroundColor(.white)
            
            Text("\(book.bookCategory ?? "erro")")
                .font(.system(.footnote, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                .background(Color("TagNoteColor"))
                .opacity(0.8)
                .clipShape(Capsule())
            
            VStack(spacing: 16) {
                Divider().background(Color.white.opacity(0.3))
                
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Início da leitura")
                            .font(.footnote).foregroundColor(Color("InfosDetailsView"))
                        Text("adicionar data de leitura")
                            .font(.subheadline).bold().foregroundColor(.white)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Páginas").font(.footnote).foregroundColor(Color("InfosDetailsView"))
                        Text("\(book.bookTotalPages) páginas")
                            .font(.subheadline).bold().foregroundColor(.white)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Progresso").font(.footnote)
                            .foregroundColor(Color("InfosDetailsView"))
                        Text("\(formattedReadingProgress)")
                            .font(.subheadline).bold().foregroundColor(.white)
                    }
                    Spacer()
                }
                
                Divider()
                    .background(Color("LinesColor").opacity(0.3))
            }
            .padding(.top, 8)
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/BooksDetailsComponents/NotesHeaderview.swift\ ⁠
⁠ swift
//
//  NotesHeaderview.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI


struct NotesHeaderview: View {
    @Binding var isPresentedAddNote: Bool
    var body: some View {
        HStack {
            Text("Anotações")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                isPresentedAddNote = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
//                    .frame(width: 36, height: 36)
                    //.background(Color(.orange))
                    .clipShape(Circle())
                    
            }
            .tint(Color(.orange))
            .background(Color(.orange))
            .clipShape(Circle())
            //.padding()
            .buttonStyle(.glass)
            
        }
    }
}
#Preview {
    NotesHeaderview(isPresentedAddNote: .constant(false))
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/SheetsComponents/NoteFieldView.swift\ ⁠
⁠ swift
//
//  NoteFieldView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI
// campos para visualizar a nota
struct NoteFieldView: View {
        let note: Notes
        
        var body: some View {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(categoryColor(for: note.noteCategory))
                    .frame(width: 12, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.noteTitle ?? "Sem título")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(note.noteDescription ?? "")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        
        private func categoryColor(for category: String?) -> Color {
            switch category {
            case "Citação": return .pink
            case "Resumo": return .blue
            case "Pensamento": return .yellow
            case "Crítica": return .red
            case "Conceito": return .purple
            case "Lição": return .green
            case "Pergunta": return .orange
            case "Favorito": return .indigo
            default: return .gray
            }
        }
    }
 ⁠

---

### Arquivo: \⁠ ./View/Components/SheetsComponents/TextFieldSheets.swift\ ⁠
⁠ swift
//
//  TextFieldSheets.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 16/08/26.
//

import SwiftUI

struct TextFieldSheets: View {
    @Binding var text: String
    var placeholder: String
    var label: String? = nil
    
    var body: some View {
        VStack (alignment: .leading){
            if let label = label {
                Text(label)
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(Color("LinesColor"))
                    .padding(.bottom, 6)
                    .padding(.leading, 4)
            }
            
            TextField("", text: $text, prompt: Text(placeholder)
                .font(.system(.body, weight: .regular))
                .foregroundColor(Color("TextFieldPlaceholderColor"))
            )
            .foregroundStyle(.white)
            .padding()
            .font(.system(.body, weight: .regular))
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color("LinesColor"), lineWidth: 0.5)
            )
            
        }
        
        
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            TextFieldSheets(
                text: .constant(""),
                placeholder: "Digite aqui...",
                label: "Título do Campo"
            )
            
           
            TextFieldSheets(
                text: .constant(""),
                placeholder: "Apenas com placeholder"
            )
        }
        .padding()
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/SheetsComponents/MenuSheetPicker.swift\ ⁠
⁠ swift
//
//  MenuSheetPicker.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 16/08/26.
//

import SwiftUI

struct MenuSheetPicker: View {
    var title: String? = nil
    var placeholder: String
    @Binding var selectedValue: String
    var options: [String]
    var formatOption: (String) -> String = { $0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(Color("LinesColor"))
                    .padding(.leading, 4)
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(formatOption(option)) {
                        selectedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selectedValue.isEmpty ? placeholder : formatOption(selectedValue))
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(selectedValue.isEmpty ? Color("TextFieldPlaceholderColor") : .white)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("LinesColor"))
                }
                .padding()
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color("LinesColor"), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }
}



 ⁠

---

### Arquivo: \⁠ ./View/Components/SheetsComponents/MediaThumbView.swift\ ⁠
⁠ swift
//
//  MediaThumbView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 17/08/26.
//

import Foundation
import SwiftUI

struct MediaThumbnailView: View {
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(10)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .padding(6)
            }
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/SheetsComponents/NotesToolBar.swift\ ⁠
⁠ swift
//
//  NotesHeaderEditView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct NotesToolBar: ToolbarContent {
    var title: String
    var onClose: () -> Void
    var onEdit: () -> Void
    
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                onClose()
            }) {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .buttonBorderShape(.circle)
            .tint(Color.white.opacity(0.2))
        }
        
        ToolbarItem(placement: .principal) {
            Text(title)
                .foregroundColor(Color("LinesColor"))
                .font(.bitter(.semibold, style: .title2))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                onEdit()
            }) {
                Image(systemName: "pencil")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                   
            }
            
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color("ActionColor"))
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var showAlert = false
        
        var body: some View {
            NavigationStack {
                Text("Conteúdo da sua Sheet aqui")
                    .toolbar {
                        NotesToolBar(
                            title: "Notas", onClose: {}, onEdit: {}
                        )
                    }
            }
        }
    }
    
    return PreviewWrapper()
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/SheetsComponents/CategorySelectGroup.swift\ ⁠
⁠ swift
//
//  CategorySelectGroup.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 16/08/26.
//

import SwiftUI

struct CategoryMenuView: View {
    var title: String
    //let categories = ["Citação", "Resumo", "Pensamento", "Crítica"]
    let categories: [String]
    @Binding var selectedCategory: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.title3, weight: .medium))
                .foregroundColor(Color("LinesColor"))
                .padding(.bottom, 6)
                .padding(.leading, 4)

            Menu {
                Picker("Categoria", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            } label: {
                HStack {
                    Text(selectedCategory.isEmpty ? "Selecione uma categoria" : selectedCategory)
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(selectedCategory.isEmpty ?  Color("TextFieldPlaceholderColor2") : .white)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("TextFieldPlaceholderColor2"))
                }
                .padding()
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color("LinesColor"), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        CategoryMenuView(
            title: "Escolher categoria",
            categories: ["Citação", "Resumo", "Pensamento", "Crítica"],
            selectedCategory: .constant("Teste"),
            //selectedCategory: .constant("Citação"),
        )
        .padding()
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/SheetsComponents/NotesSectionView.swift\ ⁠
⁠ swift
//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI
import CoreData

struct NotesSectionView: View {
    var notes: [Notes]
    @State private var selectedNote: Notes?
    
    var body: some View {
        Group {
            if notes.isEmpty {
                Text("Nenhuma anotação cadastrada.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 24)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(notes, id: \.objectID) { note in
                        Button {
                            selectedNote = note
                        } label: {
                            NoteRowView(note: note)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        
                        if note.objectID != notes.last?.objectID {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 16)
                        }
                    }
                }
            }
        }
        .background(Color("cardNote").opacity(0.8))
        .cornerRadius(20)
        .sheet(item: $selectedNote) { note in
            NoteDetailSheetView(note: note)
                .environmentObject(PhotoLibraryViewModel())
                .environmentObject(NotesViewModel())
        }
    }
}
struct NoteRowView: View {
    var note: Notes
    
    private var photo: UIImage? {
        if let photosData = note.notePhoto as? [Data], let firstData = photosData.first {
            return UIImage(data: firstData)
        }
        return nil
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let image = photo {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("defaultBook")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 50, height: 70)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(note.noteTitle ?? "Sem título")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(note.noteDescription ?? "Sem conteúdo")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .contentShape(Rectangle())
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/SheetsComponents/SheetHeaderView.swift\ ⁠
⁠ swift
//
//  SheetHeaderView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 14/08/26.
//

import SwiftUI

struct SheetHeaderView: ToolbarContent {
    let title: String
    let actionIcon: String
    
    @Binding var showingDiscardAlert: Bool
    
    var onCancel: () -> Void
    var onConfirm: () -> Void
    var onDiscard: () -> Void
  
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                showingDiscardAlert = true
            }) {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .confirmationDialog(
                "Atenção",
                isPresented: $showingDiscardAlert,
                titleVisibility: .hidden
            ) {
                Button("Descartar", role: .destructive) {
                    onDiscard()
                }
                
                Button("Continuar Editando", role: .cancel) { }
                
            } message: {
                Text("Deseja mesmo descartar a edição?")
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(title)
                .foregroundColor(Color("LinesColor"))
                .font(.bitter(.semibold, style: .title2))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                onConfirm()
            }) {
                Image(systemName: actionIcon)
                    .fontWeight(.semibold)
                    .font(.body.bold())
                    .foregroundColor(.title)
            }
            
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color("ActionColor"))
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showAlert = false
        
        var body: some View {
            NavigationStack {
                Text("Conteúdo da sua Sheet aqui")
                    .toolbar {
                        SheetHeaderView (
                            title: "Cadastrar livro",
                            actionIcon: "checkmark",
                            showingDiscardAlert: $showAlert,
                            onCancel: { print("Clicou no X") },
                            onConfirm: { print("Clicou no Check") },
                            onDiscard: { print("Clicou em descartar") }
                        )
                    }
            }
        }
    }
    
    return PreviewWrapper()
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/GeralComponents/ButtonAction.swift\ ⁠
⁠ swift
//
//  ButtonAction.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI

struct ButtonAction: View {
    var text: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
                    action?()
        }) {
            Text(text)
                .font(.body)
                .frame(maxWidth: .infinity)
                .fontWeight(.medium)
                .padding(.vertical, 14)
                .background(Color("ActionColor"))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        
    }
}

#Preview {
    VStack(spacing: 16) {
            ButtonAction(text: "Teste Sem Ação")
            
            ButtonAction(text: "Teste Com Ação") {
                print("Botão pressionado!")
            }
        }
        .padding()
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/GeralComponents/TipsComponent.swift\ ⁠
⁠ swift
//
//  TipsComponent.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 16/08/26.
//

import Foundation
import SwiftUI

struct TipsComponent: View {
    let content: String
    
    var body: some View {
        Text(content)
            .font(.caption)
           .fontWeight(.regular)
           .foregroundColor(.secondary)
           .padding(.horizontal, 5)
    }
}

#Preview {
    TipsComponent(
        content: "Tips"
    )
}
 ⁠

---

### Arquivo: \⁠ ./View/Components/GeralComponents/ToolBarButton.swift\ ⁠
⁠ swift
//
//  StopwatchToolbar.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

//
//  StopwatchToolbar.swift
//  CH4-Books
//

import SwiftUI

struct ToolBarButton: ToolbarContent {
    var action: () -> Void
    var icon: String
    var colorName: String?

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            
            Button(action: {
                action()
            }) {
                Image(systemName: icon)
                        .font(icon == "note.text.badge.plus" ? .subheadline : .body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(colorName != nil ? Color(colorName!) : Color(""))
            
          
        }
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
            .toolbar {
                ToolBarButton(action: {}, icon: "note.text.badge.plus")
            }
    }
    .preferredColorScheme(.dark)
}
 ⁠

---

### Arquivo: \⁠ ./View/BookCaseView.swift\ ⁠
⁠ swift
//
//  BookCaseView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 15/08/26.
//

import SwiftUI

struct BookCaseView: View {
    @ObservedObject var bookViewModel: BooksViewModel
    @State private var isShowingSheet = false
    
    @State private var selectedBookForDetail: Books? = nil
    @State private var isShowingBookDetail = false
    
    
    var books: [Books] {
        bookViewModel.savedBooks
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    //@State var books = self.booksViewModel.savedBooks
    
    var body: some View {
        
        NavigationStack{
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (alignment: .leading, spacing: 24) {
                        //título e botão "+"
                        HStack {
                            TitleComponent(title: "Meus Livros")
                                
                        }
                        .padding(.top, 28)
                        
                        CardTotalPages(totalPages: bookViewModel.countReadedPages())
                        
                        DailyGoalCardView(
                            pagesReadToday: 12,
                            targetPages: 30,
                            onEditAction: {
                                print("Editar meta clicado")
                            }
                        )
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(books) { book in
                                NavigationLink(destination: BookDetailView(bookViewModel: bookViewModel, book: book)){
                                    BookCardView(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .environmentObject(bookViewModel)
                    }
                    .padding(.horizontal, 24)
                }
                
                //.navigationTitle("Meus livros")
                //.navigationBarTitleDisplayMode(.large)
                .toolbar {
                    BookCaseToolbar(onAddClick: {
                        isShowingSheet.toggle()
                    })
                }
            }
        }
        .onAppear {
            withAnimation{
                bookViewModel.fetchBooks()
            }
        }
//        .fakeSheet(isPresented: $isShowingBookDetail) {
//            if let selectedBookForDetail {
//                BookDetailView(viewModel: booksViewModel, book: selectedBookForDetail)
//            }
//        }
        .sheet(isPresented: $isShowingSheet, onDismiss: {
            withAnimation{
                bookViewModel.fetchBooks()
            }
            
        }) {
            BookSheetView(bookToEdit: nil)
                .environmentObject(PhotoLibraryViewModel())
                .environmentObject(bookViewModel)
                
        }
    }
}

#Preview {
    BookCaseView(bookViewModel: BooksViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(NotesViewModel())
}
 ⁠

---

### Arquivo: \⁠ ./View/Garbage/NotesListView.swift\ ⁠
⁠ swift
//
//  NotesListView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 16/08/26.
//

import Foundation
import SwiftUI

struct NotesListView: View {
    @ObservedObject var notesViewModel: NotesViewModel
    
    var body: some View {
        NavigationStack {
            List(notesViewModel.savedNotes) { note in
                NoteCardView(note: note)
                    //.listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
            .navigationTitle("Minhas Notas")
        }
    }
}

struct NoteCardView: View {
    let note: Notes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top) {
                Text(note.noteTitle ?? "Sem título")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(note.noteCategory ?? "Sem categoria")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(.accentColor)
                    .clipShape(Capsule())
            }
            
            Text(note.noteDescription ?? "Sem descrição")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            
            if let photosData = note.notePhoto as? [Data], !photosData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(photosData, id: \.self) { data in
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
            
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NotesListView(notesViewModel: NotesViewModel())
}
 ⁠

---

### Arquivo: \⁠ ./View/StopwatchView.swift\ ⁠
⁠ swift
//
//  StopWatchView.swift
//  CH4-Books
//
//  Created by Lucas on 15/08/26.
//

import SwiftUI

    
struct StopwatchView: View {
    @State private var selectedBook = "Livro 1"
    @State private var isShowingSheet = false
    @EnvironmentObject var stopwatchViewModel: StopwatchViewModel
    //@State private var progress: Double = 0.5
    
    var body: some View {

        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.49
            let cardHeight = geometry.size.height * 0.38
            
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                // 10 Anéis Concentricos ao Fundo
                ConcentricRingsView(progress: stopwatchViewModel.timeProgress)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    //card central
                    VStack (spacing: 24){
                        
                        Text(stopwatchViewModel.timerFormater())
                            .font(.custom("Bitter", size: 70, relativeTo: .largeTitle))
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .monospacedDigit()
                        
                        //progresso do livro
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Text("Progresso do livro")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .fontWeight(.regular)
                                
                                Text("\(Int(stopwatchViewModel.bookProgress * 100))%")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("ProgressBar"))
                            }
                            
                            ProgressView(value: stopwatchViewModel.bookProgress)
                                .tint(Color("ProgressBar"))
                                .frame(width: 170)
                            
                        }
                        
                        //seleção do livro
                        VStack(spacing: 6) {
                            Text("Selecione o livro")
                                .font(.subheadline)
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                            
                            Menu {
                                Picker("Selecione o livro", selection: $selectedBook){
                                    Text("Livro 1").tag("Livro 1")
                                    Text("Livro 2").tag("Livro 2")
                                    Text("Livro 3").tag("Livro 3")
                                }
                            } label: {
                                Text(selectedBook)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            
                            //botao inciar
                            Button(action: {
                                
                                stopwatchViewModel.isRunning.toggle()
                                
                                if stopwatchViewModel.isRunning {
                                    stopwatchViewModel.startTimer()
                                    
                                }
                                else{
                                    stopwatchViewModel.stop()
                                }
                                
                               
                            }) {
                                Text(stopwatchViewModel.isRunning ? "Parar" : "Iniciar")
                                    .font(.title3)
                                    .frame(maxWidth: .infinity)
                                    .fontWeight(.medium)
                                    .padding(.vertical, 14)
                                    .background(
                                        Group {
                                            if stopwatchViewModel.isRunning {
                                                Color.red.opacity(0.85)
                                            } else {
                                                Color("ActionColor")
                                            }
                                        }
                                    )
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            
                        }
                    }
                    .frame(width: cardWidth, height: cardHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 64, style: .continuous)
                            .fill(Color("BackgroundColorViews"))
                    )
                    .padding(.bottom, 26)
                    Spacer()
                    
                }
                .padding(.horizontal)
            }
            //botao de editar (top bar)
            .overlay(
                HStack {
                    Button(action: {
                        isShowingSheet.toggle()
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color("TitleColor"))
                            .frame(width: 48, height: 48)
                            .background(Color("ActionColor").opacity(0.8), in: Circle())
                    }
                    .glassEffect(.regular, in: Circle())
                    .sheet(isPresented: $isShowingSheet) {
                        NoteSheetView(book: PreviewProviderHelper.sampleBook)
                    }
                    
                }
                .padding(.horizontal, 24)
                .padding(.top, geometry.safeAreaInsets.top > 0 ? 8 : 16),
                alignment: .topTrailing

            )
           
        }
    }
}

#Preview {
    StopwatchView()
        .preferredColorScheme(.dark)
        .environmentObject(StopwatchViewModel())
        .environmentObject(PhotoLibraryViewModel())
}
 ⁠

---

### Arquivo: \⁠ ./View/SplashView.swift\ ⁠
⁠ swift
//
//  SplashView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "FEF4C7"), location: 0.00),
                    .init(color: Color(hex: "FEF0B8"), location: 0.05),
                    .init(color: Color(hex: "FEE78F"), location: 0.20),
                    .init(color: Color(hex: "FEDF6C"), location: 0.35),
                    .init(color: Color(hex: "FED952"), location: 0.51),
                    .init(color: Color(hex: "FED53F"), location: 0.66),
                    .init(color: Color(hex: "FED233"), location: 0.83),
                    .init(color: Color(hex: "FFD230"), location: 1.00)
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image("FrushLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 222, height: 184)
                    .foregroundColor(Color(red: 0.15, green: 0.10, blue: 0.05))
                
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: 1
        )
    }
}

#Preview {
    SplashView()
}
 ⁠

---

### Arquivo: \⁠ ./View/MyNotesListView.swift\ ⁠
⁠ swift
//
//  NoteListView.swift
//  CH4-Books
//
//  Created by Lucas on 19/08/26.
//

import SwiftUI
import CoreData

struct MyNotesListView: View {
    @StateObject private var viewModel = NotesViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedNote: Notes?
    @State private var isPresentedAddNote: Bool = false
    
    var book: Books?
    
    var body: some View {
        ZStack {
            Color(.backgroundColorViews).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                TitleComponent(title: "Minhas notas")
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        ForEach(viewModel.savedNotes, id: \.self) { note in
                            
                            Button(action: {
                                selectedNote = note
                            }) {
                                NoteRowView(note: note)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            MyNotesToolBar(onBackClick: { dismiss() }, onAddClick: {
                isPresentedAddNote = true
            })
        }
        .onAppear {
            viewModel.fetchNotes(for: book)
        }
        .sheet(item: $selectedNote) { note in
            NoteDetailSheetView(note: note)
        }
        .sheet(isPresented: $isPresentedAddNote, onDismiss: {
            viewModel.fetchNotes(for: book)
        }) {
            if let book = book {
                NoteSheetView(book: book)
                    .environmentObject(viewModel)
            }
        }
    }
}

struct NotesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyNotesListView(book: nil)
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/StopwatchInicialView.swift\ ⁠
⁠ swift
//
//  StopwatchInicialView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI

struct StopwatchInitialView: View {
    var namespace: Namespace.ID
    @EnvironmentObject var stopwatchViewModel: StopwatchViewModel
    
    @Binding var selectedBook: Books?
    
    @State private var isShowingNoteSheet = false
    @State private var isShowingSelectBookSheet = false
    @State private var isShowingTimerPicker = false
    
    @State private var selectedDuration: TimeInterval = 15 * 60

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color("BackgroundColorViews")
                        .ignoresSafeArea()
                    
                    // Fundo com a capa do livro e gradiente
                    Group {
                        if let imageData = selectedBook?.bookCover, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                        } else {
                            Image("bookTest2")
                                .resizable()
                        }
                    }
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.20)
                    .overlay(
                        ZStack {
                            Color("BackgroundColorViews").opacity(0.70)
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color("BackgroundColorViews").opacity(0.80),
                                    Color("BackgroundColorViews")
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                    )
                    .clipped()
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // Campo de Seleção do Tempo
                        VStack(spacing: 8) {
                            Text("Selecione o tempo de leitura")
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                isShowingTimerPicker = true
                            }) {
                                Text(stopwatchViewModel.timerFormater())
                                    .font(.custom("Bitter", size: 60, relativeTo: .largeTitle))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                                    .matchedGeometryEffect(id: "timerText", in: namespace)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        ZStack {
                                            // vidro claro (branco a 20%)
                                            RoundedRectangle(cornerRadius: 100, style: .continuous)
                                                .fill(Color("StopwatchSelectors").opacity(0.2))
                                        }
                                    )
                                    .overlay(
                                        // borda reluzente com brilho no topo
                                        RoundedRectangle(cornerRadius: 100, style: .continuous)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 0.5
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Card de Seleção do Livro
                        VStack(spacing: 24) {
                            VStack(spacing: 8) {
                                Text("Selecione o livro")
                                    .font(.body)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    isShowingSelectBookSheet = true
                                }) {
                                    HStack(spacing: 12) {
                                        if let imageData = selectedBook?.bookCover, let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 52)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } else {
                                            Image("defaultBook")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 52)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .padding(.leading, 8)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(selectedBook?.bookTitle ?? "Hush, Hush")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            Text(selectedBook?.bookAuthor ?? "Becca Fitzpatrick")
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.white.opacity(0.8))
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        ZStack {
                                            // vidro claro
                                            RoundedRectangle(cornerRadius: 100, style: .continuous)
                                                .fill(Color("StopwatchSelectors").opacity(0.20))
                                        }
                                    )
                                    .overlay(
                                        // Borda reluzente
                                        RoundedRectangle(cornerRadius: 100, style: .continuous)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 0.5
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            //  Progresso do Livro
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Progresso do livro")
                                        .font(.body)
                                        .foregroundColor(.white)
                                    Text("\(Int(stopwatchViewModel.bookProgress * 100))%")
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("ActionColor"))
                                }
                                
                                GeometryReader { barGeo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.15))
                                        Capsule()
                                            .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                                            .frame(width: barGeo.size.width * CGFloat(stopwatchViewModel.bookProgress))
                                    }
                                }
                                .frame(height: 10)
                                .padding(.horizontal, 28)
                            }
                            
                           
                            VStack(spacing: 12) {
                                // botão Principal: Iniciar / Pausar / Continuar
                                ButtonAction(text: buttonTitle){
                                    if stopwatchViewModel.timerState == .running {
                                        stopwatchViewModel.pauseTimer()
                                    } else {
                                        stopwatchViewModel.startTimer()
                                    }
                                }
                                .padding(.top, 8)

                                // botão Secundário: abandonar Leitura (exibido apenas se a leitura começou ou está pausada)
                                if stopwatchViewModel.timerState != .stopped {
                                    Button(action: {
                                        stopwatchViewModel.abandonTimer()
                                    }) {
                                        Text("Abandonar leitura")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.red)
                                            .padding(.vertical, 8)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Computada auxiliar para o rótulo do botão
                            var buttonTitle: String {
                                switch stopwatchViewModel.timerState {
                                case .running:
                                    return "Pausar leitura"
                                case .paused:
                                    return "Continuar leitura"
                                case .stopped:
                                    return "Iniciar leitura"
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                .toolbar {
                    ToolBarButton(
                        action: { isShowingNoteSheet = true },
                        icon: "note.text.badge.plus"
                    )
                }
                .sheet(isPresented: $isShowingNoteSheet) {
                    if let currentBook = selectedBook {
                        NoteSheetView(book: currentBook)
                    } else {
                        VStack(spacing: 12) {
                            Text("Atenção")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Selecione um livro antes de adicionar uma anotação.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .presentationDetents([.height(180)])
                    }
                }
                .sheet(isPresented: $isShowingSelectBookSheet) {
                    SelectBookSheetView(selectedBook: $selectedBook)
                }

                .sheet(isPresented: $isShowingTimerPicker) {
                    VStack(spacing: 20) {
                        HStack(spacing: 0) {
                            // Picker de Horas
                            Picker("Horas", selection: Binding(
                                get: { Int(selectedDuration) / 3600 },
                                set: { newHours in
                                    let currentMinutes = (Int(selectedDuration) % 3600) / 60
                                    let newTotal = TimeInterval((newHours * 3600) + (currentMinutes * 60))
                                    selectedDuration = newTotal
                                    stopwatchViewModel.totalTime = newTotal
                                    stopwatchViewModel.elapsedTime = newTotal
                                }
                            )) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text("\(hour) h").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)

                            // Picker de Minutos
                            Picker("Minutos", selection: Binding(
                                get: { (Int(selectedDuration) % 3600) / 60 },
                                set: { newMinutes in
                                    let currentHours = Int(selectedDuration) / 3600
                                    let newTotal = TimeInterval((currentHours * 3600) + (newMinutes * 60))
                                    selectedDuration = newTotal
                                    stopwatchViewModel.totalTime = newTotal
                                    stopwatchViewModel.elapsedTime = newTotal
                                }
                            )) {
                                ForEach(0..<60, id: \.self) { minute in
                                    Text("\(minute) min").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .padding(.horizontal)

                        Button("Confirmar") {
                            isShowingTimerPicker = false
                        }
                        .font(.body.weight(.semibold))
                        .foregroundColor(Color("ActionColor"))
                        .padding(.bottom)
                    }
                    .presentationDetents([.height(260)])                 
                 
                }
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    @Previewable @State var selectedBook: Books? = nil
    
    StopwatchInitialView(namespace: namespace, selectedBook: $selectedBook)
        .preferredColorScheme(.dark)
        .environmentObject(StopwatchViewModel())
        .environmentObject(BooksViewModel.preview)
}

 ⁠

---

### Arquivo: \⁠ ./View/EditDailyGoalSheet.swift\ ⁠
⁠ swift
//
//  EditDailyGoalSheet.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//
import SwiftUI

struct EditDailyGoalContent: View {
    // binding atualizado para representar o tempo total em minutos
    @Binding var minutesPerDay: Int
    @State private var showAlert = false
    var onDismiss: () -> Void = {}
    var onSave: () -> Void = {}

    // computadas locais para facilitar o bind das rodas do Picker
    private var hours: Int {
        minutesPerDay / 60
    }
    
    private var minutes: Int {
        minutesPerDay % 60
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Título e Subtítulo
                VStack(spacing: 4) {
                    Text("Editar objetivo diário")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)

                    Text("Defina quantos minutos você\ndeseja ler por dia")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // selector estilo cronômetro hrs e min
                VStack(spacing: 0) {
                    Text("Tempo por dia")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.top, 12)

                    HStack(spacing: 0) {
                        // picker de hrs
                        Picker("Horas", selection: Binding(
                            get: { hours },
                            set: { newHours in
                                minutesPerDay = (newHours * 60) + minutes
                            }
                        )) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour) h").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)

                        // picker de mins
                        Picker("Minutos", selection: Binding(
                            get: { minutes },
                            set: { newMinutes in
                                minutesPerDay = (hours * 60) + newMinutes
                            }
                        )) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(height: 120)
                    .padding(.horizontal, 8)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("LinesColor"), lineWidth: 0.3)
                )

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal, 20)
            .toolbar {
                SheetHeaderView(
                    title: "",
                    actionIcon: "checkmark",
                    showingDiscardAlert: $showAlert,
                    onCancel: { onDismiss() },
                    onConfirm: { onSave() },
                    onDiscard: { onDismiss() }
                )
            }
        }
    }
}

#Preview("Edit Daily Goal - SheetHeaderView") {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        @State private var goalMinutes = 15 // exemplo 0h 15min

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                Button("Abrir Sheet") {
                    isPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $isPresented) {
                EditDailyGoalContent(
                    minutesPerDay: $goalMinutes,
                    onDismiss: { isPresented = false },
                    onSave: { isPresented = false }
                )
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color("BackgroundColorViews"))
            }
        }
    }

    return PreviewWrapper()
}
 ⁠

---

### Arquivo: \⁠ ./View/Onboarding/FirstOnboardView.swift\ ⁠
⁠ swift
//
//  FirstOnboardView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 17/08/26.
//

import SwiftUI

struct FirstOnboardView: View {
    var onAdvance: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            Image("OnboardingOficial")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black, location: 0.68),
                            .init(color: .clear, location: 0.52)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 16) {
                Spacer()
        
                Capsule()
                    .fill(Color("ProgressBar"))
                    .frame(width: 36, height: 4)
                    .padding(.top, 8)
                

                VStack(spacing: 2) {
                    Text("Bem-vindo(a)")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Text("ao")
                            .font(.largeTitle)
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                        
                        Text("Frush")
                            .font(.bitter(.bold, style: .largeTitle))
                            .foregroundColor(.white)
 
                    }
                }
                
                // Subtítulo com destaque final em amarelo
                (Text("Venha cadastrar seus livros, registrar suas notas de leitura e alcançar suas metas ")
                    .foregroundColor(.white.opacity(0.85)) +
                 Text("no seu próprio ritmo.")
                    .foregroundColor(Color("ProgressBar"))
                    .bold())
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                
                Spacer()
                
                ButtonAction(text: "Avançar") {
                    //colocar acao
                }
                .padding(.bottom, 40)
                
            }
            .padding(.horizontal, 26)
            .padding(.top, 400)
        }
    }
}

#Preview {
    FirstOnboardView()
}
 ⁠

---

### Arquivo: \⁠ ./View/Onboarding/SecondOnboardView.swift\ ⁠
⁠ swift
//
//  SecondOnboardView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 17/08/26.
//
/*
 import SwiftUI
 
 struct SecondOnboardView: View {
 @EnvironmentObject var booksViewModel: BooksViewModel
 @State private var selectedGoal: String = ""
 
 var body: some View {
 ZStack {
 Color("BackgroundColorViews")
 .ignoresSafeArea()
 
 VStack {
 Spacer()
 Spacer()
 
 Text("Quanto tempo você \n deseja por dia?")
 .font(.title2)
 .fontWeight(.semibold)
 .padding(.bottom, 30)
 .multilineTextAlignment(.center)
 
 Rectangle()
 .frame(width: 100, height: 2.5)
 .foregroundColor(Color("ActionColor"))
 .padding(.bottom, 30)
 
 Text("Definir um tempo diário ajuda a manter a consistência. Você pode alterar isso a qualquer momento")
 .font(.body)
 .fontWeight(.light)
 .padding(.bottom, 30)
 .multilineTextAlignment(.center)
 .foregroundColor(.white)
 
 
 MenuSheetPicker(
 title: "",
 placeholder: "Selecione seu objetivo diário",
 selectedValue: $selectedGoal,
 options: booksViewModel.goalOptions,
 formatOption: { "\($0) minutos" }
 )
 
 
 Spacer()
 Spacer()
 
 Button(action: {
 
 }) {
 Text("Iniciar jornada")
 .font(.title3)
 .frame(maxWidth: .infinity)
 .fontWeight(.medium)
 .padding(.vertical, 14)
 .background(Color("ActionColor"))
 .foregroundColor(.white)
 .clipShape(Capsule())
 }
 .padding(.bottom, 30)
 
 }
 .padding(.horizontal, 26)
 }
 
 
 }
 }
 
 #Preview {
 SecondOnboardView()
 .environmentObject(BooksViewModel())
 }
 */

import SwiftUI

struct SecondOnboardView: View {
    @EnvironmentObject var booksViewModel: BooksViewModel
    @State private var selectedGoal: String = ""
    var onStart: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // Fundo escuro base
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            // Ilustração dos arcos no topo (supondo que seja a mesma imagem ou similar com máscara)
            Image("OnboardingOficial2")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
               
            
            // Conteúdo principal
            VStack(spacing: 20) {
                Spacer()
                
                // Título principal
                VStack(spacing: 2) {
                    Text("Defina a sua ")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .foregroundColor(.white) +
                    Text("meta")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Text("diária")
                            .font(.bitter(.bold, style: .largeTitle))
                            .foregroundColor(.white)
                        
                        Text("de leitura")
                            .font(.largeTitle)
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.top, 350)
                
                // Subtítulo com destaque amarelo
                (Text("Definir um tempo diário ajuda\nem ")
                    .foregroundColor(.white.opacity(0.85)) +
                 Text("manter a consistência")
                    .foregroundColor(Color("ProgressBar"))
                    .bold())
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                
                // Picker / Menu de Seleção
                MenuSheetPickerOnboarding(
                    title: "",
                    placeholder: "Selecione uma meta",
                    selectedValue: $selectedGoal,
                    options: booksViewModel.goalOptions,
                    formatOption: { "\($0) minutos" }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Texto informativo logo abaixo do Picker
                Text("Você pode alterar isso a qualquer momento")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Botão de ação "Iniciar jornada"
                ButtonAction(text: "Iniciar jornada") {
                    onStart?()
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 26)
            
        }
    }
}

#Preview {
    SecondOnboardView()
        .environmentObject(BooksViewModel())
}
 ⁠

---

### Arquivo: \⁠ ./View/NotesView.swift\ ⁠
⁠ swift
//
//  NotesView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 17/08/26.
//

import SwiftUI

struct NotesView: View {
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Minhas notas")
                        .font(.bitter(.medium, style: .largeTitle))
                        .foregroundStyle(Color("TitleColor"))
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(0..<5) { _ in
                                NotesCardView(
                                    imageName: "defaultBook",
                                    tagText: "Referência",
                                    title: "Título da nota",
                                    description: "Descrição inicial da primeira..."
                                )
                            }
                        }
                    }
                
                }
                .padding(.horizontal, 24)
    
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolBarButton(action: {}, icon: "plus", colorName: "ActionColor")
            }
        }
    }
}

#Preview {
    NotesView()
}
 ⁠

---

