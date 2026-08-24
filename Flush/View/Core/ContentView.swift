//
//  ContentView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedBook: Books? = nil
    @Namespace private var stopwatchNamespace
    
    @EnvironmentObject var booksViewModel: BooksViewModel
    
    init() {
        let appearance = UITabBarAppearance()
        
        // mantém o desfoque/transparência original do sistema
        appearance.configureWithDefaultBackground()
        
        let actionColor = UIColor(named: "ActionColor") ?? UIColor.orange
        
        // configura a cor quando o ícone ESTÁ selecionado
        appearance.stackedLayoutAppearance.selected.iconColor = actionColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: actionColor]
        
        // configura a cor quando o ícone NÃO ESTÁ selecionado (Cinza padrão)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        // aplica as regras na TabBar do app
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
     
    var body: some View {
        
        TabView {
            Tab("Estante", systemImage: "book"){
                BookCaseView()
//                    .tint(.blue)
                   // .environmentObject(PhotoLibraryViewModel())
            }
            Tab("Cronômetro", systemImage: "timer"){
                StopwatchFlowView(
                    namespace: stopwatchNamespace,
                    selectedBook: $selectedBook
                )
//                .tint(.blue)
            }
            Tab(role: .search){
                BookSearchView()
//                    .tint(.blue)
            }
            
        }
//        .tint(Color("ActionColor"))
    }
}

#Preview {
    ContentView()
        .environmentObject(UserSettingsViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(StopwatchViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(NotesViewModel())
        .environmentObject(BookFilterViewModel())
}
