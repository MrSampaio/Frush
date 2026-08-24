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
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
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
        .sheet(isPresented: $stopwatchViewModel.showProgressSheet) {
            progressSheet
        }
        .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
            Button("Tentar novamente", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var progressSheet: some View {
        Group {
            if let currentBook = selectedBook {
                BottomSheet(
                    minutesPerDay: .constant(0),
                    isPickerShown: false,
                    readedPages: $tempReadedPages,
                    onDismiss: {
                        // descartou: o tempo de leitura é perdido
                        tempReadedPages = ""
                        stopwatchViewModel.showProgressSheet = false
                        stopwatchViewModel.abandonTimer()
                    },
                    onSave: {
                        if let newPage = Int16(tempReadedPages) {
                            currentBook.bookCurrentPage = newPage
                            
                            do {
                                try booksViewModel.saveBook(context: modelContext)
                            } catch let error as LocalizedError {
                                errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                                showErrorAlert = true
                            } catch {
                                errorMessage = "Erro inesperado."
                                showErrorAlert = true
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
}
