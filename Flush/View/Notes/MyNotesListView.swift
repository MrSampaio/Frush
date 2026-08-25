//
//  NoteListView.swift
//  CH4-Books
//
//  Created by Lucas on 19/08/26.
//

import SwiftUI
import SwiftData

struct MyNotesListView: View {
    @EnvironmentObject private var viewModel: NotesViewModel
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedNote: Notes?
    @State private var isPresentedAddNote: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    
    var book: Books?
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color(.backgroundColorViews).ignoresSafeArea()
                VStack(alignment: .leading, spacing: 20) {
                    TitleComponent(title: "Minhas notas")
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.savedNotes) { note in
                                if let imageData = note.notePhoto.first {
                                    let uiImage = UIImage(data: imageData)
                                    
                                    
                                    //                                var image = photoLibraryViewModel.loadDataImage(image: note.notePhoto.first)
                                    NavigationLink(destination: NoteDetailSheetView(note: note)){
                                        
                                        //NoteRowView(note: note)
                                        NotesCardView(imageName: uiImage, tagText: note.noteCategory, title: note.noteTitle, description: note.noteDescription)
                                    }
                                    //                                .buttonStyle(PlainButtonStyle())
                                    //                                Button(action: {
                                    //                                    selectedNote = note
                                    //                                }) {
                                    //
                                    //                                }
                                    
                                } else{
                                    NotesCardView(imageName: nil, tagText: note.noteCategory, title: note.noteTitle, description: note.noteDescription)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10)
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
                    viewModel.fetchNotes(for: book, context: modelContext)
                }
                //        .sheet(item: $selectedNote) { note in
                //            NoteDetailSheetView(note: note)
                //        }
                .sheet(isPresented: $isPresentedAddNote, onDismiss: {
                    viewModel.fetchNotes(for: book, context: modelContext)
                }) {
                    if let book = book {
                        NoteSheetView(book: book)
                            .environmentObject(viewModel)
                    }
                }
            }
            
        }
    }
}

//struct NotesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            MyNotesListView(book: nil)
//                .environmentObject(PhotoLibraryViewModel()
//        }
//    }
//}
//
