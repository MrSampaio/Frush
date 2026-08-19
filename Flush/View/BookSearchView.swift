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
                            BookCellView(book: book)
                        }
                    }
                }
                
                if !filteredNotes.isEmpty {
                    Section("Notas") {
                        ForEach(filteredNotes, id: \.self) { note in
                            NoteCellView(note: note)
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
            }
        }
    }
}



