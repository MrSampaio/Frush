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

class StopwatchViewModel: ObservableObject {
    @Published var elapsedTime: TimeInterval = 10
    @Published var totalTime: TimeInterval = 10
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
        
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.elapsedTime > 0 {
                self.elapsedTime -= 0.1
            } else {
                self.stop()
            }
            
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func updatePage(to newPage: Int) {
        self.currentPage = newPage
    }
    
    func timerFormater() -> String{
        let current = max(0, Int(elapsedTime))
        return String(format: "%02d:%02d", current / 60, current % 60)
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
                print("Error loading persistent stores: \(error)")
            }
        }
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
}

////
////  CoreDataManager.swift
////  CH4-Books
////
////  Created by Julio Sampaio on 13/08/26.
////
//
//import Foundation
//import CoreData
//
//class CoreDataManager {
//    let persistentContainer: NSPersistentContainer
//    static let shared = CoreDataManager()
//    
//    var viewContext: NSManagedObjectContext {
//        return self.persistentContainer.viewContext
//    }
//    
//    init() {
//        self.persistentContainer = NSPersistentContainer(name: "Database")
//        
//        // Configurar para usar memória RAM
//        let description = NSPersistentStoreDescription()
//        description.type = NSInMemoryStoreType  // ← Aqui é a mágica
//        self.persistentContainer.persistentStoreDescriptions = [description]
//        
//        self.persistentContainer.loadPersistentStores { (description, error) in
//            if let error = error {
//                print("Error loading persistent stores: \(error)")
//            } else {
//                print("Core Data loaded in memory ✅")
//            }
//        }
//        
//        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
//    }
//}

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
}
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
    
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
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
        
        let coverData = photoLibraryViewModel.convertImageToData(image: bookCover!)
        
        
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
    func deleteBook(indexSet: IndexSet) throws{

        guard let index = indexSet.first else { return }
        let book = self.savedBooks[index]
        
        CoreDataManager.shared.viewContext.delete(book)
        
        try self.saveBook()
        self.fetchBooks()

    }
    
    func updateBook(IndexSet: IndexSet, bookTitle: String?, bookAuthor: String?, bookCover: Data?, bookCategory: String?, bookTotalPages: Int16?, bookCurrentPage: Int16?, bookGoal: Int16?) throws {
        
        guard let index = IndexSet.first else { return }
        
        let book = self.savedBooks[index]
        
        // valores finais que serão aplicados (novo valor, ou o valor atual se nil)
        let finalTitle = (bookTitle?.trimmingCharacters(in: .whitespacesAndNewlines)) ?? book.bookTitle
        let finalTotalPages = bookTotalPages ?? book.bookTotalPages
        let finalCurrentPage = bookCurrentPage ?? book.bookCurrentPage
        let finalGoal = bookGoal ?? book.bookGoal
        
        if let finalTitle, finalTitle.isEmpty {
            throw BookError.invalidTitle
        }
        
        if finalTotalPages <= 0 {
            throw BookError.invalidTotalPages
        }
        
        if finalCurrentPage < 0 {
            throw BookError.invalidCurrentPage
        }
        
        if finalCurrentPage > finalTotalPages {
            throw BookError.invalidPageLogic
        }
        
//        if finalGoal <= 0 {
//            throw BookError.invalidGoal
//        }
        
        // só aplica as mudanças se passou em todas as validações
//        book.id = UUID()
        book.bookTitle = finalTitle
        book.bookAuthor = bookAuthor ?? book.bookAuthor
        book.bookCover = bookCover ?? book.bookCover
        book.bookCategory = bookCategory ?? book.bookCategory
        book.bookTotalPages = finalTotalPages
        book.bookCurrentPage = finalCurrentPage
        book.bookGoal = finalGoal
        
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
                            BookCellView(book: book)
                        }
                    }
                }
                
                if !filteredNotes.isEmpty {
            
                    Section("Notas") {
                        ForEach(filteredNotes, id: \.self) { note in
                            NoteCellView(note: note)
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
            }
        }
    }
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
    @EnvironmentObject var booksViewModel: BooksViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    
    @State var showingDiscardAlert: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var titleText: String = ""
    @State private var noteText: String = ""
    @State var image: UIImage? = nil
    @State var selectedCategory: String = ""
    
    @State private var selectedBook: Books? = nil
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCameraPicker = false
    @State private var capturedImage: UIImage? = nil
    @State private var showMediaSourceMenu = false
    @State private var showPhotoPicker = false
    
    var book: Books
   
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
                
                .toolbar {
                    SheetHeaderView(
                        title: "Adicionar nota",
                        actionIcon: "checkmark",
                        showingDiscardAlert: $showingDiscardAlert,
                        onCancel: { dismiss() },
                        onConfirm: handleConfirm,
                        onDiscard: { dismiss() }
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
        }
    }
    
    private func handleConfirm() {
        do {
            try notesViewModel.addNote(
                noteTitle: titleText,
                noteDescription: noteText,
                noteCategory: selectedCategory,
                notePhotos: photoLibraryViewModel.noteImages.map(\.image),
                to: book
            )
            
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
        TextFieldSheets(
            text: $titleText,
            placeholder: "Adicione o título",
            label: nil
        )
    }
    
    private var noteTextEditor: some View {
        ZStack(alignment: .topLeading) {
            if noteText.isEmpty {
                Text("Escreva sua nota...")
                    .foregroundColor(Color("TextFieldPlaceholderColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .zIndex(1)
                    .allowsHitTesting(false)
                    .font(.system(.body, weight: .regular))
            }
            
            TextEditor(text: $noteText)
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
        
        return Menu {
            Button {
                showCameraPicker = true
            } label: {
                Label("Tirar foto com a Câmera", systemImage: "camera")
            }
            .disabled(isLimitReached)
            
            Button {
                showPhotoPicker = true
            } label: {
                Label("Escolher da Galeria", systemImage: "photo.on.rectangle")
            }
            .disabled(isLimitReached)
            
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
            .cornerRadius(10)
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
              
                    .toolbar {
                        SheetHeaderView(
                            title: toolbarTitle,
                            actionIcon: "checkmark",
                            showingDiscardAlert: $showingDiscardAlert,
                            onCancel: {},
                            onConfirm: {
                                
                                do{

//                                    
//                                    let coverData = photoLibraryViewModel.selectedImage?.jpegData(compressionQuality: 0.7) ?? Data()
                                    
//                                    let goalInt = Int16(selectedGoal.filter("0123456789".contains)) ?? 0
                                    
                                    try booksViewModel.addBook(
                                        bookTitle: bookTitle,
                                        bookAuthor: bookAuthor,
                                        bookCover: photoLibraryViewModel.selectedImage,
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
                BookCaseView(booksViewModel: BooksViewModel())
                    .environmentObject(PhotoLibraryViewModel())
            }
            Tab("Cronômetro", systemImage: "timer"){
                StopwatchView()
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
    @ObservedObject var viewModel: BooksViewModel
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var isPresentedAddNote: Bool = false
    @State private var isPresentedEditBook: Bool = false
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    
    var book: Books? = nil
    
    private var currentBook: Books? {
        book ?? viewModel.savedBooks.first
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
                            
                            CardTotalPages(totalPages: 100)
                            .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                NotesHeaderview(isPresentedAddNote: $isPresentedAddNote)
                                NotesSectionView(notes: notesViewModel.savedNotes)
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
            .sheet(isPresented: $isPresentedAddNote, onDismiss: {
                notesViewModel.fetchNotes(for: currentBook)
            }) {
                if let currentBook {
                    NoteSheetView(book: currentBook)
                        .environmentObject(notesViewModel)
                }
            }
            .sheet(isPresented: $isPresentedEditBook){
                BookSheetView(bookToEdit: book)
                    .environmentObject(PhotoLibraryViewModel())
                    .environmentObject(BooksViewModel())
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
    BookDetailView(viewModel: BooksViewModel())
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
                .frame(width: 80, height: 95)
                .cornerRadius(16)
                .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(tagText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color("TagNoteColor"))
                    .clipShape(Capsule())
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
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
    let book: Books
    
    @State private var isEditingSheetPresented = false
    
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    
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
                //showDeleteAlert = true
            } label: {
                Label("Apagar Livro", systemImage: "trash")
                    .font(.body)
            }
        }
        .frame(width: 170)
        .cornerRadius(12)
        
        .sheet(isPresented: $isEditingSheetPresented) {
                    BookSheetView(bookToEdit: book)
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
    var book: Books
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

### Arquivo: \⁠ ./View/Components/SheetsComponents/NoteDetailSheetView.swift\ ⁠
⁠ swift
//
//  NoteDetailSheetView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct NoteDetailSheetView: View {
    var note: Notes
    
    @Environment(\.dismiss) var dismiss
    
    private var noteImages: [UIImage] {
        if let photosData = note.notePhoto as? [Data] {
            return photosData.compactMap { UIImage(data: $0) }
        }
        return []
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.backgroundColorViews)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                NotesHeaderEditView(
                    title: "Nota",
                    onClose: { dismiss() },
                    onEdit: { }
                )
                
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

### Arquivo: \⁠ ./View/Components/SheetsComponents/NotesHeaderEditView.swift\ ⁠
⁠ swift
//
//  NotesHeaderEditView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct NotesHeaderEditView: View {
    var title: String = "Nota"
    var onClose: () -> Void
    var onEdit: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(title)
                .font(.bitter(.semibold, style: .title2))
                .foregroundColor(Color("LinesColor"))
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.orange)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
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
        }
    }
}
struct NoteRowView: View {
    var note: Notes
    
    private var thumbnailImage: UIImage? {
        if let photosData = note.notePhoto as? [Data], let firstData = photosData.first {
            return UIImage(data: firstData)
        }
        return nil
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("defaultBook")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                }
            }
            .frame(width: 50, height: 50)
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
    @ObservedObject var booksViewModel: BooksViewModel
    @State private var isShowingSheet = false
    
    @State private var selectedBookForDetail: Books? = nil
    @State private var isShowingBookDetail = false
    
    
    var books: [Books] {
        booksViewModel.savedBooks
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
                            
                            
    //                        Spacer()
    //
    //                        Button(action: {
    //                            // Ação do botão
    //                        }) {
    //                            Image(systemName: "plus")
    //                                .font(.system(.title, weight: .semibold))
    //                                .foregroundStyle(Color("TitleColor"))
    //                                .frame(width: 48, height: 48)
    //                                .background(Color.black.opacity(0.3), in: Circle())
    //                        }
    //                        .glassEffect(.regular, in: Circle())
                            
                                
                        }
                        .padding(.top, 28)
                        
                        CardTotalPages(totalPages: booksViewModel.countReadedPages())
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(books) { book in
                                NavigationLink(destination: BookDetailView(viewModel: booksViewModel, book: book)){
                                    BookCardView(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
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
//        .fakeSheet(isPresented: $isShowingBookDetail) {
//            if let selectedBookForDetail {
//                BookDetailView(viewModel: booksViewModel, book: selectedBookForDetail)
//            }
//        }
        .sheet(isPresented: $isShowingSheet) {
            BookSheetView(bookToEdit: nil)
                .environmentObject(PhotoLibraryViewModel())
                .environmentObject(BooksViewModel())
                
        }
    }
}

#Preview {
    BookCaseView(booksViewModel: BooksViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
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
                                    stopwatchViewModel.start()
                                    
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
    var body: some View {
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                    Image("Onboarding")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    Text("Olá, seja bem-vindo(a)!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 30)
                        .multilineTextAlignment(.center)
                    
                    Rectangle()
                    .frame(width: 100, height: 2.5)
                        .foregroundColor(Color("ActionColor"))
                        .padding(.bottom, 30)
                    
                    Text("No Frush você consegue cadastrar seus livros, registrar seus momentos de leitura e alcançar suas metas no seu próprio ritmo.")
                        .font(.body)
                        .fontWeight(.light)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Spacer()
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Text("Avançar")
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
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                
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
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    NotesView()
}
 ⁠

---

