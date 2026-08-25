//
//  StopwatchFlowView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 24/08/26.
//

import SwiftUI
import SwiftData

struct StopwatchFlowView: View {
    var namespace: Namespace.ID
    @Binding var selectedBook: Books?
    
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var stopwatchViewModel: StopwatchViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    
    @State private var tempReadedPages: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                if stopwatchViewModel.timerState == .stopped {
                    StopwatchInitialView(namespace: namespace, selectedBook: $selectedBook)
                        .transition(.opacity)
                } else {
                    StopwatchRunningView(namespace: namespace, selectedBook: $selectedBook)
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.85),
                       value: stopwatchViewModel.timerState)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85),
                               value: stopwatchViewModel.timerState)
        .sheet(isPresented: $stopwatchViewModel.showProgressSheet) {
                BottomSheet(
                            minutesPerDay: .constant(0),
                            isPickerShown: false,
                            readedPages: $tempReadedPages,
                            onDismiss: {
                                tempReadedPages = ""
                                stopwatchViewModel.showProgressSheet = false
                                stopwatchViewModel.abandonTimer()
                            },
                            onSave: {
                                let book = selectedBook ?? userSettingsViewModel.lastBookReaded
                                
                                if let currentBook = book, let newPage = Int16(tempReadedPages) {
                                    currentBook.bookCurrentPage = newPage
                                    
                                    do {
                                        try booksViewModel.saveBook(context: modelContext)
                                    } catch {
                                        print("Error when trying to save last readed page: \(error)")
                                    }
                                }
                                
                                let rawMinutes = Int(stopwatchViewModel.totalTime / 60)
                                let minutesRead = max(1, rawMinutes)
                                
                                userSettingsViewModel.addCompletedReadingTime(
                                    minutes: minutesRead,
                                    context: modelContext
                                )
                                
                                booksViewModel.fetchBooks(context: modelContext)
                                userSettingsViewModel.fetchUserSettings(context: modelContext)
                                
                                tempReadedPages = ""
                                stopwatchViewModel.showProgressSheet = false
                                stopwatchViewModel.abandonTimer()
                            }
                        )
                        .presentationDetents([.height(340)])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Color("BackgroundColorViews"))
                        
                }
        }
       
}
    
   
