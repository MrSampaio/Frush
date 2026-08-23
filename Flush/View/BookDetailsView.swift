//
//  BookDetailView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI
import CoreData

struct BookDetailView: View {
    @ObservedObject var bookViewModel: BooksViewModel
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var isPresentedAddNote: Bool = false
    @State private var isPresentedEditBook: Bool = false
    @State private var isPresentedBottomSheet: Bool = false
    @State private var tempGoalMinutes: Int = 15
    
    @State private var tempReadedPages: String = ""
    
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
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
                    VStack() {
                        
                        BookInstanceDetailView(book: book)
                            .environmentObject(PhotoLibraryViewModel())
                            .id(book.bookCover ?? Data())
                        
                        CardTotalPages(totalPages: bookViewModel.countBookReadedPages(book: book))
                            .padding(.horizontal)
                        
                        NotesHeaderview(isPresentedAddNote: $isPresentedAddNote)
                               .padding(.horizontal, 24)
                               .padding(.top, 10)
                        

                        VStack(spacing: 16) {
                            
                               
                            VStack{
                                VStack() {
                                    NotesSectionView(notes: Array(notesViewModel.savedNotes.prefix(3))) {
                                        notesViewModel.fetchNotes(for: book)
                                    }
                                    
                                    
                                    Divider()
                                        .frame(height: 0.3)
                                        .background(Color("LinesColor"))
                                        .padding(.horizontal, 28)
                                    
                                }
<<<<<<< HEAD
                                
                                NavigationLink(destination: MyNotesListView(book: currentBook)) {
                                    Text(notesViewModel.savedNotes.isEmpty ? "Ver anotações" : "Ver mais anotações...")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(.action))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal,28)
                                        .padding(.vertical)
                                        .padding(.bottom, 10)
                                }
                                
=======
>>>>>>> dev
                            }
                            
//                            NotesSectionView(notes: Array(notesViewModel.savedNotes.prefix(3))) {
//                                notesViewModel.fetchNotes(for: book)
//                            }
//                            
//                            NavigationLink(destination: MyNotesListView(book: book)) {
//                                    Text(notesViewModel.savedNotes.isEmpty ? "Ver anotações" : "Ver mais anotações...")
//                                        .font(.system(size: 14, weight: .semibold))
//                                        .foregroundColor(Color(.action))
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        .padding(.horizontal,28)
//                                        .padding(.vertical)
//                                        .padding(.bottom, 10)
//                                }
//                                
//                            }
//                            .background(Color("CardNoteColor"))
//                            .cornerRadius(30)
//                            .padding(.horizontal)
                            
                            NavigationLink(destination: MyNotesListView(book: book)) {
                                
//                                Text(notesViewModel.savedNotes.isEmpty ? "Ver anotações" : "Ver todas as anotações")
                                Text(notesViewModel.savedNotes.isEmpty ? "Ver anotações" : "Ver mais anotações...")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(.action))
                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.horizontal)
                                    .padding(.horizontal,28)
                                    .padding(.vertical)
                                    .padding(.bottom, 10)
                            }
                            
                        }
                        .background(Color("CardNoteColor"))
                        .cornerRadius(30)
                        .padding(.horizontal)
                        VStack(spacing: 16) {
                            /*
                            Button(action: {
                            }) {
                                Text("Adicionar leitura")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(.glass)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                             */
                            
                            
                            ButtonAction(text: "Adicionar leitura", isGlass: true) {
                                isPresentedBottomSheet.toggle()
                            }
                            .buttonStyle(.glass)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            
                            // Button preenchido com cor
                            ButtonAction(text: "Iniciar leitura", colorButton: "ActionColor")
                                .padding(.horizontal, 24)
                        }
       
                        
                    }
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                notesViewModel.fetchNotes(for: book)
            }
            .onDisappear {
                bookViewModel.fetchBooks()
            }
            .sheet(isPresented: $isPresentedAddNote, onDismiss: {
                notesViewModel.fetchNotes(for: book)
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
                            try bookViewModel.updateCurrentPage(book: book, currentPage: tempReadedPages)
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
                    tempGoalMinutes = bookViewModel.dailyGoalMinutes
                    tempReadedPages = ""
                }
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color("BackgroundColorViews"))
            }
            .sheet(isPresented: $isPresentedEditBook, onDismiss: {
                bookViewModel.fetchBooks()
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
        }
    }
}
//#Preview {
//    BookDetailView(bookViewModel: BooksViewModel())
//        .environmentObject(PhotoLibraryViewModel())
//        .environmentObject(NotesViewModel())
//}
