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
    
    var body: some View {
        TabView {
            Tab("Estante", systemImage: "book"){
                BookCaseView(bookViewModel: BooksViewModel())
                   // .environmentObject(PhotoLibraryViewModel())
            }
            Tab("Cronômetro", systemImage: "timer"){
                StopwatchInitialView(
                    namespace: stopwatchNamespace,
                    selectedBook: $selectedBook
                )
            }
            Tab(role: .search){
                BookSearchView()
            }
            
        }
        .tint(Color("ActionColor"))
  
    }
}

#Preview {
    ContentView()
        .environmentObject(BooksViewModel())
        .environmentObject(StopwatchViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(NotesViewModel())
}
