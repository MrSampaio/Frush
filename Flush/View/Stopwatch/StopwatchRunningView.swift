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
            
            // Conteúdo dentro dos arcos amarelos
            VStack(spacing: 0) {
                Text("Tempo de leitura")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 2)
                
                Text(stopwatchViewModel.timerFormater())
                    .font(.custom("Bitter", size: 52, relativeTo: .largeTitle))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .matchedGeometryEffect(id: "timerText", in: namespace)
                    .padding(.bottom, 14)
                
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 20, height: 1)
                    
                    Text("Progresso do livro")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 20, height: 1)
                }
                .padding(.bottom, 10)
                
                progressBar
                    .padding(.bottom, 16)
                
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
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("ActionColor"))
                        .underline()
                }
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
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(70, geo.size.width * CGFloat(progress)))
                
                HStack {
                    Text(selectedBook?.bookTitle ?? "Sem livro")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.black.opacity(0.85))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("ActionColor"))
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(height: 30)
    }
}
