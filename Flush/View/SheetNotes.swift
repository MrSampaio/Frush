//
//  SheetNotes.swift
//  CH4-Books
//
//  Created by Lucas on 14/08/26.
//

import SwiftUI
import PhotosUI

struct SheetNotes: View {
    @State private var titleText: String = ""
    @State private var noteText: String = ""
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @State var image: UIImage? = nil
    //descomentar e adicionar em to: book
    //var book: Books
    @State private var selectedCategory: String = ""
    
    var body: some View {
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                //aqui e o teste
                NavigationBarView()
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        TextField("", text: $titleText, prompt: Text("Adicionar título")
                            .font(.system(.body, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                        )
                            .foregroundStyle(.white)
                            .padding()
                            .font(.system(.body, weight: .regular))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            
                        
                        ZStack(alignment: .topLeading) {
                            if noteText.isEmpty {
                                Text("Escreva sua nota...")
                                    .foregroundColor(.white.opacity(0.7))
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
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
             
                        
                        if let selectedImage = photoLibraryViewModel.selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(10)
                        }
                        
                        PhotosPicker(selection: $photoLibraryViewModel.selectedItem, matching: .images, photoLibrary: .shared()) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                    .foregroundColor(Color("AddNoteImage"))
                                
                                Text(photoLibraryViewModel.selectedImage == nil ? "Adicionar foto" : "Trocar foto")
                                    .foregroundColor(Color("AddNoteImage"))
                                    .font(.system(.body, weight: .regular))
                                
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("AddNoteImage"))
                            }
                            .padding()
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .foregroundColor(.primary)
                        }
                        
                        /* CATEGORIAS ANTIGAS
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Escolher categoria")
                                .padding(.leading, 4)
                                .font(.system(.title3, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.bottom, 6)
                            
                            VStack(spacing: 0) {
                                CategoryRow(title: "Categoria 1", hasDivider: true)
                                CategoryRow(title: "Categoria 2", hasDivider: true)
                                CategoryRow(title: "Categoria 3", hasDivider: false)
                            }
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            
                        }*/
                        CategoryMenuView(title: "Escolher categoria", selectedCategory: $selectedCategory)
                    }
                    .padding(.horizontal)
                }
                
                /* BOTAO DE ADICIONAR NOTA ANTIGO
                Button(action: {
                    //codigo que seleciona o primeiro livro do banco
                    guard let book = booksViewModel.savedBooks.count > 0
                                ? booksViewModel.savedBooks[1]
                                : booksViewModel.savedBooks.first else {
                            print("Nenhum livro disponível no banco!")
                            return
                        }
                            notesViewModel.addNote(
                                noteTitle: titleText,
                                noteDescription: noteText,
                                noteCategory: "Teste",
                                notePhoto: "foto_teste.jpg",
                                to: book
                            )
                }) {
                    Text("Adicionar nota")
                        .font(.system(.title3, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("ActionColor"))
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                 */
            }
        }
    }
}

#Preview {
    SheetNotes()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(NotesViewModel())
}
