//
//  AddBookSheetView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 15/08/26.
//

import Foundation
import SwiftUI
import PhotosUI

struct AddBookSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    
    @State private var showingDiscardAlert: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var bookTitle = ""
    @State private var selectedGoal: String = ""
    @State private var selectedCategory: String = ""
    @State private var bookTotalPages: String = ""
    @State private var bookLastPage: String = ""
    @State private var bookAuthor: String = ""
    
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
                                                    .frame(width: 150, height: 210)
                                                    .background(Color(uiColor: .systemGray4))
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                            }
                                        }
                                        
                                        Image(systemName: photoLibraryViewModel.selectedImage == nil ? "plus" : "pencil")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(Color.black)
                                            .clipShape(Circle())
                                            .offset(x: 12, y: 12)
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
                            TextFieldSheets(text: $bookTitle, placeholder: "Adicionar título", label: "Título")
                            
                            MenuSheetPicker(
                                title: "Categoria",
                                placeholder: "Categoria do livro",
                                selectedValue: $selectedCategory,
                                options: booksViewModel.bookCategories
                            )
                        
                            TextFieldSheets(text: $bookTotalPages, placeholder: "Páginas totais", label: "Páginas")
                                .keyboardType(.numberPad)
                            
                            TextFieldSheets(text: $bookAuthor, placeholder: "Adicionar autor(a)", label: "Autor(a)")
                            
                            TextFieldSheets(text: $bookLastPage, placeholder: "Exemplo: 125", label: "Última página lida")
                                .keyboardType(.numberPad)
                            
                            MenuSheetPicker(
                                title: "Objetivo diário",
                                placeholder: "Objetivo diário (minutos)",
                                selectedValue: $selectedGoal,
                                options: booksViewModel.goalOptions,
                                formatOption: { "\($0) minutos" }
                            )
                            
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
                                    
                                    let coverData = photoLibraryViewModel.selectedImage?.jpegData(compressionQuality: 1) ?? Data()
                                    
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
                }
            }
        }
    }
}

#Preview {
    AddBookSheetView()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}

