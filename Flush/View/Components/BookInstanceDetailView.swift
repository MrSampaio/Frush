//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI

struct BookInstanceDetailView: View {
    var book: Books
    
    var body: some View {
        VStack(spacing: 16) {
            // Título
            Text(book.bookTitle ?? "Título desconhecido")
                .font(.custom("Georgia", size: 32))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let coverData = book.bookCover, let uiImage = UIImage(data: coverData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 5)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.22, green: 0.20, blue: 0.16))
                    
                    Image("defaultBook")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                .frame(width: 200, height: 300)
                .shadow(radius: 5)
            }
            
            Text("Autor: \(book.bookAuthor ?? "Erro")")
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Text("Ficção")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                .background(Color(red: 0.68, green: 0.85, blue: 0.90)) // Azul claro
                .clipShape(Capsule())
            
            VStack(spacing: 16) {
                Divider().background(Color.white.opacity(0.3))
                
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Início da leitura").font(.caption).foregroundColor(.gray)
                        Text("12/08/2026").font(.subheadline).bold().foregroundColor(.white)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Páginas").font(.caption).foregroundColor(.gray)
                        Text("362 páginas").font(.subheadline).bold().foregroundColor(.white)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Progresso").font(.caption).foregroundColor(.gray)
                        Text("60%").font(.subheadline).bold().foregroundColor(.white)
                    }
                    Spacer()
                }
                
                Divider().background(Color.white.opacity(0.3))
            }
            .padding(.top, 8)
        }
    }
}
