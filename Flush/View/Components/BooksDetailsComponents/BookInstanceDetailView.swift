//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI

struct BookInstanceDetailView: View {
    var book: Books
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    
    var readingProgress: Double {
        guard book.bookTotalPages > 0 else { return 0.0 }
            let current = Double(book.bookCurrentPage)
            let total = Double(book.bookTotalPages)
            return min(max(current / total, 0.0), 1.0)
        }
        
        var formattedReadingProgress: String {
            let percentage = readingProgress * 100
            return String(format: "%.0f%%", percentage)
        }
    
    
    var body: some View {
        VStack(spacing: 16) {
            /*
            Text(book.bookTitle ?? "Título desconhecido")
                .font(.custom("Georgia", size: 32))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
             */
            
            TitleComponent(title: book.bookTitle ?? "Título desconhecido")
            
            if let coverData = photoLibraryViewModel.getCoverImage(for: book){
                Image(uiImage: coverData)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 5)
            } else{
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray2))
                    
                    Image("defaultBook")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                .frame(width: 200, height: 300)
                .shadow(radius: 5)
            }
            
//            if let coverData = book.bookCover, let uiImage = UIImage(data: coverData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 200, height: 300)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .shadow(radius: 5)
//            } else {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color(.systemGray2))
//                    
//                    Image("defaultBook")
//                        .font(.system(size: 40))
//                        .foregroundColor(.gray)
//                }
//                .frame(width: 200, height: 300)
//                .shadow(radius: 5)
//            }
            
            Text("Autor: \(book.bookAuthor ?? "Erro")")
                .font(.body)
                .foregroundColor(.white)
            
            Text("\(book.bookCategory ?? "erro")")
                .font(.system(.footnote, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                .background(Color("TagNoteColor"))
                .opacity(0.8)
                .clipShape(Capsule())
            
            VStack(spacing: 16) {
                Divider().background(Color.white.opacity(0.3))
                
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Início da leitura")
                            .font(.footnote).foregroundColor(Color("InfosDetailsView"))
                        Text("adicionar data de leitura")
                            .font(.subheadline).bold().foregroundColor(.white)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Páginas").font(.footnote).foregroundColor(Color("InfosDetailsView"))
                        Text("\(book.bookTotalPages) páginas")
                            .font(.subheadline).bold().foregroundColor(.white)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Progresso").font(.footnote)
                            .foregroundColor(Color("InfosDetailsView"))
                        Text("\(formattedReadingProgress)")
                            .font(.subheadline).bold().foregroundColor(.white)
                    }
                    Spacer()
                }
                
                Divider()
                    .background(Color("LinesColor").opacity(0.3))
            }
            .padding(.top, 8)
        }
    }
}
