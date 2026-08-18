//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI
import CoreData

import SwiftUI
import CoreData

struct NotesSectionView: View {
    var notes: [Notes]
    
    var body: some View {
        VStack(spacing: 0) {
            if notes.isEmpty {
                Text("Nenhuma anotação cadastrada.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 24)
            } else {
                ForEach(Array(notes.enumerated()), id: \.element.objectID) { index, note in
                    NoteRowView(
                        note: note,
                        isLast: index == notes.count - 1
                    )
                }
            }
        }
        //colocar cor correta
        .background(Color(.cardNote))
        .opacity(0.8)
        .cornerRadius(20)
    }
}

struct NoteRowView: View {
    var note: Notes
    var isLast: Bool
    
    private var thumbnailImage: UIImage? {
        if let photosData = note.notePhoto as? [Data], let firstData = photosData.first {
            return UIImage(data: firstData)
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Group {
                    if let image = thumbnailImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("defaultBook")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }
                }
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .clipped()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.noteTitle ?? "Sem título")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(note.noteDescription ?? "Sem conteúdo")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding()
            
            if !isLast {
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 82)
            }
        }
    }
}
