//
//  BookCellView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct BookCellView: View {
    let book: Books
    var isSelected: Bool = false 
    
    var progress: Double {
        guard book.bookTotalPages > 0 else { return 0 }
        return min(1, Double(book.bookCurrentPage) / Double(book.bookTotalPages))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let coverData = book.bookCover, let uiImage = UIImage(data: coverData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("defaultBook")
                        .resizable()
                        .scaledToFill()
                        .background(Color(uiColor: .systemGray5))
                }
            }
            .frame(width: 55, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.bookTitle ?? "Sem Título")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                    .foregroundStyle(isSelected ? Color("ActionColor") : .white)
                    .lineLimit(1)
                
                Text(book.bookAuthor ?? "Desconhecido")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.7))
                
                Spacer(minLength: 0)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
    }
}
