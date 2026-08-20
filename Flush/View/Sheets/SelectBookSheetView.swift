//
//  SelectBookSheetView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI
import CoreData

struct SelectBookSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var booksViewModel: BooksViewModel
    
    // Binding do livro selecionado enviado de volta para a view chamadora
    @Binding var selectedBook: Books?
    
    @State private var showingDiscardAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(booksViewModel.savedBooks, id: \.objectID) { book in
                            let isSelected = selectedBook == book
                            
                            Button(action: {
                                selectedBook = book
                                dismiss()
                            }) {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text(book.bookTitle ?? "Sem título")
                                            .font(.body)
                                            .fontWeight(isSelected ? .semibold : .regular)
                                            .foregroundColor(isSelected ? Color("ActionColor") : Color("Texts"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                                    }

                                    Rectangle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 1)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 14)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                SheetHeaderView(
                    title: "Livros salvos",
                    actionIcon: "checkmark",
                    hasChanges: false,
                    showingDiscardAlert: $showingDiscardAlert,
                    onCancel: { dismiss() },
                    onConfirm: { dismiss() },
                    onDiscard: { dismiss() }
                )
            }
            .onAppear {
                booksViewModel.fetchBooks()
            }
        }
    }
}

#Preview {
    SelectBookSheetView(selectedBook: .constant(nil))
        .environmentObject(BooksViewModel())
}
