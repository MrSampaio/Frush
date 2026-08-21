//
//  NoteCellView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//
import SwiftUI

struct NoteCellView: View {
    var note: Notes
    
    @ObservedObject var noteViewModel: NotesViewModel
    
    @State private var isShowingDeleteAlert = false
    @State private var isEditingSheetPresented = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(note.noteCategory ?? "Geral")
                    .font(.custom("Bitter-SemiBold", size: 11))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .foregroundStyle(.blue)
                    .background(Color.blue.opacity(0.15), in: Capsule())
                
                Spacer()
            }
            
            Text(note.noteTitle ?? "Nota sem título")
                .font(.custom("Bitter-SemiBold", size: 17))
            
            if let description = note.noteDescription, !description.isEmpty {
                Text(description)
                    .font(.custom("Bitter-Regular", size: 15))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
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
                    try noteViewModel.deleteNote(note: note)
                    
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
        .padding(.vertical, 4)
    }
}

