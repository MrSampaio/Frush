//
//  BookCaseView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 15/08/26.
//

import SwiftUI

struct BookCaseView: View {
    //@AppStorage("dailyReadingGoal") private var goalMinutes: Int = 15
    @EnvironmentObject var bookViewModel: BooksViewModel
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    
    @State private var isShowingSheet = false
    
    @State private var selectedBookForDetail: Books? = nil
    @State private var isShowingBookDetail = false
    
    @State private var showBottomSheet: Bool = false
    
    @State private var isPresented = true
    @State private var tempGoalMinutes: Int = 15
    
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
                        
                        CardTotalPages(totalPages: bookViewModel.countGeralReadedPages())
                        
                        DailyGoalCardView(
//                            pagesReadToday: 12,
//                            targetPages: userSettingsViewModel.dailyGoal,
                            onEditAction: {
                                showBottomSheet = true
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
            withAnimation {
                bookViewModel.fetchBooks()
                userSettingsViewModel.fetchUserSettings()
                //bookViewModel.fetchDailyGoal()
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
        .sheet(isPresented: $showBottomSheet) {
            BottomSheet(
                minutesPerDay: $tempGoalMinutes,
                isPickerShown: true,
                readedPages: .constant(""),
                onDismiss: {
                    userSettingsViewModel.fetchUserSettings()
                    showBottomSheet = false
                },
                onSave: {
                    userSettingsViewModel.saveDailyGoal(minutes: tempGoalMinutes)
                    //bookViewModel.saveDailyGoal(minutes: tempGoalMinutes)
                    showBottomSheet = false
                }
            )
            .onAppear {
//                tempGoalMinutes = bookViewModel.dailyGoalMinutes
                tempGoalMinutes = userSettingsViewModel.dailyGoal
            }
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color("BackgroundColorViews"))
        }
//        .sheet(isPresented: $showBottomSheet) {
//            EditDailyGoalContent(
//                minutesPerDay: $tempGoalMinutes,
//                onDismiss: {
//                    showBottomSheet = false
//                },
//                onSave: {
//                    //bookViewModel.saveDailyGoal(minutes: goalMinutes)
//                    showBottomSheet = false
//                }
//            )
//            .presentationDetents([.height(340)])
//            .presentationDragIndicator(.visible)
//            .presentationBackground(Color("BackgroundColorViews"))
//        }
    }
}

#Preview {
    BookCaseView()
        .environmentObject(UserSettingsViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(NotesViewModel())
}
