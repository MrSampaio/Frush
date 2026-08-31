//
//  AppRouter.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 25/08/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    
    enum Tab: Hashable {
        case bookcase
        case stopwatch
        case search
    }
    
    @Published var selectedTab: Tab = .bookcase
    @Published var selectedBook: Books? = nil
    
    /// Leva o usuário para a aba do cronômetro com o livro já selecionado.
    func startReading(_ book: Books) {
        selectedBook = book
        selectedTab = .stopwatch
    }
}
