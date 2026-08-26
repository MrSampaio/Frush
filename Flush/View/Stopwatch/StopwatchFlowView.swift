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
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85),
                               value: stopwatchViewModel.timerState)
        .onAppear {
                userSettingsViewModel.fetchUserSettings(context: modelContext)
                
                if selectedBook == nil {
                    selectedBook = userSettingsViewModel.lastBookReaded
                }
        }
        .sheet(isPresented: $stopwatchViewModel.showProgressSheet) {
            BottomSheet(
                minutesPerDay: .constant(0),
                isPickerShown: false,
                maxPages: selectedBook?.bookTotalPages,
                readedPages: $tempReadedPages,
                onDismiss: {
                    tempReadedPages = ""
                    stopwatchViewModel.showProgressSheet = false
                    stopwatchViewModel.abandonTimer()
                },
                onSave: {
                    let book = selectedBook ?? userSettingsViewModel.lastBookReaded
                    
                    guard let currentBook = book else {
                        tempReadedPages = ""
                        stopwatchViewModel.showProgressSheet = false
                        stopwatchViewModel.abandonTimer()
                        return
                    }
                    
                    do {
                        try booksViewModel.updateCurrentPage(
                            book: currentBook,
                            currentPage: tempReadedPages,
                            context: modelContext
                        )
                        // grava a data de início apenas na primeira página registrada
                        try booksViewModel.markReadingStartDate(for: currentBook, context: modelContext)
                    } catch let error as LocalizedError {
                        errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                        showErrorAlert = true
                        return          // mantém a sheet aberta para o usuário corrigir
                    } catch {
                        errorMessage = "Erro inesperado."
                        showErrorAlert = true
                        return
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
            .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
                Button("Tentar novamente", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        }
       
}
//#Preview {
//    // É necessário criar uma estrutura de envoltório (wrapper)
//    // porque `Namespace` precisa ser criado como uma @Namespace property.
//    struct PreviewWrapper: View {
//        @Namespace var namespace
//
//        // Estado local para o livro selecionado
//        @State private var mockBook: Books? = nil
//
//        // Instanciando as ViewModels
//        @StateObject private var mockStopwatchViewModel = StopwatchViewModel()
//        @StateObject private var mockBooksViewModel = BooksViewModel()
//        @StateObject private var mockUserSettingsViewModel = UserSettingsViewModel()
//
//        var body: some View {
//            StopwatchFlowView(
//                namespace: namespace,
//                selectedBook: $mockBook
//            )
//            // Injetando as ViewModels no ambiente (Environment)
//            .environmentObject(mockStopwatchViewModel)
//            .environmentObject(mockBooksViewModel)
//            .environmentObject(mockUserSettingsViewModel)
//            // Caso suas ViewModels dependam de persistência nativa do SwiftData:
//            // .modelContainer(for: [Books.self, UserSettings.self], inMemory: true)
//        }
//    }
//}
//
