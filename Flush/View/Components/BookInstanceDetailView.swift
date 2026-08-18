//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI

struct BookInstanceDetailView: View {
    let book: Books
    var body: some View {
        VStack(spacing: 12) {
            Text(book.bookAuthor ?? "Autor Desconhecido")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
            
            Group {
                if let imageData = book.bookCover, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("defaultBook")
                        .resizable()
                        .scaledToFill()
                        .background(Color(uiColor: .systemGray4))
                }
            }
            .frame(width: 140, height: 210)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(book.bookTitle ?? "Sem Título")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            Text(book.bookCategory ?? "Sem categoria")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                .background(Color.indigo)
                .clipShape(Capsule())
        }
    }
}
