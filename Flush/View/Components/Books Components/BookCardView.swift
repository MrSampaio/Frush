//
//  BookCardView.swift
//  CH4-Books
//
//  Created by Julio on 17/08/26.
//
import SwiftUI
import PhotosUI
import CoreData

struct BookCardView: View {
    let book: Books
//    let title: String
//    let totalPages: Int
//    let percentageRead: Int
//    let coverImage: String
    
    private var coverUIImage: UIImage? {
        if let imageData = book.value(forKey: "bookImage") as? Data,
           let uiImage = UIImage(data: imageData) {
            return uiImage
        }
        
        if let imageName = book.value(forKey: "bookCover") as? String,
           !imageName.isEmpty {
            return UIImage(named: imageName)
        }
        
        return nil
    }
        
//    private var percentageRead: Int {
//        guard book.bookTotalPages > 0 else { return 0 }
//        let percentage = (Double(book.bookCurrentPage) / Double(book.bookTotalPages)) * 100.0
//        return min(max(Int(percentage), 0), 100)
//    }
    
    
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
            
            if let uiImage = coverUIImage {
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
                    
                    Text("\(book.bookCurrentPage)%")
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
