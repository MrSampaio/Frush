//
//  NoteCellView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//
import SwiftUI

struct NoteCellView: View {
    let note: Notes
    
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
//                isShowingDeleteAlert = true
            } label: {
                Label("Apagar Nota", systemImage: "trash")
                    .font(.body)
            }
        }
        .frame(width: 170)
        .cornerRadius(12)
        .padding(.vertical, 4)
    }
}

