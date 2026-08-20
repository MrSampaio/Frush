//
//  NotesView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 17/08/26.
//

import SwiftUI

struct NotesView: View {
    
    var body: some View {
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                
                Text("Minhas notas")
                    .font(.bitter(.medium, style: .largeTitle))
                    .foregroundStyle(Color("TitleColor"))
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(0..<5) { _ in
                            NotesCardView(
                                imageName: "defaultBook",
                                tagText: "Referência",
                                title: "Título da nota",
                                description: "Descrição inicial da primeira..."
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    NotesView()
}
