//
//  ContentView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedBook: Books? = nil
    @Namespace private var stopwatchNamespace
    
    @EnvironmentObject var booksViewModel: BooksViewModel
    
    init() {
        // Tenta puxar a sua "ActionColor". Se falhar por algum motivo, usa laranja padrão.
        UITabBar.appearance().tintColor = UIColor(named: "ActionColor") ?? UIColor.orange
    }

    var body: some View {
        
        TabView {
            Tab("Estante", systemImage: "book"){
                BookCaseView()
//                    .tint(.blue)
                   // .environmentObject(PhotoLibraryViewModel())
            }
            Tab("Cronômetro", systemImage: "timer"){
                StopwatchInitialView(
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
}
