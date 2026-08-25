//
//  NoteCellView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//
import SwiftUI
import SwiftData
import PhotosUI

struct NoteCellView: View {
    @Environment(\.modelContext) private var modelContext
    var note: Notes
    
    @ObservedObject var noteViewModel: NotesViewModel
    
    @State private var isShowingDeleteAlert = false
    @State private var isEditingSheetPresented = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
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
        HStack{
            Group {
                if let image = photo{
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
            VStack(alignment: .leading, spacing: 6) {
                
                
                Text(note.noteTitle ?? "Nota sem título")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                if !note.noteDescription.isEmpty {
                    Text(note.noteDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

        }
        .contentShape(Rectangle())
//        .contextMenu {
//            Button() {
//                isEditingSheetPresented = true
//            } label: {
//                Label("Editar Nota", systemImage: "pencil")
//                    .foregroundColor(.blue)
//                    .font(.body)
//            }
//            
//            Divider()
//            
//            Button(role: .destructive) {
//                isShowingDeleteAlert = true
//            } label: {
//                Label("Apagar Nota", systemImage: "trash")
//                    .font(.body)
//            }
//        }
        
        .alert("Apagar Nota", isPresented: $isShowingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Apagar", role: .destructive) {
                do{
                    try noteViewModel.deleteNote(note: note, context: modelContext)
                    
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

        .frame(width: 170)
        .cornerRadius(12)
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }
}

