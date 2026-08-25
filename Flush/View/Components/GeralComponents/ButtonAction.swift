//
//  ButtonAction.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI

struct ButtonAction: View {
    var text: String
    var colorButton: String? = nil
    var isGlass: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            Text(text)
                .font(.body)
                .frame(maxWidth: .infinity)
                .fontWeight(.medium)
                .padding(.vertical, isGlass ? 8 : 14)
                .background(
                    Group {
                        if let colorName = colorButton, !isGlass {
                            Color(colorName)
                        } else {
                            Color.clear
                        }
                    }
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                
        }
        .frame(height: 50) // Garante a mesma altura padrão para todos
        .if(isGlass) { view in
            view.buttonStyle(.glass)
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        // Button com .buttonStyle(.glass)
        ButtonAction(text: "Excluir", isGlass: true) {
            print("Excluído")
        }
        
        // Button preenchido com cor
        ButtonAction(text: "Salvar", colorButton: "ActionColor")
    }
    .padding()
}
