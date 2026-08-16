//
//  ContentView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        BookView()
    }
}

#Preview {
    ContentView()
        .environmentObject(BooksViewModel())
}
