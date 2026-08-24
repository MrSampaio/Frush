//
//  NoteCellView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//
import SwiftUI
import SwiftData

struct NoteCellView: View {
    @Environment(\.modelContext) private var modelContext
    var note: Notes
    
    @ObservedObject var noteViewModel: NotesViewModel
    
    @State private var isShowingDeleteAlert = false
    @State private var isEditingSheetPresented = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(note.noteTitle ?? "Nota sem título")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(1)
            
            if  !note.noteDescription.isEmpty {
                Text(note.noteDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button() {
//                isEditingSheetPresented = true
            } label: {
                Label("Editar Nota", systemImage: "pencil")
                    .foregroundColor(.blue)
                    .font(.body)
            }
            
            Divider()
            
            Button(role: .destructive) {
                isShowingDeleteAlert = true
            } label: {
                Label("Apagar Nota", systemImage: "trash")
                    .font(.body)
            }
        }
        
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

