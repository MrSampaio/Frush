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
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
                    action?()
        }) {
            Text(text)
                .font(.body)
                .frame(maxWidth: .infinity)
                .fontWeight(.medium)
                .padding(.vertical, 14)
                .background(colorButton != nil ? Color(colorButton!) : Color.clear)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        
    }
}

#Preview {
    VStack(spacing: 16) {
        ButtonAction(text: "Botão Sem Cor") {
            print("Pressionado")
        }
        
        ButtonAction(text: "Excluir", colorButton: "ActionColor") {
            print("Excluído")
        }
        
        // 3. Com cor de fundo e sem ação (passando a String com o nome da cor)
        ButtonAction(text: "Salvar", colorButton: "ActionColor")
    }
    .padding()

}
