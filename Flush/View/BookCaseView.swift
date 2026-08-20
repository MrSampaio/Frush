//
//  BookCaseView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 15/08/26.
//

import SwiftUI

struct BookCaseView: View {
    @ObservedObject var booksViewModel: BooksViewModel
    @State private var isShowingSheet = false
    
    @State private var selectedBookForDetail: Books? = nil
    @State private var isShowingBookDetail = false
    
    
    var books: [Books] {
        booksViewModel.savedBooks
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    
    //@State var books = self.booksViewModel.savedBooks
    
    var body: some View {
        
        NavigationStack{
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (alignment: .leading, spacing: 24) {
                        //título e botão "+"
                        HStack {
                            TitleComponent(title: "Meus Livros")
                            
                            
    //                        Spacer()
    //
    //                        Button(action: {
    //                            // Ação do botão
    //                        }) {
    //                            Image(systemName: "plus")
    //                                .font(.system(.title, weight: .semibold))
    //                                .foregroundStyle(Color("TitleColor"))
    //                                .frame(width: 48, height: 48)
    //                                .background(Color.black.opacity(0.3), in: Circle())
    //                        }
    //                        .glassEffect(.regular, in: Circle())
                            
                                
                        }
                        .padding(.top, 28)
                        
                        CardTotalPages(totalPages: booksViewModel.countReadedPages())
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(books) { book in
                                NavigationLink(destination: BookDetailView(viewModel: booksViewModel, book: book)){
                                    BookCardView(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                //.navigationTitle("Meus livros")
                //.navigationBarTitleDisplayMode(.large)
                .toolbar {
                    BookCaseToolbar(onAddClick: {
                        isShowingSheet.toggle()
                    })
                }
            }
        }
//        .fakeSheet(isPresented: $isShowingBookDetail) {
//            if let selectedBookForDetail {
//                BookDetailView(viewModel: booksViewModel, book: selectedBookForDetail)
//            }
//        }
        .sheet(isPresented: $isShowingSheet, onDismiss: {
            booksViewModel.fetchBooks()
        }) {
            BookSheetView(bookToEdit: nil)
                .environmentObject(PhotoLibraryViewModel())
                .environmentObject(BooksViewModel())
                
        }
    }
}

#Preview {
    BookCaseView(booksViewModel: BooksViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}
