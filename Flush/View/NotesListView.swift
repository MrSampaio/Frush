//
//  NotesListView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 16/08/26.
//

import Foundation
import SwiftUI

struct NotesListView: View {
    @ObservedObject var notesViewModel: NotesViewModel
    
    var body: some View {
        NavigationStack {
            List(notesViewModel.savedNotes) { note in
                NoteCardView(note: note)
                    //.listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
            .navigationTitle("Minhas Notas")
        }
    }
}

struct NoteCardView: View {
    let note: Notes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top) {
                Text(note.noteTitle ?? "Sem título")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(note.noteCategory ?? "Sem categoria")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(.accentColor)
                    .clipShape(Capsule())
            }
            
            Text(note.noteDescription ?? "Sem descrição")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            
            if let photosData = note.notePhoto as? [Data], !photosData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(photosData, id: \.self) { data in
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
            
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NotesListView(notesViewModel: NotesViewModel())
}
