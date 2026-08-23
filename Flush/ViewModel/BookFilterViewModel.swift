//
//  BookFilterViewModel.swift
//  CH4-Books
//
//  Created by Lucas on 22/08/26.
//

import Foundation
import SwiftUI
import Combine

enum BookSortOption: String, CaseIterable {
    case alphabetical = "Ordem Alfabética"
    case mostRead = "Mais Lidos (Páginas)"
}

class BookFilterViewModel: ObservableObject {
    @Published var currentSort: BookSortOption = .alphabetical
    
    @Published var selectedCategory: String = "Todos"
    
    let availableCategories = [
        "Todos", "Romance", "Suspense", "Ação", "Terror",
        "Drama", "Literatura", "Educativo", "Infantil", "Infantojuvenil"
    ]
    
    func applyFilters(to books: [Books]) -> [Books] {
        var result = books
        
        if selectedCategory != "Todos" {
            result = result.filter { $0.bookCategory == selectedCategory }
        }
        
        switch currentSort {
        case .alphabetical:
            result.sort { ($0.bookTitle ?? "") < ($1.bookTitle ?? "") }
        case .mostRead:
            result.sort { $0.bookCurrentPage > $1.bookCurrentPage }
        }
        
        return result
    }
}
