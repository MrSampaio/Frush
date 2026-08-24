//
//  BookCaseView.swift (REFATORADO)
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 15/08/26.
//

import SwiftUI
import SwiftData

struct BookCaseView: View {
    @EnvironmentObject var bookViewModel: BooksViewModel
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    @EnvironmentObject var stopwatchViewModel: StopwatchViewModel
    @EnvironmentObject var filterViewModel: BookFilterViewModel
    //injetando o contexto do banco
    @Environment(\.modelContext) private var modelContext
    
    enum ActiveSheet: Identifiable {
        case addBook
        case editGoal
        
        var id: Self { self }
    }
    
    @State private var activeSheet: ActiveSheet? = nil
    
    @State private var tempGoalMinutes: Int = 15
    @State private var tempReadedPages: String = ""
    
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
                            onEditAction: {
                                activeSheet = .editGoal
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
            }
            .toolbar {
                BookCaseToolbar(onAddClick: {
                    activeSheet = .addBook
                }, filterViewModel: filterViewModel)
            }
        }
        .onAppear {
            withAnimation {
                bookViewModel.fetchBooks(context: modelContext)
                userSettingsViewModel.fetchUserSettings(context: modelContext)
            }
            
            NotificationManager.shared.requestPermission()
        }

        .sheet(item: $activeSheet, onDismiss: {
            withAnimation {
                bookViewModel.fetchBooks(context: modelContext)
                userSettingsViewModel.fetchUserSettings(context: modelContext)
            }
        }) { sheet in
            switch sheet {
            case .addBook:
                BookSheetView(bookToEdit: nil)
                    .environmentObject(PhotoLibraryViewModel())
                    .environmentObject(bookViewModel)
                
            case .editGoal:
                BottomSheet(
                    minutesPerDay: $tempGoalMinutes,
                    isPickerShown: true,
                    readedPages: .constant(""),
                    onDismiss: {
                        userSettingsViewModel.fetchUserSettings(context: modelContext)
                        activeSheet = nil
                    },
                    onSave: {
                        userSettingsViewModel.saveDailyGoal(minutes: tempGoalMinutes, context: modelContext)
                        activeSheet = nil
                    }
                )
                .onAppear {
                    tempGoalMinutes = userSettingsViewModel.dailyGoal
                }
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color("BackgroundColorViews"))
            }
        }
        
        .sheet(isPresented: $stopwatchViewModel.showProgressSheet) {
            if let currentBook = userSettingsViewModel.lastBookReaded {
                BottomSheet(
                    minutesPerDay: .constant(0),
                    isPickerShown: false,
                    readedPages: $tempReadedPages,
                    onDismiss: {
                        stopwatchViewModel.showProgressSheet = false
                    },
                    onSave: {
                        if let newPage = Int16(tempReadedPages) {
                            currentBook.bookCurrentPage = newPage
                            
                            do {
                                try bookViewModel.saveBook(context: modelContext)
                            } catch {
                                print("Error when trying to save last readed page by home: \(error)")
                            }
                        }
                        
                        let rawMinutes = Int(stopwatchViewModel.totalTime / 60)
                        let minutesRead = max(1, rawMinutes)
                        
                        userSettingsViewModel.addCompletedReadingTime(minutes: minutesRead, context: modelContext)
                        
                        bookViewModel.fetchBooks(context: modelContext)
                        userSettingsViewModel.fetchUserSettings(context: modelContext)
                        tempReadedPages = ""
                        stopwatchViewModel.showProgressSheet = false
                    }
                )
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color("BackgroundColorViews"))
            }
        }
    }
}
#Preview {
    BookCaseView()
        .environmentObject(UserSettingsViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(NotesViewModel())
        .environmentObject(StopwatchViewModel())
        .environmentObject(BookFilterViewModel())
}
