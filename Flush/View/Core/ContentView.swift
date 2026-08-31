//
//  ContentView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 13/08/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @EnvironmentObject var router: AppRouter
    @Namespace private var stopwatchNamespace
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        let actionColor = UIColor(named: "ActionColor") ?? UIColor.orange
        
        appearance.stackedLayoutAppearance.selected.iconColor = actionColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: actionColor]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab("Estante", systemImage: "book", value: AppRouter.Tab.bookcase) {
                BookCaseView()
            }
            Tab("Cronômetro", systemImage: "timer", value: AppRouter.Tab.stopwatch) {
                StopwatchFlowView(
                    namespace: stopwatchNamespace,
                    selectedBook: $router.selectedBook
                )
            }
            Tab(value: AppRouter.Tab.search, role: .search) {
                BookSearchView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
        .environmentObject(UserSettingsViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(StopwatchViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(NotesViewModel())
        .environmentObject(BookFilterViewModel())
}
