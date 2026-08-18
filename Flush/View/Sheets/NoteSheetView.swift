
//
//  SheetNotes.swift
//  CH4-Books
//
//  Created by Lucas on 14/08/26.
//
 
import SwiftUI
import PhotosUI
import CoreData

struct SelectableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
 
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
    @State private var selectedImages: [SelectableImage] = []
    
    @State private var showCameraPicker = false
    @State private var capturedImage: UIImage? = nil
    @State private var showMediaSourceMenu = false
    
    @State private var showPhotoPicker = false
    
    //descomentar e adicionar em to: book
    // essa variável é pra quando a sheet for aberta direto da view de um livro
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
                            //bookPickerSection
                            selectedImagePreview
                            mediaSection
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 18)
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
            .navigationBarTitleDisplayMode(.inline)
            
            
            .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
                Button("Tentar novamente", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: selectedItems) { newItems in
                loadPickedItems(newItems)
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $capturedImage)
                    .ignoresSafeArea()
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedItems,
                maxSelectionCount: 3 - selectedImages.count,
                matching: .images
            )
            .onChange(of: capturedImage) { newImage in
                appendCapturedImage(newImage)
            }
        }
    }
    
    // MARK: - Ações
    
    private func handleConfirm() {
        do {
            try notesViewModel.addNote(
                noteTitle: titleText,
                noteDescription: noteText,
                noteCategory: selectedCategory,
                notePhotos: selectedImages.map(\.image),
                //a antiga variavel nao estava permitindo adicionar uma nota 
                to: book
            )
            
            dismiss()
            
        } catch let error as LocalizedError {
            errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
            showErrorAlert = true
        } catch {
            errorMessage = "Erro inesperado."
            showErrorAlert = true
        }
    }
    
    private func loadPickedItems(_ newItems: [PhotosPickerItem]) {
        Task {
            for item in newItems {
                guard selectedImages.count < 3 else { break }
                
                guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
                guard let uiImage = UIImage(data: data) else { continue }
                
                selectedImages.append(SelectableImage(image: uiImage))
            }
            selectedItems.removeAll()
        }
    }
    
    private func appendCapturedImage(_ newImage: UIImage?) {
        guard let newImage, selectedImages.count < 3 else { return }
        selectedImages.append(SelectableImage(image: newImage))
        capturedImage = nil
    }
    
    private func removeImage(id: UUID) {
        withAnimation {
            selectedImages.removeAll { $0.id == id }
        }
    }
    
    // MARK: - Seções (extraídas para aliviar o type-checker)
    
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
            
            
        }
    }
    
    private var titleField: some View {
//        let placeholder = Text("Adicionar título")
//            .font(.system(.body, weight: .regular))
//            .foregroundColor(.white.opacity(0.7))
        
        return TextFieldSheets(
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
    
    // depois muda pra sheet receber o livro como parâmetro
//    private var bookPickerSection: some View {
//        // valores pré-calculados fora da view builder: isso é o que mais ajuda
//        // o type-checker, já que ele não precisa inferir ternário + optional junto
//        // com os modificadores de uma vez só.
//        let bookTitle: String = selectedBook?.bookTitle ?? "Selecione um livro"
//        let bookTextColor: Color = selectedBook == nil ? .white.opacity(0.7) : .white
//        
//        return VStack(alignment: .leading, spacing: 0) {
//            Text("Livro relacionado")
//                .font(.system(.title3, weight: .medium))
//                .foregroundColor(.white)
//                .padding(.bottom, 6)
//                .padding(.leading, 4)
//            
//            Menu {
//                ForEach(booksViewModel.savedBooks, id: \.self) { book in
//                    Button(book.bookTitle ?? "Sem título") {
//                        selectedBook = book
//                    }
//                }
//            } label: {
//                HStack {
//                    Text(bookTitle)
//                        .font(.system(.body, weight: .regular))
//                        .foregroundColor(bookTextColor)
//                    
//                    Spacer()
//                    
//                    Image(systemName: "chevron.up.chevron.down")
//                        .font(.footnote.weight(.semibold))
//                        .foregroundColor(.white)
//                }
//                .padding()
//                .contentShape(Rectangle())
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.white, lineWidth: 1)
//                )
//            }
//            .buttonStyle(.plain)
//        }
//    }
    
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
            
            if !selectedImages.isEmpty {
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
                ForEach(selectedImages) { item in
                    MediaThumbnailView(image: item.image) {
                        removeImage(id: item.id)
                    }
                }
            }
        }
    }
    
    private var mediaPickerMenu: some View {
        // isolar o texto condicional (ternário + interpolação) numa constante
        // evita que o type-checker precise resolver tudo dentro do Text()
        let isLimitReached = selectedImages.count >= 3
        let mediaButtonText: String = selectedImages.isEmpty
            ? "Adicionar fotos"
            : "Adicionar mais fotos (\(selectedImages.count)/3)"
        
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
