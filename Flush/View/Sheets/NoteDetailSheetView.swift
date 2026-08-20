//
//  NoteDetailSheetView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct NoteDetailSheetView: View {
    @EnvironmentObject private var notesViewModel: NotesViewModel

    @ObservedObject var note: Notes

    @Environment(\.dismiss) private var dismiss

    @State private var isShowingEditSheet = false

    private var noteImages: [UIImage] {
        if let photosData = note.notePhoto as? [Data] {
            return photosData.compactMap { UIImage(data: $0) }
        }
        return []
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.backgroundColorViews)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        if !noteImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Array(noteImages.enumerated()), id: \.offset) { _, image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 240, height: 300)
                                            .cornerRadius(16)
                                            .clipped()
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text(note.noteTitle ?? "Sem título")
                                .font(.system(.title, weight: .medium))
                                .foregroundColor(.title)
                                .multilineTextAlignment(.leading)

                            Text(note.noteDescription ?? "Sem descrição")
                                .font(.system(.body, weight: .light))
                                .foregroundColor(Color(.title))
                                .lineSpacing(5)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .padding(.bottom, 40)
                }
                .toolbar {
                    NoteDetailsToolbar(title: "Nota", onEdit: {
                         
                    })
//                    NotesToolBar(
//                        title: "Nota",
//                        onClose: {
//                            notesViewModel.fetchNotes(for: note.book)
//                            dismiss()
//                        },
//                        onEdit: {
//                            isShowingEditSheet = true
//                        }
//                    )
                }
            }
            .sheet(isPresented: $isShowingEditSheet, onDismiss: {
                notesViewModel.fetchNotes(for: note.book)
            }) {
                if let book = note.book {
                    NoteSheetView(book: book, noteToEdit: note)
                        .environmentObject(notesViewModel)
                }
            }
        }
    }
}
