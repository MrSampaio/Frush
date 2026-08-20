//
//  StopwatchInicialView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI

struct StopwatchInitialView: View {
    var namespace: Namespace.ID
    @EnvironmentObject var stopwatchViewModel: StopwatchViewModel
    
    @Binding var selectedBook: Books?
    
    @State private var isShowingNoteSheet = false
    @State private var isShowingSelectBookSheet = false
    @State private var isShowingTimerPicker = false
    
    @State private var selectedDuration: TimeInterval = 15 * 60

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color("BackgroundColorViews")
                        .ignoresSafeArea()
                    
                    // Fundo com a capa do livro e gradiente
                    Group {
                        if let imageData = selectedBook?.bookCover, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                        } else {
                            Image("bookTest2")
                                .resizable()
                        }
                    }
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.20)
                    .overlay(
                        ZStack {
                            Color("BackgroundColorViews").opacity(0.70)
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color("BackgroundColorViews").opacity(0.80),
                                    Color("BackgroundColorViews")
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                    )
                    .clipped()
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // Campo de Seleção do Tempo
                        VStack(spacing: 8) {
                            Text("Selecione o tempo de leitura")
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                isShowingTimerPicker = true
                            }) {
                                Text(stopwatchViewModel.timerFormater())
                                    .font(.custom("Bitter", size: 60, relativeTo: .largeTitle))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                                    .matchedGeometryEffect(id: "timerText", in: namespace)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        ZStack {
                                            // vidro claro (branco a 20%)
                                            RoundedRectangle(cornerRadius: 100, style: .continuous)
                                                .fill(Color("StopwatchSelectors").opacity(0.2))
                                        }
                                    )
                                    .overlay(
                                        // borda reluzente com brilho no topo
                                        RoundedRectangle(cornerRadius: 100, style: .continuous)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 0.5
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Card de Seleção do Livro
                        VStack(spacing: 24) {
                            VStack(spacing: 8) {
                                Text("Selecione o livro")
                                    .font(.body)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    isShowingSelectBookSheet = true
                                }) {
                                    HStack(spacing: 12) {
                                        if let imageData = selectedBook?.bookCover, let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 52)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } else {
                                            Image("defaultBook")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 52)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .padding(.leading, 8)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(selectedBook?.bookTitle ?? "Hush, Hush")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            Text(selectedBook?.bookAuthor ?? "Becca Fitzpatrick")
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.white.opacity(0.8))
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        ZStack {
                                            // vidro claro
                                            RoundedRectangle(cornerRadius: 100, style: .continuous)
                                                .fill(Color("StopwatchSelectors").opacity(0.20))
                                        }
                                    )
                                    .overlay(
                                        // Borda reluzente
                                        RoundedRectangle(cornerRadius: 100, style: .continuous)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 0.5
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            //  Progresso do Livro
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Progresso do livro")
                                        .font(.body)
                                        .foregroundColor(.white)
                                    Text("\(Int(stopwatchViewModel.bookProgress * 100))%")
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("ActionColor"))
                                }
                                
                                GeometryReader { barGeo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.15))
                                        Capsule()
                                            .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                                            .frame(width: barGeo.size.width * CGFloat(stopwatchViewModel.bookProgress))
                                    }
                                }
                                .frame(height: 10)
                                .padding(.horizontal, 28)
                            }
                            
                           
                            VStack(spacing: 12) {
                                // botão Principal: Iniciar / Pausar / Continuar
                                ButtonAction(text: buttonTitle){
                                    if stopwatchViewModel.timerState == .running {
                                        stopwatchViewModel.pauseTimer()
                                    } else {
                                        stopwatchViewModel.startTimer()
                                    }
                                }
                                .padding(.top, 8)

                                // botão Secundário: abandonar Leitura (exibido apenas se a leitura começou ou está pausada)
                                if stopwatchViewModel.timerState != .stopped {
                                    Button(action: {
                                        stopwatchViewModel.abandonTimer()
                                    }) {
                                        Text("Abandonar leitura")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.red)
                                            .padding(.vertical, 8)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Computada auxiliar para o rótulo do botão
                            var buttonTitle: String {
                                switch stopwatchViewModel.timerState {
                                case .running:
                                    return "Pausar leitura"
                                case .paused:
                                    return "Continuar leitura"
                                case .stopped:
                                    return "Iniciar leitura"
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                .toolbar {
                    ToolBarButton(
                        action: { isShowingNoteSheet = true },
                        icon: "note.text.badge.plus"
                    )
                }
                .sheet(isPresented: $isShowingNoteSheet) {
                    if let currentBook = selectedBook {
                        NoteSheetView(book: currentBook)
                    } else {
                        VStack(spacing: 12) {
                            Text("Atenção")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Selecione um livro antes de adicionar uma anotação.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .presentationDetents([.height(180)])
                    }
                }
                .sheet(isPresented: $isShowingSelectBookSheet) {
                    SelectBookSheetView(selectedBook: $selectedBook)
                }

                .sheet(isPresented: $isShowingTimerPicker) {
                    VStack(spacing: 20) {
                        HStack(spacing: 0) {
                            // Picker de Horas
                            Picker("Horas", selection: Binding(
                                get: { Int(selectedDuration) / 3600 },
                                set: { newHours in
                                    let currentMinutes = (Int(selectedDuration) % 3600) / 60
                                    let newTotal = TimeInterval((newHours * 3600) + (currentMinutes * 60))
                                    selectedDuration = newTotal
                                    stopwatchViewModel.totalTime = newTotal
                                    stopwatchViewModel.elapsedTime = newTotal
                                }
                            )) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text("\(hour) h").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)

                            // Picker de Minutos
                            Picker("Minutos", selection: Binding(
                                get: { (Int(selectedDuration) % 3600) / 60 },
                                set: { newMinutes in
                                    let currentHours = Int(selectedDuration) / 3600
                                    let newTotal = TimeInterval((currentHours * 3600) + (newMinutes * 60))
                                    selectedDuration = newTotal
                                    stopwatchViewModel.totalTime = newTotal
                                    stopwatchViewModel.elapsedTime = newTotal
                                }
                            )) {
                                ForEach(0..<60, id: \.self) { minute in
                                    Text("\(minute) min").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .padding(.horizontal)

                        Button("Confirmar") {
                            isShowingTimerPicker = false
                        }
                        .font(.body.weight(.semibold))
                        .foregroundColor(Color("ActionColor"))
                        .padding(.bottom)
                    }
                    .presentationDetents([.height(260)])                 
                 
                }
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    @Previewable @State var selectedBook: Books? = nil
    
    StopwatchInitialView(namespace: namespace, selectedBook: $selectedBook)
        .preferredColorScheme(.dark)
        .environmentObject(StopwatchViewModel())
        .environmentObject(BooksViewModel.preview)
}

