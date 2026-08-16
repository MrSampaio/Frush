//
//  BookView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 14/08/26.
//

import SwiftUI
import PhotosUI

struct BookView: View {
    @State private var isShowingSheet = false
    @EnvironmentObject var booksViewModel: BooksViewModel
    
//    @State var savedBooks[][books] = BooksViewModel.savedBooks
    
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Meus Livros")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Button(action: {
                    isShowingSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            //Spacer()
            
            VStack(alignment: .leading) {
                if booksViewModel.savedBooks.count > 0 {
                    ForEach(booksViewModel.savedBooks, id: \.self) { book in
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
                        
                        Divider()
                            .padding(.leading, 84)
                    }
                } else {
                    Spacer()
                    Text("Nenhum livro adicionado")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            AddBookSheetView()
        }
    }
}

#Preview {
    BookView()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}
