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
    
    @State var book: Books?
    
    @State private var showingDiscardAlert: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var bookTitle = ""
    @State private var selectedGoal: String = ""
    @State private var selectedCategory: String = ""
    @State private var bookTotalPages: String = ""
    @State private var bookLastPage: String = ""
    @State private var bookAuthor: String = ""
    
    @ViewBuilder
    private var SelectCategoryField: some View {
        if let currentBook = book {
            MenuSheetPicker(
                    title: "Categoria",
                    placeholder: "Adicione a categoria",
                    selectedValue: Binding(
                        get: { book != nil ? (book?.bookCategory ?? "") : selectedCategory },
                        set: { newValue in
                            if book != nil { book?.bookCategory = newValue }
                            else { selectedCategory = newValue }
                        }
                    ),
                    options: booksViewModel.bookCategories
                )
        }
    }
    
    
    @ViewBuilder
    private var TitleField: some View {
        if let currentBook = book {
            TextFieldSheets(
                text: Binding(
                    get: { currentBook.bookTitle ?? "" },
                    set: { book?.bookTitle = $0 }
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
        if let currentBook = book {
            TextFieldSheets(
                text: Binding(
                    get: { currentBook.bookAuthor ?? "" },
                    set: { book?.bookAuthor = $0 }
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
        if let currentBook = book {
            TextFieldSheets(
                text: Binding(
                    get: { String(currentBook.bookTotalPages) },
                    set: { if let value = Int16($0) { book?.bookTotalPages = value } }
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
                                            if let selectedImage = photoLibraryViewModel.selectedImage {
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
                                        
                                        
                                        Image(systemName: photoLibraryViewModel.selectedImage == nil ? "plus" : "trash")
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
                            
                            if photoLibraryViewModel.selectedImage != nil {
                                Button(action: {
                                    withAnimation {
                                        photoLibraryViewModel.selectedImage = nil
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
                            title: "Cadastrar Livro",
                            actionIcon: "checkmark",
                            showingDiscardAlert: $showingDiscardAlert,
                            onCancel: {},
                            onConfirm: {
                                
                                do{
                                    let pagesInt = Int16(bookTotalPages) ?? 0
                                    
                                    let lastPageInt = Int16(bookLastPage) ?? 0
                                    
                                    let coverData = photoLibraryViewModel.selectedImage?.jpegData(compressionQuality: 0.7) ?? Data()
                                    
                                    let goalInt = Int16(selectedGoal.filter("0123456789".contains)) ?? 0
                                    
                                    try booksViewModel.addBook(
                                        bookTitle: bookTitle,
                                        bookAuthor: bookAuthor,
                                        bookCover: coverData,
                                        bookCategory: selectedCategory,
                                        bookTotalPages: pagesInt,
                                        bookCurrentPage: lastPageInt,
                                        bookGoal: goalInt
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
                        if let book = book {
                            bookTitle = book.bookTitle ?? ""
                            bookAuthor = book.bookAuthor ?? ""
                            selectedCategory = book.bookCategory ?? ""
                            bookTotalPages = book.bookTotalPages > 0 ? String(book.bookTotalPages) : ""
                            
                            if let imageData = book.bookCover, let image = UIImage(data: imageData) {
                                photoLibraryViewModel.selectedImage = image
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    BookSheetView(book: nil)
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}

