//
//  CategorySelectGroup.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 16/08/26.
//

import SwiftUI

struct CategoryMenuView: View {
    var title: String
    //let categories = ["Citação", "Resumo", "Pensamento", "Crítica"]
    let categories: [String]
    @Binding var selectedCategory: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.title3, weight: .medium))
                .foregroundColor(Color("LinesColor"))
                .padding(.bottom, 6)
                .padding(.leading, 4)

            Menu {
                Picker("Categoria", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            } label: {
                HStack {
                    Text(selectedCategory.isEmpty ? "Selecione uma categoria" : selectedCategory)
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(selectedCategory.isEmpty ?  Color("TextFieldPlaceholderColor2") : .white)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("TextFieldPlaceholderColor2"))
                }
                .padding()
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color("LinesColor"), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        CategoryMenuView(
            title: "Escolher categoria",
            categories: ["Citação", "Resumo", "Pensamento", "Crítica"],
            selectedCategory: .constant("Teste"),
            //selectedCategory: .constant("Citação"),
        )
        .padding()
    }
}
