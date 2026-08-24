//
//  NotesSectionView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI
import SwiftData

struct NotesSectionView: View {
    var notes: [Notes]

    var onNotesChanged: () -> Void = { }

    @EnvironmentObject private var notesViewModel: NotesViewModel

    @State private var selectedNote: Notes?

    var body: some View {
            Group {
                if notes.isEmpty {
                    Text("Adicione sua primeira anotação")
                        .font(.subheadline)
                        .foregroundColor(Color("Texts"))
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                } else {
                    NavigationStack {
                        LazyVStack {
                            ForEach(notes, id: \.self) { note in
                                NavigationLink(destination: NoteDetailSheetView(note: note)) {
                                    NoteRowView(note: note)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 28)

                                if note.persistentModelID != notes.last?.persistentModelID {
                                    Divider()
                                        .frame(height: 0.3)
                                        .background(Color("LinesColor"))
                                        .padding(.horizontal, 28)
                                }
                            }
                            .padding(.top, 16)
                        }
                    }
                }
            }
            .background(Color("cardNote").opacity(0.9))
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
//        if let photosData = note.notePhoto as? [Data], let firstData = photosData.first {
//            return UIImage(data: firstData)
//        }
//        return nil
        
        if let firstData = note.notePhoto.first {
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
                .cornerRadius(8)
                .clipped()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.noteTitle ?? "Sem título")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Texts"))
                        .lineLimit(1)
                    
                    Text(note.noteDescription ?? "Sem conteúdo")
                        .font(.subheadline)
                        .foregroundColor(Color("Texts"))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("Texts"))
                    .font(.body)
                    .fontWeight(.medium)

            }
            .contentShape(Rectangle())
    }
}


//#Preview("Com Anotações") {
//    do {
//        // Cria um container isolado na memória só para visualização
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Notes.self, configurations: config)
//        let context = container.mainContext
//        
//        let note1 = Notes()
//        note1.noteTitle = "Anotações do Capítulo 1"
//        note1.noteDescription = "Principais insights sobre a introdução do livro e conceitos base."
//        note1.notePhoto = []
//
//        let note2 = Notes()
//        note2.noteTitle = "Citação Favorita"
//        note2.noteDescription = "A simplicidade é o último grau de sofisticação."
//        note2.notePhoto = []
//
//        context.insert(note1)
//        context.insert(note2)
//
//        NavigationStack {
//            ScrollView {
//                NotesSectionView(notes: [note1, note2])
//                    .padding()
//            }
//            .background(Color("BackgroundColorViews"))
//        }
//        .modelContainer(container)
//        .environmentObject(NotesViewModel())
//        
//    } catch {
//        fatalError("Erro ao criar container de preview: \(error.localizedDescription)")
//    }
//}
//
//#Preview("Lista Vazia") {
//    NavigationStack {
//        NotesSectionView(notes: [])
//            .padding()
//            .background(Color(uiColor: .systemGroupedBackground))
//    }
//    .environmentObject(NotesViewModel())
//}
