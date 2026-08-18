//
//  BookCardView.swift
//  CH4-Books
//
//  Created by Julio on 17/08/26.
//
import SwiftUI

struct BookCardView: View {
    let title: String
    let totalPages: Int
    let percentageRead: Int
    let coverImage: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
//            if let coverImage = coverImage {
//                Image(uiImage: coverImage)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 160, height: 240)
//                    .clipped()
//            } else {
//               
//                Rectangle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: 160, height: 240)
//                    .overlay(
//                        Image(systemName: "book.closed")
//                            .font(.largeTitle)
//                            .foregroundColor(.white.opacity(0.5))
//                    )
//            }
            
            Image(coverImage)
                .resizable()
                .scaledToFill()
                .frame(width: 170, height: 240)
                .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(alignment: .bottom) {
                    Text("\(totalPages) páginas")
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
        .frame(width: 170)
        //.frame(height: .infinity)
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        HStack(spacing: 16) {
            BookCardView(
                title: "A metamorfose",
                totalPages: 300,
                percentageRead: 60,
                coverImage: "bookTest"
            )
        }
    }
}

