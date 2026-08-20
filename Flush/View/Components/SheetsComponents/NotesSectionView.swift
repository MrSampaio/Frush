//
//  NotesSectionView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI
import CoreData

struct NotesSectionView: View {
    var notes: [Notes]

    var onNotesChanged: () -> Void = { }

    @EnvironmentObject private var notesViewModel: NotesViewModel

    @State private var selectedNote: Notes?

    var body: some View {
        Group {
            if notes.isEmpty {
                Text("Nenhuma anotação cadastrada.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 24)
            } else {
                LazyVStack(spacing: 0) {
                    NavigationStack{
                        ForEach(notes, id: \.objectID) { note in
                            NavigationLink(destination: NoteDetailSheetView(note: note)){
                                NoteRowView(note: note)
                            }
    //                        Button {
    //                            selectedNote = note
    //                        } label: {
    //
    //                        }
    //                        .buttonStyle(.plain)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)

                            if note.objectID != notes.last?.objectID {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                    .padding(.leading, 16)
                            }
                        }
                    }

                }
            }
        }
        .background(Color("cardNote").opacity(0.8))
        .cornerRadius(20)
        .sheet(item: $selectedNote, onDismiss: onNotesChanged) { note in
            NoteDetailSheetView(note: note)
                .environmentObject(notesViewModel)
        }
    }
}

struct NoteRowView: View {
    var note: Notes

    private var photo: UIImage? {
        if let photosData = note.notePhoto as? [Data], let firstData = photosData.first {
            return UIImage(data: firstData)
        }
        return nil
    }

    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let image = photo {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("defaultBook")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 50, height: 70)
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
        .contentShape(Rectangle())
    }
}
