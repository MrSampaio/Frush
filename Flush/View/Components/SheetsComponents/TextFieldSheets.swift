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
                    .foregroundColor(Color("LinesColor"))
                    .padding(.bottom, 6)
                    .padding(.leading, 4)
            }
            
            TextField("", text: $text, prompt: Text(placeholder)
                .font(.system(.body, weight: .regular))
                .foregroundColor(Color("TextFieldPlaceholderColor"))
            )
            .foregroundStyle(.white)
            .padding()
            .font(.system(.body, weight: .regular))
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color("LinesColor"), lineWidth: 0.5)
            )
            
        }
        
        
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text1: String = ""
        @State private var text2: String = ""
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextFieldSheets(
                        text: $text1,
                        placeholder: "Digite aqui...",
                        label: "Título do Campo"
                    )
                    
                    TextFieldSheets(
                        text: $text2,
                        placeholder: "Apenas com placeholder"
                    )
                }
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
