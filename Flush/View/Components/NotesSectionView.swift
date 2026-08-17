//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI
import CoreData

struct NotesSectionView: View {
    let notes: [Notes]
    
    var body: some View {
        VStack(spacing: 16) {
            if notes.isEmpty {
                VStack {
                    Text("Nenhuma anotação para este livro.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(24)
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(notes.enumerated()), id: \.element.objectID) { index, note in
                        NoteFieldView(note: note)
                        if index < notes.count - 1 {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(24)
                .padding(.horizontal, 24)
            }
        }
    }
}
