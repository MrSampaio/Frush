//
//  CH4_BooksApp.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import SwiftUI
import CoreData

@main
struct CH4_BooksApp: App {
    let persistenceController = CoreDataManager.shared
    @StateObject var photoViewModel = PhotoLibraryViewModel()
    @StateObject private var booksViewModel = BooksViewModel()
    @StateObject private var notesViewModel = NotesViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(photoViewModel)
                .environmentObject(booksViewModel)
                .environmentObject(notesViewModel)
        }
    }
}
