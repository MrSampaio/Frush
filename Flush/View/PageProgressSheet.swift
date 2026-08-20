//
//  PageProgressSheet.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//

import SwiftUI

struct PageProgressSheetView: View {
    let bookTitle: String
    let totalPages: Int
    
    @Binding var currentPage: Int
    @State private var tempPage: Int
    @State private var showAlert = false
    
    var onDismiss: () -> Void = {}
    var onSave: (Int) -> Void = { _ in }
    
    init(bookTitle: String, totalPages: Int, currentPage: Binding<Int>, onDismiss: @escaping () -> Void = {}, onSave: @escaping (Int) -> Void = { _ in }) {
        self.bookTitle = bookTitle
        self.totalPages = max(totalPages, 1)
        self._currentPage = currentPage
        self._tempPage = State(initialValue: currentPage.wrappedValue)
        self.onDismiss = onDismiss
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text("Em qual página você parou no livro")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("“\(bookTitle)”?")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                TextFieldSheets(
                    text: .constant(""),
                    placeholder: "Digite o número da página...",
                )
                .padding(.horizontal)

            }
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal, 20)
            .toolbar {
                SheetHeaderView(
                    title: "",
                    actionIcon: "checkmark",
                    showingDiscardAlert: $showAlert,
                    onCancel: { onDismiss() },
                    onConfirm: {
                        currentPage = tempPage
                        onSave(tempPage)
                        onDismiss()
                    },
                    onDiscard: { onDismiss() }
                )
            }
        }
    }
}

#Preview("Page Progress Sheet") {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        @State private var page = 42

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                Button("Abrir Mini Sheet") {
                    isPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $isPresented) {
                PageProgressSheetView(
                    bookTitle: "Hush, Hush",
                    totalPages: 384,
                    currentPage: $page,
                    onDismiss: { isPresented = false },
                    onSave: { newPage in
                        print("Nova página salva: \(newPage)")
                    }
                )
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color("BackgroundColorViews"))
            }
        }
    }

    return PreviewWrapper()
}
