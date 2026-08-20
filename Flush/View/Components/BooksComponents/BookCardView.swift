//
//  BookCardView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 17/08/26.
//

import SwiftUI
import CoreData

struct BookCardView: View {
    @ObservedObject var book: Books
    
    @State private var isEditingSheetPresented = false
    
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
                    .foregroundColor(.blue)
                    .font(.body)
            }
            
            Divider()
            
            Button(role: .destructive) {
                //showDeleteAlert = true
            } label: {
                Label("Apagar Livro", systemImage: "trash")
                    .font(.body)
            }
        }
        .frame(width: 170)
        .cornerRadius(12)
        
        .sheet(isPresented: $isEditingSheetPresented, onDismiss: {
            bookViewModel.fetchBooks()
        }) {
            BookSheetView(bookToEdit: book)
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
