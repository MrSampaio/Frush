//
//  StopWatchView.swift
//  CH4-Books
//
//  Created by Lucas on 15/08/26.
//

import SwiftUI

    
struct StopwatchView: View {
    @State private var selectedBook = "Livro 1"
    @State private var isShowingSheet = false
    @EnvironmentObject var stopwatchViewModel: StopwatchViewModel
    //@State private var progress: Double = 0.5
    
    var body: some View {

        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.49
            let cardHeight = geometry.size.height * 0.38
            
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                // 10 Anéis Concentricos ao Fundo
                ConcentricRingsView(progress: stopwatchViewModel.timeProgress)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    //card central
                    VStack (spacing: 24){
                        
                        Text(stopwatchViewModel.timerFormater())
                            .font(.custom("Bitter", size: 70, relativeTo: .largeTitle))
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .monospacedDigit()
                        
                        //progresso do livro
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Text("Progresso do livro")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .fontWeight(.regular)
                                
                                Text("\(Int(stopwatchViewModel.bookProgress * 100))%")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("ProgressBar"))
                            }
                            
                            ProgressView(value: stopwatchViewModel.bookProgress)
                                .tint(Color("ProgressBar"))
                                .frame(width: 170)
                            
                        }
                        
                        //seleção do livro
                        VStack(spacing: 6) {
                            Text("Selecione o livro")
                                .font(.subheadline)
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                            
                            Menu {
                                Picker("Selecione o livro", selection: $selectedBook){
                                    Text("Livro 1").tag("Livro 1")
                                    Text("Livro 2").tag("Livro 2")
                                    Text("Livro 3").tag("Livro 3")
                                }
                            } label: {
                                Text(selectedBook)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            
                            //botao inciar
                            Button(action: {
                                
                                stopwatchViewModel.isRunning.toggle()
                                
                                if stopwatchViewModel.isRunning {
                                    stopwatchViewModel.start()
                                    
                                }
                                else{
                                    stopwatchViewModel.stop()
                                }
                                
                               
                            }) {
                                Text(stopwatchViewModel.isRunning ? "Parar" : "Iniciar")
                                    .font(.title3)
                                    .frame(maxWidth: .infinity)
                                    .fontWeight(.medium)
                                    .padding(.vertical, 14)
                                    .background(
                                        Group {
                                            if stopwatchViewModel.isRunning {
                                                Color.red.opacity(0.85)
                                            } else {
                                                Color("ActionColor")
                                            }
                                        }
                                    )
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            
                        }
                    }
                    .frame(width: cardWidth, height: cardHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 64, style: .continuous)
                            .fill(Color("BackgroundColorViews"))
                    )
                    .padding(.bottom, 26)
                    Spacer()
                    
                }
                .padding(.horizontal)
            }
            //botao de editar (top bar)
            .overlay(
                HStack {
                    Button(action: {
                        isShowingSheet.toggle()
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color("TitleColor"))
                            .frame(width: 48, height: 48)
                            .background(Color("ActionColor").opacity(0.8), in: Circle())
                    }
                    .glassEffect(.regular, in: Circle())
                    .sheet(isPresented: $isShowingSheet) {
                        SheetNotes()
                    }
                    
                    
                }
                .padding(.horizontal, 24)
                .padding(.top, geometry.safeAreaInsets.top > 0 ? 8 : 16),
                alignment: .topTrailing

            )
           
        }
    }
}

#Preview {
    StopwatchView()
        .preferredColorScheme(.dark)
        .environmentObject(StopwatchViewModel())
        .environmentObject(PhotoLibraryViewModel())
}
