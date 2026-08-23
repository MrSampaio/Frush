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
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    @EnvironmentObject var stopwatchViewModel: StopwatchViewModel
    
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
                                userSettingsViewModel.updateUserSettings(newLastBook: book)
                                userSettingsViewModel.fetchUserSettings()
                                
                                stopwatchViewModel.getTotalPages(book: book)
                                stopwatchViewModel.getCurrentPage(book: book)
                            
                                dismiss()
                            }) {
                                VStack(spacing: 14) {
                                    HStack {
                                        BookCellView(book: book, isSelected: isSelected)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 1)
                                        .padding(.horizontal, 24)
                                }
                                .padding(.top, 14)
                                .contentShape(Rectangle())
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
            .onDisappear{
                userSettingsViewModel.fetchUserSettings()
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedBook: Books? = nil
    
    SelectBookSheetView(selectedBook: $selectedBook)
        .environmentObject(BooksViewModel())
        .environmentObject(UserSettingsViewModel())
        .environmentObject(StopwatchViewModel())
}
