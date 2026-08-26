//
//  BookInstanceDetailView.swift (ATUALIZADO)
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
    
    // Formata a data de início da leitura
    var formattedReadingStartDate: String {
        guard let date = book.readingStartDate else {
            return "Ainda não iniciado"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 16) {

            TitleComponent(title: book.bookTitle ?? "Título desconhecido")
                .padding(.horizontal, 60)
                .multilineTextAlignment(.center)
            
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
            
            Text("Autor: \(book.bookAuthor ?? "Erro")")
                .font(.body)
                .foregroundColor(.white)
            
            Text("\(book.bookCategory ?? "erro")")
                .font(.system(.footnote, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.vertical, 6)
                .background(Color("TagNoteColor"))
                .opacity(0.8)
                .clipShape(Capsule())
            
            VStack(spacing: 16) {
                Divider()
                    .frame(height: 0.3)
                    .background(Color("LinesColor"))
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Início da leitura")
                            .font(.footnote)
                            .foregroundColor(Color("InfosDetailsView"))
                        
                        if book.readingStartDate != nil {
                            Text(formattedReadingStartDate)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("Texts"))
                        } else {
                            Text("Clique em 'Iniciar leitura'")
                                .fontWeight(.bold)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("InfosDetailsView"))
                        }
                    }
                    
                    Spacer()
                    
                    // SEÇÃO: Páginas Totais
                    VStack(spacing: 4) {
                        Text("Páginas")
                            .font(.footnote)
                            .foregroundColor(Color("InfosDetailsView"))
                        Text("\(book.bookTotalPages) páginas")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Texts"))

                    }
                    
                    Spacer()
                    
                    // SEÇÃO: Progresso
                    VStack(spacing: 4) {
                        Text("Progresso")
                            .font(.footnote)
                            .foregroundColor(Color("InfosDetailsView"))
                        Text("\(formattedReadingProgress)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Texts"))
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .frame(height: 0.3)
                    .background(Color("LinesColor"))
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 10)
        }
    }
}
