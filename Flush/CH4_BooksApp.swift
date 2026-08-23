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
    @StateObject var booksViewModel = BooksViewModel()
    @StateObject var notesViewModel = NotesViewModel()
    @StateObject var stopWatchViewModel = StopwatchViewModel()
    @StateObject var userSettingsViewModel = UserSettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(userSettingsViewModel)
                .environmentObject(photoViewModel)
                .environmentObject(booksViewModel)
                .environmentObject(notesViewModel)
                .environmentObject(stopWatchViewModel)
        }
    }
}
