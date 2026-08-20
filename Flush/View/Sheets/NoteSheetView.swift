//
//  NoteSheetView.swift
//  CH4-Books
//
//  Created by Lucas on 14/08/26.
//

import SwiftUI
import PhotosUI
import CoreData

struct NoteSheetView: View {

    // MARK: - Ambiente
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notesViewModel: NotesViewModel

    // MARK: - Entradas
    let book: Books
    let noteToEdit: Notes?

    @State private var noteTitle: String
    @State private var noteDescription: String
    @State private var noteImages: [SelectableImage]
    @State private var selectedCategory: String

    // MARK: - Fluxo de mídia
    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCamera = false

    // MARK: - Alertas
    @State private var showingDiscardAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private static let maxImages = 3

    // MARK: - Init
    init(book: Books, noteToEdit: Notes? = nil) {
        self.book = book
        self.noteToEdit = noteToEdit

        _noteTitle = State(initialValue: noteToEdit?.noteTitle ?? "")
        _noteDescription = State(initialValue: noteToEdit?.noteDescription ?? "")
        _selectedCategory = State(initialValue: noteToEdit?.noteCategory ?? "")

        let existingImages = ((noteToEdit?.notePhoto as? [Data]) ?? [])
            .compactMap { UIImage(data: $0) }
            .prefix(Self.maxImages)
            .map { SelectableImage(image: $0) }

        _noteImages = State(initialValue: Array(existingImages))
    }

    private var toolbarTitle: String {
        noteToEdit != nil ? "Editar nota" : "Adicionar nota"
    }

    private var isLimitReached: Bool {
        noteImages.count >= Self.maxImages
    }

    private var remainingSlots: Int {
        max(1, Self.maxImages - noteImages.count)
    }

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 17) {
                        noteContentHeader
                        titleField
                        noteTextEditor
                        mediaSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
                    Button("Tentar novamente", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                SheetHeaderView(
                    title: toolbarTitle,
                    actionIcon: "checkmark",
                    showingDiscardAlert: $showingDiscardAlert,
                    onCancel: {
                        hideKeyboard()
                        dismiss()
                    },
                    onConfirm: handleConfirm,
                    onDiscard: {
                        hideKeyboard()
                        dismiss()
                    }
                )
            }

            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraPicker { image in
                    appendImage(image)
                }
                .ignoresSafeArea()
            }
        }
    }

    // MARK: - Cabeçalho
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

    // MARK: - Mídia
    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            if !noteImages.isEmpty {
                mediaThumbnailsRow
            }

            mediaSourceMenu

            TipsComponent(
                content: "Você pode adicionar até 3 fotos em uma mesma nota."
            )
        }
        .photosPicker(
            isPresented: $isShowingPhotoPicker,
            selection: $pickedItems,
            maxSelectionCount: remainingSlots,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: pickedItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            Task { await loadPickedItems(newItems) }
        }
    }

    private var mediaThumbnailsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(noteImages) { item in
                    MediaThumbnailView(image: item.image) {
                        noteImages.removeAll { $0.id == item.id }
                    }
                }
            }
        }
    }
    
    private var mediaSourceMenu: some View {
        Menu {
            Button {
                isShowingCamera = true
            } label: {
                Label("Tirar foto", systemImage: "camera")
            }
            .disabled(!isCameraAvailable)

            Button {
                isShowingPhotoPicker = true
            } label: {
                Label("Escolher da galeria", systemImage: "photo.on.rectangle")
            }
        } label: {
            HStack {
                Image(systemName: "camera.viewfinder")

                Text(mediaButtonText)
                    .font(.system(.body, weight: .regular))

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote.weight(.semibold))
            }
            .foregroundColor(Color("AddNoteImage"))
            .padding()
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color("LinesColor"), lineWidth: 0.5)
            )
        }
        .menuOrder(.fixed)
        .buttonStyle(.plain)
        .disabled(isLimitReached)
        .opacity(isLimitReached ? 0.5 : 1.0)
    }

    private var mediaButtonText: String {
        if noteImages.isEmpty {
            return "Adicionar fotos"
        } else {
            return "Adicionar mais fotos (\(noteImages.count)/\(Self.maxImages))"
        }
    }

    // MARK: - Ações de mídia
    @MainActor
    private func loadPickedItems(_ items: [PhotosPickerItem]) async {
        for item in items {
            guard noteImages.count < Self.maxImages else { break }
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { continue }

            noteImages.append(SelectableImage(image: image))
        }
        pickedItems.removeAll()
    }

    private func appendImage(_ image: UIImage?) {
        guard let image, noteImages.count < Self.maxImages else { return }
        noteImages.append(SelectableImage(image: image))
    }

    // MARK: - Salvar
    private func handleConfirm() {
        hideKeyboard()

        do {
            if let note = noteToEdit {
                try notesViewModel.updateNote(
                    note: note,
                    noteTitle: noteTitle,
                    noteDescription: noteDescription,
                    notePhotos: noteImages.map(\.image)
                )
            } else {
                try notesViewModel.addNote(
                    noteTitle: noteTitle,
                    noteDescription: noteDescription,
                    noteCategory: selectedCategory,
                    notePhotos: noteImages.map(\.image),
                    to: book
                )
            }

            notesViewModel.fetchNotes(for: book)
            dismiss()

        } catch let error as LocalizedError {
            errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
            showErrorAlert = true
        } catch {
            errorMessage = "Erro inesperado."
            showErrorAlert = true
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview {
    NoteSheetView(book: PreviewProviderHelper.sampleBook)
        .environmentObject(NotesViewModel())
}
