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
    
    var book: Books? = nil
    
    private var currentBook: Books? {
        book ?? viewModel.savedBooks.first
    }
    
    var body: some View {
        ZStack {
            Color(.orange)
                .opacity(0.1)
                .ignoresSafeArea()
            
            if let currentBook = currentBook {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        HStack {
                            Spacer()
                            Button(action: {
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.orange))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        

                        BookInstanceDetailView(book: currentBook)
                        
                        ProgressBookView(
                            currentPage: Int(currentBook.bookCurrentPage),
                            totalPages: Int(currentBook.bookTotalPages)
                        )
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            NotesHeaderview()
                            NotesSectionView(notes: notesViewModel.savedNotes)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                            }) {
                                Text("Adicionar leitura")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color(red: 0.22, green: 0.20, blue: 0.16))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                            }) {
                                Text("Iniciar leitura")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(.orange))
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
