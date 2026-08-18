//
//  SheetHeaderView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 14/08/26.
//

import SwiftUI

struct SheetHeaderView: ToolbarContent {
    let title: String
    let actionIcon: String
    
    @Binding var showingDiscardAlert: Bool
    
    var onCancel: () -> Void
    var onConfirm: () -> Void
    var onDiscard: () -> Void
  
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                showingDiscardAlert = true
            }) {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .confirmationDialog(
                "Atenção",
                isPresented: $showingDiscardAlert,
                titleVisibility: .hidden
            ) {
                Button("Descartar", role: .destructive) {
                    onDiscard()
                }
                
                Button("Continuar Editando", role: .cancel) { }
                
            } message: {
                Text("Deseja mesmo descartar a edição?")
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(title)
                .foregroundColor(.title)
                .font(.title2)
                .fontWeight(.semibold)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                onConfirm()
            }) {
                Image(systemName: actionIcon)
                    .fontWeight(.semibold)
                    .font(.body.bold())
                    .foregroundColor(.title)
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
                        SheetHeaderView (
                            title: "Cadastrar Livro",
                            actionIcon: "checkmark",
                            showingDiscardAlert: $showAlert,
                            onCancel: { print("Clicou no X") },
                            onConfirm: { print("Clicou no Check") },
                            onDiscard: { print("Clicou em descartar") }
                        )
                    }
            }
        }
    }
    
    return PreviewWrapper()
}
