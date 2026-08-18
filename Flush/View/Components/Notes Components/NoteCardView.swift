//
//  NoteCardView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 18/08/26.
//

import SwiftUI

struct NotesCardView: View {
    let imageName: String
    let tagText: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 95)
                .cornerRadius(16)
                .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(tagText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color("TagNoteColor"))
                    .clipShape(Capsule())
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color("CardNoteColor"))
        .cornerRadius(20)
    }
}

#Preview {
    NotesCardView(
        imageName: "defaultBook",
        tagText: "Referência",
        title: "Título da nota",
        description: "Descrição inicial da primeira..."
    )
}
