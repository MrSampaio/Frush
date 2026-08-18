//
//  TextFieldSheets.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 16/08/26.
//

import SwiftUI

struct TextFieldSheets: View {
    @Binding var text: String
    var placeholder: String
    var label: String? = nil
    
    var body: some View {
        VStack (alignment: .leading){
            if let label = label {
                Text(label)
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.bottom, 6)
                    .padding(.leading, 4)
            }
            
            TextField("", text: $text, prompt: Text(placeholder)
                .font(.system(.body, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
            )
            .foregroundStyle(.white)
            .padding()
            .font(.system(.body, weight: .regular))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 1)
            )
            
        }
        
        
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            TextFieldSheets(
                text: .constant(""),
                placeholder: "Digite aqui...",
                label: "Título do Campo"
            )
            
           
            TextFieldSheets(
                text: .constant(""),
                placeholder: "Apenas com placeholder"
            )
        }
        .padding()
    }
}
