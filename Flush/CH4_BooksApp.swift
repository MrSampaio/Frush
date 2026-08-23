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
    @StateObject var filterViewModel = BookFilterViewModel()

    var body: some Scene {
        WindowGroup {
            RootFlowView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(userSettingsViewModel)
                .environmentObject(photoViewModel)
                .environmentObject(booksViewModel)
                .environmentObject(notesViewModel)
                .environmentObject(stopWatchViewModel)
                .environmentObject(filterViewModel)
        }
    }
}

struct RootFlowView: View {
    enum Screen {
        case splash
        case firstOnboard
        case secondOnboard
        case main
    }

    @State private var screen: Screen = .splash

    var body: some View {
        ZStack {
            switch screen {
            case .splash:
                SplashView()
                    .transition(.opacity)
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation(.easeInOut(duration: 0.5)) {
                            screen = .firstOnboard
                        }
                    }

            case .firstOnboard:
                FirstOnboardView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        screen = .secondOnboard
                    }
                }
                .transition(.opacity)

            case .secondOnboard:
                SecondOnboardView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        screen = .main
                    }
                }
                .transition(.opacity)

            case .main:
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}
