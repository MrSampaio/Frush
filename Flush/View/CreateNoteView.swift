//
//  create-note-view.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 14/08/26.
//

import Foundation
import SwiftUI
import PhotosUI

struct CreateNoteView: View {
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    var body: some View {
        VStack {

            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                HStack {
                    Text("Adicione uma foto")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "camera")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding()
            }
            
            // Apenas para testar se a imagem foi carregada:
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            
            // Tenta converter o bookCover (Data) em UIImage para exibir a foto
//            if let coverData = book.bookCover, let uiImage = UIImage(data: coverData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 50, height: 70)
//                    .cornerRadius(8)
//                    .clipped()
//            } else {
//                // Imagem genérica caso o livro não tenha capa salva
//                Rectangle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: 50, height: 70)
//                    .cornerRadius(8)
//                    .overlay(
//                        Image(systemName: "book.closed")
//                            .foregroundColor(.gray)
//                    )
//            }
        }
    }
}

#Preview {
    CreateNoteView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}
