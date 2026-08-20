//
//  BookCaseView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 15/08/26.
//

import SwiftUI

struct BookCaseView: View {
    @ObservedObject var bookViewModel: BooksViewModel
    @State private var isShowingSheet = false
    
    @State private var selectedBookForDetail: Books? = nil
    @State private var isShowingBookDetail = false
    
    
    var books: [Books] {
        bookViewModel.savedBooks
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
                                
                        }
                        .padding(.top, 28)
                        
                        CardTotalPages(totalPages: bookViewModel.countReadedPages())
                        
                        DailyGoalCardView(
                            pagesReadToday: 12,
                            targetPages: 30,
                            onEditAction: {
                                print("Editar meta clicado")
                            }
                        )
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(books) { book in
                                NavigationLink(destination: BookDetailView(bookViewModel: bookViewModel, book: book)){
                                    BookCardView(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .environmentObject(bookViewModel)
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
        .onAppear {
            withAnimation{
                bookViewModel.fetchBooks()
            }
        }
//        .fakeSheet(isPresented: $isShowingBookDetail) {
//            if let selectedBookForDetail {
//                BookDetailView(viewModel: booksViewModel, book: selectedBookForDetail)
//            }
//        }
        .sheet(isPresented: $isShowingSheet, onDismiss: {
            withAnimation{
                bookViewModel.fetchBooks()
            }
            
        }) {
            BookSheetView(bookToEdit: nil)
                .environmentObject(PhotoLibraryViewModel())
                .environmentObject(bookViewModel)
                
        }
    }
}

#Preview {
    BookCaseView(bookViewModel: BooksViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}
