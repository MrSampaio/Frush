//
//  BookDetailView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI
import CoreData

struct BookDetailView: View {
    
    @ObservedObject var viewModel: BooksViewModel
    @StateObject private var notesViewModel = NotesViewModel()
    //funcoes de teste apagar assim que conseguir enviar instancia do livro
    var book: Books? = nil
    
    private var currentBook: Books? {
        book ?? viewModel.savedBooks.first
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if let currentBook = currentBook {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        HStack {
                            Spacer()
                            Button(action: {
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.tertiarySystemFill))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        //mostra informacoes sobre capa e a instancia geral do livro selecionado
                        BookInstanceDetailView(book: currentBook)
                        
                        ProgressSectionView(
                            currentPage: Int(currentBook.bookCurrentPage),
                            totalPages: Int(currentBook.bookTotalPages)
                        )
                        //Notas
                        VStack{
                            NotesHeaderview()
                            //quadro de anotacoes
                            NotesSectionView(notes: notesViewModel.savedNotes)
                        }
                        //botoes de adicao de leitura e livro

                        VStack(spacing: 16) {
                            Button(action: {
                            }) {
                                Text("Adicionar leitura")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                            }) {
                                Text("Adicionar livro")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(.systemBackground))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.primary)
                                    .cornerRadius(24)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                    }
                    .padding(.bottom, 40)
                }
            } else {
                Text("Nenhum livro encontrado.")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            notesViewModel.fetchNotes(for: currentBook)
        }
    }
}

#Preview {
    BookDetailView(viewModel: BooksViewModel())
}
