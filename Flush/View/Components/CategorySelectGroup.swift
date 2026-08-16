//
//  CategorySelectGroup.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 16/08/26.
//

import SwiftUI

struct CategoryMenuView: View {
    var title: String 
    let categories = ["Citação", "Resumo", "Pensamento", "Crítica"]
    @Binding var selectedCategory: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)            
                .font(.system(.title3, weight: .medium))
                .foregroundColor(.white)
                .padding(.bottom, 6)
                .padding(.leading, 4)

            HStack {
                Text(selectedCategory.isEmpty ? "Selecione uma categoria" : selectedCategory)
                    .font(.system(.body, weight: .regular))
                    .foregroundColor(selectedCategory.isEmpty ? .white.opacity(0.7) : .white)
                
                Spacer()
                
                Menu {
                    Picker("Categoria", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                } label: {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ZStack {
        Color("BackgroundColorViews").ignoresSafeArea()
        CategoryMenuView(title: "Escolher categoria", selectedCategory: .constant("Citação"))
            .padding()
    }
}
