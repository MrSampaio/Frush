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
    @State private var initialCoverImage: UIImage? = nil
    
    private var hasChanges: Bool {
        if let book = bookToEdit {
            let titleChanged = bookTitle != (book.bookTitle ?? "")
            let authorChanged = bookAuthor != (book.bookAuthor ?? "")
            let categoryChanged = selectedCategory != (book.bookCategory ?? "")
            let pagesChanged = bookTotalPages != (book.bookTotalPages > 0 ? String(book.bookTotalPages) : "")
            let imageChanged = photoLibraryViewModel.selectedCoverImage != initialCoverImage
            
            return titleChanged || authorChanged || categoryChanged || pagesChanged || imageChanged
        } else {
            return !bookTitle.isEmpty
                || !bookAuthor.isEmpty
                || !selectedCategory.isEmpty
                || !bookTotalPages.isEmpty
                || photoLibraryViewModel.selectedCoverImage != nil
        }
    }
    
    private var toolbarTitle: String {
        bookToEdit != nil ? "Editar livro" : "Adicionar livro"
    }
    
    @State private var showingDiscardAlert: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var bookTitle = ""
    @State private var selectedCategory: String = ""
    @State private var bookTotalPages: String = ""
    @State private var bookAuthor: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 17) {
                            
                            // Capa do livro
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
                            
                            // Detalhes do livro
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
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        SheetHeaderView(
                            title: toolbarTitle,
                            actionIcon: "checkmark",
                            hasChanges: hasChanges,
                            showingDiscardAlert: $showingDiscardAlert,
                            onCancel: { dismiss() },
                            onConfirm: {
                                handleSave()
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
                                initialCoverImage = image
                            } else {
                                photoLibraryViewModel.selectedCoverImage = nil
                                initialCoverImage = nil
                            }
                        } else {
                            photoLibraryViewModel.selectedCoverImage = nil
                            initialCoverImage = nil
                        }
                    }
                    
                    .onTapGesture {
                        #if canImport(UIKit)
                                        hideKeyboard()
                        #endif
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
        }
    }
    private func handleSave() {
        if let book = bookToEdit {
            do {
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
            } catch let error as LocalizedError {
                errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                showErrorAlert = true
            } catch {
                errorMessage = "Erro inesperado."
                showErrorAlert = true
            }
        } else {
            do {
                try booksViewModel.addBook(
                    bookTitle: bookTitle,
                    bookAuthor: bookAuthor,
                    bookCover: photoLibraryViewModel.selectedCoverImage,
                    bookCategory: selectedCategory,
                    bookTotalPages: bookTotalPages
                )
                booksViewModel.fetchBooks()
                dismiss()
            } catch let error as LocalizedError {
                errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                showErrorAlert = true
            } catch {
                errorMessage = "Erro inesperado."
                showErrorAlert = true
            }
        }
    }
}
#Preview {
    BookSheetView(bookToEdit: nil)
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}

