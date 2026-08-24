//
//  NoteDetailSheetView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI
import SwiftData

struct NoteDetailSheetView: View {
    @EnvironmentObject private var notesViewModel: NotesViewModel
    
    var note: Notes
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingEditSheet = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var showingDeleteAlert = false
    @Environment(\.modelContext) private var modelContext

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
                .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
                    Button("Tentar novamente", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .toolbar {
                    NoteDetailsToolbar(
                        title: "Nota",
                        onDelete: {
                            showingDeleteAlert.toggle()
                        },
                        onEdit: {
                            isShowingEditSheet.toggle()
                        },
                    )
                }
                .alert("Apagar Nota", isPresented: $showingDeleteAlert) {
                    Button("Cancelar", role: .cancel) { }
                    Button("Apagar", role: .destructive) {
                        do{
                            try notesViewModel.deleteNote(note: note, context: modelContext)
                            notesViewModel.fetchNotes(for: note.book, context: modelContext)
                            dismiss()
                        } catch let error as LocalizedError {
                            errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                            showErrorAlert = true
                        } catch {
                            errorMessage = "Erro inesperado."
                            showErrorAlert = true
                        }
                    }
                } message: {
                    Text("Tem certeza que deseja apagar esta nota? Essa ação não pode ser desfeita.")
                }
                //                .toolbar {
                //                    NoteDetailsToolbar(
                //                        title: "Nota",
                //                        onDelete: {
                //
                //                        },
                //                        onEdit: {
                //
                //
                //                        }
                //
                //                    )
                ////                    NotesToolBar(
                ////                        title: "Nota",
                ////                        onClose: {
                ////                            notesViewModel.fetchNotes(for: note.book)
                ////                            dismiss()
                ////                        },
                ////                        onEdit: {
                ////                            isShowingEditSheet = true
                ////                        }
                ////                    )
                //                }
                //            }
                .sheet(isPresented: $isShowingEditSheet, onDismiss: {
                    notesViewModel.fetchNotes(for: note.book, context: modelContext)
                }) {
                    if let book = note.book {
                        NoteSheetView(book: book, noteToEdit: note)
                            .environmentObject(notesViewModel)
                    }
                }
            }
        }
    }
}
