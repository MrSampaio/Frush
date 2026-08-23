//
//  ToolBarAddButton.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 16/08/26.
//


//
//  ToolBarAddButton.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 16/08/26.
//

import SwiftUI

struct BookCaseToolbar: ToolbarContent {
    var onAddClick: () -> Void
    
    @ObservedObject var filterViewModel: BookFilterViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                onAddClick()
            }) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color("ActionColor"))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Menu {
                    Picker("Gênero", selection: $filterViewModel.selectedCategory) {
                        ForEach(filterViewModel.availableCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                } label: {
                    Label("Gêneros", systemImage: "books.vertical")
                }
                
                Section("Ordenar por") {
                    Picker("Ordenação", selection: $filterViewModel.currentSort) {
                        ForEach(BookSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .buttonBorderShape(.circle)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            NavigationStack {
                Text("Conteúdo da sua View aqui")
                    .toolbar {
                        BookCaseToolbar(
                            onAddClick: { print("Clicou no add") },
                            filterViewModel: BookFilterViewModel()
                        )
                    }
            }
        }
    }
    
    return PreviewWrapper()
}
