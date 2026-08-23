//
//  BookSearchView.swift
//  CH4-Books
//
//  Created by Lucas on 16/08/26.
//

import SwiftUI
import CoreData

struct BookSearchView: View {
    @EnvironmentObject var booksViewModel: BooksViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @State private var searchText = ""
    @State private var isSearchPresented = false
    @State private var selectedBook: Books?
    @State private var selectedNote: Notes?

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
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                List {
                    if !filteredBooks.isEmpty {
                        Section {
                            ForEach(filteredBooks, id: \.self) { book in
                                Button {
                                    selectedBook = book
                                } label: {
                                    BookCellView(book: book)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color("CardNoteColor"))
                            }
                        } header: {
                            Text("Livros")
                                .font(.bitter(.medium, style: .title))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("Texts"))
                        }
                        .foregroundStyle(.white)
                    }
                    
                    if !filteredNotes.isEmpty {
                        Section {
                            ForEach(filteredNotes, id: \.self) { note in
                                Button {
                                    selectedNote = note
                                } label: {
                                    NoteCellView(note: note, noteViewModel: notesViewModel)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color("CardNoteColor"))
                            }
                        } header: {
                            Text("Notas")
                                .font(.bitter(.medium, style: .title))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("Texts"))
                        }
                        .foregroundStyle(.white)
                    }
                }
                .scrollContentBackground(.hidden)
                .contentMargins(.top, 0, for: .scrollContent)
                
                .overlay {
                    if filteredBooks.isEmpty && filteredNotes.isEmpty {
                        ContentUnavailableView {
                            Text("Nenhum resultado encontrado")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("Texts"))
                            
                        } description: {
                            Text("Tente buscar por outro título de livro ou nota")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
                //.navigationTitle("Buscar")
                //.navigationBarTitleDisplayMode(.inline)
                .searchable(
                    text: $searchText,
                    isPresented: $isSearchPresented,
                    prompt: "Buscar livros ou notas"
                )
                .onAppear {
                    isSearchPresented = true
                    booksViewModel.fetchBooks()
                    notesViewModel.fetchNotes()
                }
                .sheet(item: $selectedBook, onDismiss: {
                    booksViewModel.fetchBooks()
                    notesViewModel.fetchNotes()
                }) { book in
                    BookDetailView(bookViewModel: booksViewModel, book: book)
                }
                .sheet(item: $selectedNote, onDismiss: {
                    booksViewModel.fetchBooks()
                    notesViewModel.fetchNotes()
                }) { note in
                    NoteDetailSheetView(note: note)
                }
            }
            
        }
    }
}


#Preview {
    let context = CoreDataManager.shared.viewContext
    
    let book1 = Books(context: context)
    book1.bookTitle = "Dom Casmurro"
    book1.bookAuthor = "Machado de Assis"
    book1.bookCategory = "Romance"
    book1.bookTotalPages = 256
    book1.bookCurrentPage = 120
    book1.isTimerRunning = false
    book1.wasLastPageAdded = true
    
    let book2 = Books(context: context)
    book2.bookTitle = "O Pequeno Príncipe"
    book2.bookAuthor = "Antoine de Saint-Exupéry"
    book2.bookCategory = "Infantil"
    book2.bookTotalPages = 96
    book2.bookCurrentPage = 96
    book2.isTimerRunning = false
    book2.wasLastPageAdded = true
    
    let note1 = Notes(context: context)
    note1.noteTitle = "Anotações sobre "
    note1.noteDescription = "Reflexão sobre a personagem e sua ambiguidade."
    note1.noteCategory = "Pensamento"
    note1.book = book1
    
    let note2 = Notes(context: context)
    note2.noteTitle = "Ideias para resumo"
    note2.noteDescription = "Pontos principais do capítulo 3."
    note2.noteCategory = "Resumo"
    note2.book = book2
    
    try? context.save()
    
    let booksVM = BooksViewModel()
    let notesVM = NotesViewModel()
    
    return BookSearchView()
        .environmentObject(booksVM)
        .environmentObject(notesVM)
}
