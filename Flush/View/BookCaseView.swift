//
//  BookCaseView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 15/08/26.
//

import SwiftUI

struct BookCaseView: View {
    @ObservedObject var bookViewModel: BooksViewModel
    @StateObject private var filterViewModel = BookFilterViewModel()
    
    @State private var isShowingSheet = false
    @State private var selectedBookForDetail: Books? = nil
    @State private var isShowingBookDetail = false
    @State private var showBottomSheet: Bool = false
    @State private var isPresented = true
    @State private var tempGoalMinutes: Int = 15
    
    var filteredBooks: [Books] {
        return filterViewModel.applyFilters(to: bookViewModel.savedBooks)
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (alignment: .leading, spacing: 24) {
                        HStack {
                            TitleComponent(title: "Meus Livros")
                        }
                        .padding(.top, 28)
                        
                        CardTotalPages(totalPages: bookViewModel.countGeralReadedPages())
                        
                        DailyGoalCardView(
                            pagesReadToday: 12,
                            targetPages: bookViewModel.dailyGoalMinutes,
                            onEditAction: {
                                showBottomSheet = true
                            }
                        )
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filteredBooks) { book in
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
                .toolbar {
                    BookCaseToolbar(
                        onAddClick: { isShowingSheet.toggle() },
                        filterViewModel: filterViewModel
                    )
                }
            }
        }
        .onAppear {
            withAnimation {
                bookViewModel.fetchBooks()
                bookViewModel.fetchDailyGoal()
            }
        }
        .sheet(isPresented: $isShowingSheet, onDismiss: {
            withAnimation{
                bookViewModel.fetchBooks()
            }
        }) {
            BookSheetView(bookToEdit: nil)
                .environmentObject(bookViewModel)
        }
        .sheet(isPresented: $showBottomSheet) {
            BottomSheet(
                minutesPerDay: $tempGoalMinutes,
                isPickerShown: true,
                readedPages: .constant(""),
                onDismiss: {
                    showBottomSheet = false
                },
                onSave: {
                    bookViewModel.saveDailyGoal(minutes: tempGoalMinutes)
                    showBottomSheet = false
                }
            )
            .onAppear {
                tempGoalMinutes = bookViewModel.dailyGoalMinutes
            }
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color("BackgroundColorViews"))
        }
    }
}
#Preview {
    BookCaseView(bookViewModel: BooksViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(NotesViewModel())
}
