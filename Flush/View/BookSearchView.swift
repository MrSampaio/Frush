//
//  BookSearchView.swift
//  CH4-Books
//
//  Created by Lucas on 16/08/26.
//

import SwiftUI

struct BookSearchView: View {
    @EnvironmentObject var booksViewModel: BooksViewModel
    @State private var searchText = ""
    @State private var isSearchPresented = false
    //depois colocar na booksViewModel
    var filteredBooks: [Books] {
        if searchText.isEmpty {
            return booksViewModel.savedBooks
        } else {
            return booksViewModel.savedBooks.filter { book in
                book.bookTitle?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredBooks, id: \.self) { book in
                HStack(spacing: 16) {
                    if let coverData = book.bookCover, let uiImage = UIImage(data: coverData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image("defaultBook")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 90)
                            .background(Color(uiColor: .systemGray4))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.bookTitle ?? "Sem Título")
                            .font(.headline)
                            .lineLimit(2)
                        
                        Text(book.bookAuthor ?? "Desconhecido")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(book.bookCurrentPage) / \(book.bookTotalPages) páginas")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .overlay {
                if filteredBooks.isEmpty {
                    ContentUnavailableView(
                        "Nenhum livro encontrado",
                        systemImage: "magnifyingglass",
                        description: Text("Tente buscar por outro título ou autor.")
                    )
                }
            }
            .navigationTitle("Buscar")
            .searchable(
                text: $searchText,
                isPresented: $isSearchPresented,
                prompt: "Buscar por título"
            )
            .onAppear {
                isSearchPresented = true
            }
        }
    }
}
