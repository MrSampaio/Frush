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
    @State var selectedCategory = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.title3, weight: .medium))
                .foregroundColor(.white)
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
                        .foregroundColor(selectedCategory.isEmpty ? .white.opacity(0.7) : .white)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white)
                }
                .padding()
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
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
            //selectedCategory: .constant("Citação"),
        )
        .padding()
    }
}
