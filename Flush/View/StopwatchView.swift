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
    @State private var progress: Double = 0.5
        
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Cronômetro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    isShowingSheet.toggle()
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title3)
                        .padding(12)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $isShowingSheet) {
                            SheetNotes()
                        }
            }
            .padding(.top)

            Spacer()

            Text(stopwatchViewModel.timerFormater())
                .font(.system(size: 64, weight: .regular))

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("Progresso do livro")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ProgressView(value: progress)
                    .tint(.orange)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Selecione o livro")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(selectedBook)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }

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
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding(.vertical, 8)

        }
        .padding(.horizontal)
    }
}

#Preview {
    StopwatchView()
        .preferredColorScheme(.dark)
        .environmentObject(StopwatchViewModel())
        .environmentObject(PhotoLibraryViewModel())
}
