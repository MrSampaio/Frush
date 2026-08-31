//
//  BookCardView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 17/08/26.
//

import SwiftUI
import SwiftData

struct BookCardView: View {
    @Environment(\.modelContext) private var modelContext
    //nao e mais necessario observedObject
    var book: Books
    
    @State private var isEditingSheetPresented = false
    @State private var isShowingDeleteAlert = false
    
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var bookViewModel: BooksViewModel
    
    private var percentageRead: Int {
        guard book.bookTotalPages > 0 else { return 0 }
        let percentage = (Double(book.bookCurrentPage) / Double(book.bookTotalPages)) * 100.0
        return min(max(Int(percentage), 0), 100)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            if let uiImage = photoLibraryViewModel.getCoverImage(for: book) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 240)
                    .clipped()
            } else {
                Image("defaultBook")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 240)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.bookTitle ?? "Sem título")
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(alignment: .bottom) {
                    Text("\(book.bookTotalPages) páginas")
                        .font(.system(.caption, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(percentageRead)%")
                        .font(.system(.headline, weight: .bold))
                        .foregroundColor(.addNote)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
        }
        .contextMenu {
            Button() {
                isEditingSheetPresented = true
            } label: {
                Label("Editar Livro", systemImage: "pencil")
                   
                    .font(.body)
            }
            .foregroundColor(.blue)
            
            Divider()
            
            Button(role: .destructive) {
                isShowingDeleteAlert = true
            } label: {
                Label("Apagar Livro", systemImage: "trash")
                    .font(.body)
            }
            .foregroundColor(.red)
        
        }
        
        .frame(width: 170)
        .cornerRadius(12)

        
        .sheet(isPresented: $isEditingSheetPresented, onDismiss: {
            withAnimation{
                bookViewModel.fetchBooks(context: modelContext)
            }
        }) {
            BookSheetView(bookToEdit: book)
        }
        
        .alert("Apagar Livro", isPresented: $isShowingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            
            Button("Apagar", role: .destructive) {
                withAnimation {
                    do {
                        try bookViewModel.deleteBook(book: book, context: modelContext)
                    } catch {
                        print("Erro ao tentar apagar o livro: \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("Tem certeza que deseja apagar o livro '\(book.bookTitle ?? "Sem título")'? Essa ação não pode ser desfeita.")
        }
    }
}
//#Preview {
//    ZStack {
//        HStack(spacing: 16) {
//            
//            BookCardView(
//                book: PreviewProviderHelper.sampleBook
//            )
//        }
//    }
//}
//
