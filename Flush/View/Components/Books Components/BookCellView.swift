//
//  BookCellView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct BookCellView: View {
    let book: Books
    
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
                    .font(.custom("Bitter-SemiBold", size: 17))
                    .lineLimit(2)
                
                Text(book.bookAuthor ?? "Desconhecido")
                    .font(.custom("Bitter-Regular", size: 15))
                    .foregroundStyle(.secondary)
                
                Spacer(minLength: 0)
                
                Gauge(value: Double(book.bookCurrentPage), in: 0...Double(max(1, book.bookTotalPages))) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(book.bookCurrentPage)/\(book.bookTotalPages)")
                        // Substituindo .caption2.weight(.medium)
                        .font(.custom("Bitter-Medium", size: 12))
                        .foregroundStyle(.tertiary)
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(.blue)
            }
            .padding(.vertical, 4)
        }
    }
}

