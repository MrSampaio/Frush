//
//  CH4_BooksApp.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import SwiftUI
import SwiftData

@main
struct CH4_BooksApp: App {
    //let persistenceController = CoreDataManager.shared
    @StateObject var photoViewModel = PhotoLibraryViewModel()
    @StateObject var booksViewModel = BooksViewModel()
    @StateObject var notesViewModel = NotesViewModel()
    @StateObject var stopWatchViewModel = StopwatchViewModel()
    @StateObject var userSettingsViewModel = UserSettingsViewModel()
    @StateObject var filterViewModel = BookFilterViewModel()

    var body: some Scene {
        WindowGroup {
            RootFlowView()
                //.environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(userSettingsViewModel)
                .environmentObject(photoViewModel)
                .environmentObject(booksViewModel)
                .environmentObject(notesViewModel)
                .environmentObject(stopWatchViewModel)
                .environmentObject(filterViewModel)
        }
        .modelContainer(for: [
                    Books.self,
                    Notes.self,
                    NoteImage.self,
                    UserSettings.self
                ])
    }
}

struct RootFlowView: View {
 
    enum Screen {
        case splash
        case firstOnboard
        case secondOnboard
        case main
    }
 
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
 
    @State private var screen: Screen = .splash
 
    var body: some View {
        ZStack {
            switch screen {
            case .splash:
                SplashView()
                    .transition(.opacity)
                    .task {
                        try? await Task.sleep(for: .seconds(1.2))
                        withAnimation(.easeInOut(duration: 0.35)) {
                            screen = hasCompletedOnboarding ? .main : .firstOnboard
                        }
                    }
 
            case .firstOnboard:
                FirstOnboardView {
                    withAnimation(.easeInOut(duration: 0.35)) { screen = .secondOnboard }
                }
                .transition(.opacity)
 
            case .secondOnboard:
                SecondOnboardView {
                    hasCompletedOnboarding = true
                    withAnimation(.easeInOut(duration: 0.35)) { screen = .main }
                }
                .transition(.opacity)
 
            case .main:
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}
