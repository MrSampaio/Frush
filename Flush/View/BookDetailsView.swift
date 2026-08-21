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
                        VStack{
                            
                            BookInstanceDetailView(book: currentBook)
                                .environmentObject(PhotoLibraryViewModel())
                                .id(currentBook.bookCover ?? Data())
                            
                            CardTotalPages(totalPages: 100)
                                .padding(.horizontal)
                            
                            NotesHeaderview(isPresentedAddNote: $isPresentedAddNote)
                                .padding(.horizontal, 24)
                                .padding(.top, 10)
                            
                            VStack{
                                VStack() {
                                    NotesSectionView(notes: Array(notesViewModel.savedNotes.prefix(3))) {
                                        notesViewModel.fetchNotes(for: currentBook)
                                    }
                                    
                                    
                                    Divider()
                                        .frame(height: 0.3)
                                        .background(Color("LinesColor"))
                                        .padding(.horizontal, 28)
                                    
                                }
                                NavigationLink(destination: MyNotesListView(book: currentBook)) {
                                    Text(notesViewModel.savedNotes.isEmpty ? "Ver anotações" : "Ver mais anotações...")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(.action))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal,28)
                                        .padding(.vertical)
                                        .padding(.bottom, 10)
                                }
                                
                            }
                            .background(Color("CardNoteColor"))
                            .cornerRadius(30)
                            .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                
                                ButtonAction(text: "Adicionar leitura", isGlass: true) {
                                    //print("Excluído")
                                }
                                .buttonStyle(.glass)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                                
                                // Button preenchido com cor
                                ButtonAction(text: "Iniciar leitura", colorButton: "ActionColor")
                                    .padding(.horizontal, 24)
                                
                            }
           
                            
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 10)
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
//            .sheet(isPresented: $isPresentedAddNote, onDismiss: {
//                notesViewModel.fetchNotes(for: currentBook)
//            }) {
//                if let currentBook {
//                    NoteSheetView(book: currentBook)
//                        .environmentObject(notesViewModel)
//                }
//            }
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
