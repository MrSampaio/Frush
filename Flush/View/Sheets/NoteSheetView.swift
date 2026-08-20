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
        
        return Menu {
            Button {
                // Ação da Câmera (ajuste com a sua flag/método)
                showCameraPicker = true
            } label: {
                Label("Tirar Foto", systemImage: "camera")
            }
            
            Button {
                // Ação da Galeria (ajuste com a sua flag/método)
                //showPhotoLibraryPicker = true
            } label: {
                Label("Escolher da Biblioteca", systemImage: "photo.on.rectangle")
            }
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
