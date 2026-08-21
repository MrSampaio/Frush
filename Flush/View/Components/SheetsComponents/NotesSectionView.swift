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
                Text("Adicione sua primeira anotacão")
                    .font(.subheadline)
                    .foregroundColor(Color("Texts"))
                    .padding(.top, 20)
                    .padding(.bottom, 10)
            } else {
                LazyVStack() {
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
                            .padding(.vertical, 10)
                            .padding(.horizontal, 28)

                            if note.objectID != notes.last?.objectID {
                                Divider()
                                    .frame(height: 0.3)
                                    .background(Color("LinesColor"))
                                    .padding(.horizontal, 28)
                            }
                        }.padding(.top, 16)
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


#Preview("Com Anotações") {
    // 1. Instância do CoreData em memória para o Preview
    // NOTA: Altere "CH4_Books" para o nome exato do seu arquivo .xcdatamodeld
    let container = NSPersistentContainer(name: "CH4_Books")
    container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    container.loadPersistentStores { _, error in
        if let error = error {
            fatalError("Erro no CoreData Preview: \(error.localizedDescription)")
        }
    }
    
    let context = container.viewContext

    // 2. Dados mockados (Mock Notes)
    let note1 = Notes(context: context)
    note1.noteTitle = "Anotações do Capítulo 1"
    note1.noteDescription = "Principais insights sobre a introdução do livro e conceitos base."

    let note2 = Notes(context: context)
    note2.noteTitle = "Citação Favorita"
    note2.noteDescription = "A simplicidade é o último grau de sofisticação."

    return NavigationStack {
        ScrollView {
            NotesSectionView(notes: [note1, note2])
                .padding()
        }
        .background(Color("BackgroundColorViews"))
    }
    .environment(\.managedObjectContext, context)
    .environmentObject(NotesViewModel())
}

#Preview("Lista Vazia") {
    
    NavigationStack {
                        //.ignoresSafeArea()
            
            NotesSectionView(notes: [])
                .padding()
                .background(Color(uiColor: .systemGroupedBackground))
        
    }
    .environmentObject(NotesViewModel())
}
