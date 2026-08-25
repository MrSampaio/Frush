//
//  StopwatchRunningView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 24/08/26.
//

import SwiftUI
import SwiftData

struct StopwatchRunningView: View {
    var namespace: Namespace.ID
    @Binding var selectedBook: Books?
    
    @EnvironmentObject var stopwatchViewModel: StopwatchViewModel
    
    @State private var isShowingNoteSheet = false
    @State private var showAbandonAlert = false
    @State private var isShowingNoBookAlert = false
    
    private var isRunning: Bool {
        stopwatchViewModel.timerState == .running
    }
    
    private var progress: Double {
        guard let book = selectedBook else { return 0 }
        return stopwatchViewModel.getBookProgress(book: book)
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea(.all)
            
            /*
            PulsingRingsView(
                isAnimating: isRunning,
                baseDiameter: 440,
                ringCount: 3,
                timeProgress: stopwatchViewModel.timeProgress
            )
            .allowsHitTesting(false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .ignoresSafeArea(.all)
            */
            GeometryReader { geo in
                PulsingRingsView(
                    isAnimating: isRunning,
                    baseDiameter: 440,
                    ringCount: 3,
                    timeProgress: stopwatchViewModel.timeProgress
                )
                .position(x: geo.size.width / 2, y: geo.size.height / 2)   // 👈 centro fixo
            }
            .allowsHitTesting(false)
            .clipped()
            .ignoresSafeArea(.all)
            
            // Conteúdo dentro dos arcos amarelos
            VStack(spacing: 0) {
                Text("Tempo de leitura")
                    .font(.subheadline)
                    .foregroundColor(Color("TextFieldPlaceholderColor"))
                    .padding(.bottom, 2)
                
                Text(stopwatchViewModel.timerFormater())
                    .font(.custom("Bitter", size: 70, relativeTo: .largeTitle))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Texts"))
                    .monospacedDigit()
                    //.matchedGeometryEffect(id: "timerText", in: namespace)
                    .padding(.bottom, 14)
                
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color("LinesColor"))
                        .frame(width: 20, height: 0.5)
                    
                    Text(selectedBook?.bookTitle ?? "Sem livro")
                        .font(.subheadline)
                        .foregroundColor(Color("TextFieldPlaceholderColor"))
                    
                    
                    Rectangle()
                        .fill(Color("LinesColor"))
                        .frame(width: 20, height: 0.5)
                }
                .padding(.bottom, 20)

                ButtonAction(
                    text: isRunning ? "Pausar leitura" : "Continuar leitura",
                    colorButton: "ActionColor"
                ) {
                    if isRunning {
                        stopwatchViewModel.pauseTimer()
                    } else {
                        stopwatchViewModel.startTimer()
                    }
                }
                .padding(.bottom, 4)
                
                Button {
                    showAbandonAlert = true
                } label: {
                    Text("Abandonar leitura")
                        .font(.subheadline)
                        .foregroundColor(Color("ActionColor"))
                        .underline()
                }
                .padding(.top, 20)
            }
            .frame(width: 215)
        }
        .toolbar {
            ToolBarButton(
                action: {
                    if selectedBook != nil {
                        isShowingNoteSheet = true
                    } else {
                        isShowingNoBookAlert = true
                    }
                },
                icon: "square.and.pencil"
            )
        }
        .alert("Abandonar leitura", isPresented: $showAbandonAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Abandonar", role: .destructive) {
                stopwatchViewModel.abandonTimer()
            }
        } message: {
            Text("Tem certeza que deseja abandonar a leitura? O progresso será perdido.")
        }
        .alert("Atenção", isPresented: $isShowingNoBookAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Selecione um livro antes de adicionar uma anotação.")
        }
        .sheet(isPresented: $isShowingNoteSheet) {
            if let currentBook = selectedBook {
                NoteSheetView(book: currentBook)
            }
        }
    }
}


#Preview {
    let container = try! ModelContainer(
        for: Books.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let book = Books(
        bookAuthor: "Becca Fitzpatrick",
        bookCategory: "Romance",
        bookCover: Data(),
        bookCurrentPage: 120,
        bookGoal: 0,
        bookTitle: "Hush, Hush",
        bookTotalPages: 200,
        isTimerRunning: true,
        wasLastPageAdded: true,
        readingStartDate: nil
    )
    container.mainContext.insert(book)
    
    let stopwatchVM = StopwatchViewModel()
    stopwatchVM.totalTime = 15 * 60
    stopwatchVM.elapsedTime = 6 * 60      // ~60% do tempo já passou
    stopwatchVM.timerState = .running
    
    return PreviewWrapper(book: book)
        .modelContainer(container)
        .environmentObject(stopwatchVM)
}

private struct PreviewWrapper: View {
    @Namespace var namespace
    @State var book: Books?
    
    init(book: Books) {
        _book = State(initialValue: book)
    }
    
    var body: some View {
        NavigationStack {
            StopwatchRunningView(namespace: namespace, selectedBook: $book)
        }
    }
}
