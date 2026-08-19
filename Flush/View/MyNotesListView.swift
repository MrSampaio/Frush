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
    @State private var isPresentedAddNote: Bool = false
    
    var book: Books?
    
    var body: some View {
        ZStack {
            Color(.backgroundColorViews).ignoresSafeArea()
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
                isPresentedAddNote = true
            })
        }
        .onAppear {
            viewModel.fetchNotes(for: book)
        }
        .sheet(item: $selectedNote) { note in
            NoteDetailSheetView(note: note)
        }
        .sheet(isPresented: $isPresentedAddNote, onDismiss: {
            viewModel.fetchNotes(for: book)
        }) {
            if let book = book {
                NoteSheetView(book: book)
                    .environmentObject(viewModel)
            }
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
