//
//  NoteCardView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 18/08/26.
//

import SwiftUI

struct NotesCardView: View {
    let imageName: UIImage?
    let tagText: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            //if let imageName = UIImage {
                
                if let image = imageName {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 120)
                        .cornerRadius(16)
                        .clipped()
                    //                Image(uiImage: imageName)
                    //                    .resizable()
                    //                    .scaledToFill()
                    //                    .frame(width: 90, height: 120)
                    //                    .cornerRadius(16)
                    //                    .clipped()
                    
                    
                }
            else{
                Image("defaultBook")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 120)
                    .cornerRadius(16)
                    .clipped()
            }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Color("Texts").opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: {
                    //acao
                }) {
                    Image(systemName: "chevron.forward")
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .padding(.trailing, 6)
            }
                .padding(16)
                .background(Color("CardNoteColor"))
                .cornerRadius(20)
        }
    }

//#Preview {
//    NotesCardView(
//        imageName: "defaultBook",
//        tagText: "Referência",
//        title: "Título da nota",
//        description: "Descrição inicial da primeira..."
//    )
//}
