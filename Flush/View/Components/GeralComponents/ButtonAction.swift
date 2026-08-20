//
//  ButtonAction.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI

struct ButtonAction: View {
    var text: String
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
                .background(Color("ActionColor"))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        
    }
}

#Preview {
    VStack(spacing: 16) {
            ButtonAction(text: "Teste Sem Ação")
            
            ButtonAction(text: "Teste Com Ação") {
                print("Botão pressionado!")
            }
        }
        .padding()
}
