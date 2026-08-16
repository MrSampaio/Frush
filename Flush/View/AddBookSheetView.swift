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
            ScrollView {
                VStack(spacing: 16) {
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
                    
                    TextField("Título", text: $bookTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Autor(a)", text: $bookAuthor)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
//                    TextField("Categoria", text: .constant(""))
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.horizontal)
                    
                    Menu {
                        ForEach(booksViewModel.bookCategories, id: \.self) { option in
                            Button(option) {
                                selectedCategory = option
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory.isEmpty ? "Categoria do livro" : selectedCategory)
                                .foregroundColor(selectedCategory.isEmpty ? Color(uiColor: .placeholderText) : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)

                    
                    TextField("Páginas totais", text: $bookTotalPages)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .keyboardType(.numberPad)
                    
                    TextField("Última página lida", text: $bookLastPage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .keyboardType(.numberPad)
                    
                    Menu {
                        ForEach(booksViewModel.goalOptions, id: \.self) { option in
                            Button(option) {
                                selectedGoal = option
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedGoal.isEmpty ? "Objetivo diário (minutos)" : selectedGoal)
                                .foregroundColor(selectedGoal.isEmpty ? Color(uiColor: .placeholderText) : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                SheetHeaderView(
                    title: "Cadastrar Livro",
                    actionIcon: "checkmark",
                    showingDiscardAlert: $showingDiscardAlert,
                    onCancel: {},
                    onConfirm: {
                        
//                        booksViewModel.addBook(bookTitle: bookTitle, bookAuthor: <#T##String#>, bookCover: <#T##Data#>, bookCategory: <#T##String#>, bookTotalPages: <#T##Int16#>, bookCurrentPage: <#T##Int16#>, bookGoal: <#T##Int16#>, isTimerRunning: <#T##Bool#>, wasLastPageAdded: <#T##Bool#>)
                        
                        do{
                            let pagesInt = Int16(bookTotalPages) ?? 0
                            
                            let lastPageInt = Int16(bookLastPage) ?? 0
                            
                            let coverData = photoLibraryViewModel.selectedImage?.jpegData(compressionQuality: 0.8) ?? Data()

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

#Preview {
    AddBookSheetView()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}

