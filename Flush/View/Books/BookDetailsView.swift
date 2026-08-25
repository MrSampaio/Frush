//
//  BookDetailView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI
import SwiftData

struct BookDetailView: View {
    @ObservedObject var bookViewModel: BooksViewModel
    @ObservedObject var userSettingsViewModel = UserSettingsViewModel()
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var isPresentedAddNote: Bool = false
    @State private var isPresentedEditBook: Bool = false
    @State private var isPresentedBottomSheet: Bool = false
    @State private var tempGoalMinutes: Int = 15
    
    @State private var navigateToTimer: Bool = false
    @State private var bookForTimer: Books? = nil
    @Namespace private var stopwatchNamespace
    
    @State private var tempReadedPages: String = ""
    
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.modelContext) private var modelContext

    
    var book: Books
    
    //apagar assim que possivel
//    private var currentBook: Books {
//        book ?? bookViewModel.savedBooks.first
//    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color(.orange)
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        BookInstanceDetailView(book: book)
                            .environmentObject(PhotoLibraryViewModel())
                            .id(book.bookCover ?? Data())
                        
                        CardTotalPages(totalPages: bookViewModel.countBookReadedPages(book: book))
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            
                            ButtonAction(text: "Iniciar leitura", colorButton: "ActionColor") {
                                bookForTimer = book
                                navigateToTimer = true
                            }
//                            .padding(.top, 16)
                            .padding(.horizontal, 24)
                            
                            
                            ButtonAction(text: "Adicionar leitura", isGlass: true) {
                                isPresentedBottomSheet.toggle()
                            }
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 100, style: .continuous)
//                                    .stroke(Color.orange, lineWidth: 1)
//                            )
                            .buttonStyle(.glass)
                            .padding(.horizontal, 24)
//                            .padding(.horizontal, 24)
                            
                            
                            
                        }
//                        .padding(.bottom, 16)
                        
                        
                        NotesHeaderview(isPresentedAddNote: $isPresentedAddNote)
                               .padding(.horizontal, 24)
                               .padding(.top, 10)
                        

                        VStack() {
                            
                               
                            VStack{
                                VStack() {
                                    NotesSectionView(notes: Array(notesViewModel.savedNotes.prefix(3))) {
                                        notesViewModel.fetchNotes(for: book, context: modelContext)
                                    }
                                    Divider()
                                        .frame(height: 0.3)
                                        .background(Color("LinesColor"))
                                        .padding(.horizontal, 28)
                                    
                                }
                            }

                            
                            NavigationLink(destination: MyNotesListView(book: book)) {
                                
                                Text(notesViewModel.savedNotes.isEmpty ? "Ver anotações" : "Ver mais anotações...")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(.action))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal,28)
                                    .padding(.vertical)
                                    .padding(.bottom, 10)
                            }
                            
                        }
                        .background(Color("CardNoteColor"))
                        .cornerRadius(30)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                notesViewModel.fetchNotes(for: book, context: modelContext)
            }
            .onDisappear {
                bookViewModel.fetchBooks(context: modelContext)
            }
            .sheet(isPresented: $isPresentedAddNote, onDismiss: {
                notesViewModel.fetchNotes(for: book, context: modelContext)
            }) {
                NoteSheetView(book: book)
                    .environmentObject(notesViewModel)
            }
            
            .sheet(isPresented: $isPresentedBottomSheet) {
                BottomSheet(
                    minutesPerDay: $tempGoalMinutes,
                    isPickerShown: false,
                    readedPages: $tempReadedPages,
                    onDismiss: {
                        isPresentedBottomSheet = false
                    },
                    onSave: {
                        
                        do{
                            try bookViewModel.updateCurrentPage(book: book, currentPage: tempReadedPages, context: modelContext)
                            try bookViewModel.markReadingStartDate(for: book, context: modelContext)
                        } catch let error as LocalizedError {
                            errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                            showErrorAlert = true
                        } catch {
                            errorMessage = "Erro inesperado."
                            showErrorAlert = true
                        }
                        
                        
                        isPresentedBottomSheet = false
                    }
                )
                .onAppear {
                    tempGoalMinutes = userSettingsViewModel.dailyGoal
                    tempReadedPages = ""
                }
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color("BackgroundColorViews"))
            }
            .sheet(isPresented: $isPresentedEditBook, onDismiss: {
                bookViewModel.fetchBooks(context: modelContext)
            }){
                BookSheetView(bookToEdit: book)
                    .environmentObject(photoLibraryViewModel)
                    .environmentObject(bookViewModel)
            }
            .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
                Button("Tentar novamente", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            
            .toolbar{
                BooksDetailsToolbar(onEdit: {
                    isPresentedEditBook.toggle()
                    
                })
            }
            
            .toolbar(.hidden, for: .tabBar)
            .navigationDestination(isPresented: $navigateToTimer) {
                withAnimation {
                    StopwatchInitialView(
                        namespace: stopwatchNamespace,
                        selectedBook: $bookForTimer
                    )
                }
                
            }
        }
    }
}
//#Preview {
//    BookDetailView(bookViewModel: BooksViewModel())
//        .environmentObject(PhotoLibraryViewModel())
//        .environmentObject(NotesViewModel())
//}
