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
    
    var body: some View {
        TabView {
            Tab("Estante", systemImage: "book"){
                SheetNotes(book: PreviewProviderHelper.sampleBook)
            }
            Tab("Cronometro", systemImage: "timer"){
                StopwatchView()
            }
            Tab(role: .search){
                BookSearchView()
            }
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BooksViewModel())
        .environmentObject(StopwatchViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(NotesViewModel())
}
