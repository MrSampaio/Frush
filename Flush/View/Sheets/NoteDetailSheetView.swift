//
//  NoteDetailSheetView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct NoteDetailSheetView: View {
    var note: Notes
    
    @Environment(\.dismiss) var dismiss
    
    @State var isShowingEditSheet: Bool = false
    
    private var noteImages: [UIImage] {
        if let photosData = note.notePhoto as? [Data] {
            return photosData.compactMap { UIImage(data: $0) }
        }
        return []
    }
    
    var body: some View {
        
        NavigationStack{
            ZStack(alignment: .top) {
                Color(.backgroundColorViews)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            if !noteImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(0..<noteImages.count, id: \.self) { index in
                                            Image(uiImage: noteImages[index])
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
                        .padding(.bottom, 40)
                    }
                }
                .toolbar{
                    NotesToolBar(
                        title: "Nota",
                        onClose: { dismiss() },
                        onEdit: {
                            isShowingEditSheet.toggle()
                        }
                    ) 
                }
                
                .sheet(isPresented: $isShowingEditSheet, onDismiss: {
                    
                }){
                    NoteSheetView(book: note.book!, noteToEdit: note)
                }
            }
        }

    }
}
