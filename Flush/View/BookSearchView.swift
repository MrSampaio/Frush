//
//  BookSearchView.swift
//  CH4-Books
//
//  Created by Lucas on 16/08/26.
//

import SwiftUI

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
            List {
                if !filteredBooks.isEmpty {
                    Section("Livros") {
                        ForEach(filteredBooks, id: \.self) { book in
                            Button {
                                selectedBook = book
                            } label: {
                                BookCellView(book: book)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                if !filteredNotes.isEmpty {
                    Section("Notas") {
                        ForEach(filteredNotes, id: \.self) { note in
                            Button {
                                selectedNote = note
                            } label: {
                                NoteCellView(note: note)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .overlay {
                if filteredBooks.isEmpty && filteredNotes.isEmpty {
                    ContentUnavailableView(
                        "Nenhum resultado encontrado",
                        systemImage: "magnifyingglass",
                        description: Text("Tente buscar por outro título de livro ou nota.")
                            .font(.custom("Bitter-Regular", size: 15))
                    )
                }
            }
            .navigationTitle("Buscar")
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
                BookDetailView(viewModel: booksViewModel, book: book)
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
