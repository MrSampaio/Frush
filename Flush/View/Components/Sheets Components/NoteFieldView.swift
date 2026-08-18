//
//  NoteFieldView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI
// campos para visualizar a nota
struct NoteFieldView: View {
        let note: Notes
        
        var body: some View {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(categoryColor(for: note.noteCategory))
                    .frame(width: 12, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.noteTitle ?? "Sem título")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(note.noteDescription ?? "")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        
        private func categoryColor(for category: String?) -> Color {
            switch category {
            case "Citação": return .pink
            case "Resumo": return .blue
            case "Pensamento": return .yellow
            case "Crítica": return .red
            case "Conceito": return .purple
            case "Lição": return .green
            case "Pergunta": return .orange
            case "Favorito": return .indigo
            default: return .gray
            }
        }
    }
