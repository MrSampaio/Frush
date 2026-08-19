//
//  NoteListView.swift
//  CH4-Books
//
//  Created by Lucas on 19/08/26.
//

import SwiftUI
import CoreData

struct MyNotesListView: View {
    @StateObject private var viewModel = NotesViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedNote: Notes?
    var book: Books?
    let backgroundColor = Color(.backgroundColorViews)
    let accentOrange = Color(.action)
    let buttonBackground = Color.white.opacity(0.2)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                TitleComponent(title: "Minhas notas")
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        ForEach(viewModel.savedNotes, id: \.self) { note in
                            
                            Button(action: {
                                selectedNote = note
                            }) {
                                NoteRowView(note: note)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            MyNotesToolBar(onBackClick: { dismiss() }, onAddClick: {
                print("Adicionar nova nota")
            })
        }
        .onAppear {
            viewModel.fetchNotes(for: book)
        }
        .sheet(item: $selectedNote) { note in
            NoteDetailSheetView(note: note)
        }
    }
}

struct NotesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyNotesListView(book: nil)
        }
    }
}
