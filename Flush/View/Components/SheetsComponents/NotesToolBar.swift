//
//  NotesHeaderEditView.swift
//  CH4-Books
//
//  Created by Lucas on 18/08/26.
//

import SwiftUI

struct NotesToolBar: ToolbarContent {
    var title: String
    var onClose: () -> Void
    var onEdit: () -> Void
    
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                onClose()
            }) {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .buttonBorderShape(.circle)
            .tint(Color.white.opacity(0.2))
        }
        
        ToolbarItem(placement: .principal) {
            Text(title)
                .foregroundColor(Color("LinesColor"))
                .font(.bitter(.semibold, style: .title2))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                onEdit()
            }) {
                Image(systemName: "pencil")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                   
            }
            
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color("ActionColor"))
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var showAlert = false
        
        var body: some View {
            NavigationStack {
                Text("Conteúdo da sua Sheet aqui")
                    .toolbar {
                        NotesToolBar(
                            title: "Notas", onClose: {}, onEdit: {}
                        )
                    }
            }
        }
    }
    
    return PreviewWrapper()
}
