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
    
    // View Models necessários para a NoteSheetView
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    //bindign para receber o livro
    @Binding var selectedBook: Books?
    
    @State private var isShowingNoteSheet = false
    @State private var isShowingSelectBookSheet = false
    @State private var isShowingTimerPicker = false
    @State private var isShowingNoBookAlert = false
    @State private var tempReadedPages: String = ""
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var selectedDuration: TimeInterval = 15 * 60
    
    private var buttonTitle: String {
        switch stopwatchViewModel.timerState {
        case .running:
            return "Pausar leitura"
        case .paused:
            return "Continuar leitura"
        case .stopped:
            return "Iniciar leitura"
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color("BackgroundColorViews")
                        .ignoresSafeArea()
                    
                    // Fundo com a capa do livro e gradiente
                    //modificado para colocar a capa do livro selecionado
                    Group {
                                            if let imageData = selectedBook?.bookCover, let uiImage = UIImage(data: imageData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                            } else {
                                                Image("defaultBook")
                                                    .resizable()
                                            }
                                        }                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.40)
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
                                        // mostrar capa do livro selecionado no seletor
                                                                                if let imageData = selectedBook?.bookCover, let uiImage = UIImage(data: imageData) {
                                                                                    Image(uiImage: uiImage)
                                                                                        .resizable()
                                                                                        .scaledToFill()
                                                                                        .frame(width: 40, height: 40)
                                                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                } else {
                                                                                    Image(systemName: "book.closed.fill")
                                                                                        .resizable()
                                                                                        .scaledToFit()
                                                                                        .frame(width: 40, height: 40)
                                                                                        .foregroundColor(.white.opacity(0.7))
                                                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                        .padding(.leading, 8)
                                                                                }
                                        //exibindo dinamicamente o titulo do livro
                                        VStack(alignment: .leading, spacing: 3) {
                                                                                    Text(selectedBook?.bookTitle ?? "Nenhum livro selecionado")
                                                                                        .font(.body)
                                                                                        .fontWeight(.semibold)
                                                                                        .foregroundColor(.white)
                                                                                        .lineLimit(1)
                                                                                    
                                                                                    Text(selectedBook?.bookAuthor ?? "Toque para selecionar")
                                                                                        .font(.system(size: 13))
                                                                                        .foregroundColor(Color.white.opacity(0.8))
                                                                                        .lineLimit(1)
                                                                                }
                                        /*
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
                                         */
                                        //------------------comentando codigo de capa antigo------------------
//                                        if let imageData = userSettingsViewModel.lastBookReaded?.bookCover, let uiImage = UIImage(data: imageData) {
//                                            Image(uiImage: uiImage)
//                                                .resizable()
//                                                .scaledToFill()
//                                                .frame(width: 40, height: 40)
//                                                .clipShape(RoundedRectangle(cornerRadius: 8))
//                                        } else {
//                                            Image(systemName: "book.closed.fill")
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 40, height: 40)
//                                                .foregroundColor(.white.opacity(0.7))
//                                                .clipShape(RoundedRectangle(cornerRadius: 8))
//                                                .padding(.leading, 8)
//                                        }
                                        //------------------comentando codigo de titulo antigo------------------

//                                        VStack(alignment: .leading, spacing: 3) {
//                                            Text(userSettingsViewModel.lastBookReaded?.bookTitle ?? "Nenhum livro selecionado")
//                                                .font(.body)
//                                                .fontWeight(.semibold)
//                                                .foregroundColor(.white)
//                                                .lineLimit(1)
//                                            
//                                            Text(userSettingsViewModel.lastBookReaded?.bookAuthor ?? "Toque para selecionar")
//                                                .font(.system(size: 13))
//                                                .foregroundColor(Color.white.opacity(0.8))
//                                                .lineLimit(1)
//                                        }
                                        
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
                            //livro selecionado progresso verificar funcionamento
                            if let existingBook = selectedBook {
                                //  Progresso do Livro
                                VStack(spacing: 10) {
                                    HStack {
                                        Text("Progresso do livro")
                                            .font(.body)
                                            .foregroundColor(.white)
                                        Text("\(Int(stopwatchViewModel.getBookProgress(book: existingBook) * 100))%")
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
                                                .frame(width: barGeo.size.width * CGFloat(stopwatchViewModel.getBookProgress(book: existingBook)))
                                        }
                                    }
                                    .frame(height: 10)
                                    .padding(.horizontal, 28)
                                }
                            }

                            
                           
                            VStack(spacing: 12) {
                                // botão Principal: Iniciar / Pausar / Continuar
                                ButtonAction(text: buttonTitle, colorButton: "ActionColor"){
                                    guard selectedBook != nil else {
                                        isShowingNoBookAlert = true
                                        return
                                    }
                                    
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
                        }
                        
                        Spacer()
                    }
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
                
                .sheet(isPresented: $isShowingNoteSheet) {
                    if let currentBook = selectedBook {
                        NoteSheetView(book: currentBook)
                    }
                }
                .alert("Atenção", isPresented: $isShowingNoBookAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Selecione um livro antes de adicionar uma anotação.")
                }
                
                .sheet(isPresented: $isShowingSelectBookSheet) {
                    SelectBookSheetView(selectedBook: self.$selectedBook)
                        .environmentObject(self.booksViewModel)
                }

                .sheet(isPresented: $isShowingTimerPicker) {
                    VStack(spacing: 20) {
                        HStack(spacing: 0) {
                            // Picker de Horas
                            Picker("Horas", selection: Binding(
                                get: { Int(selectedDuration) / 3600 },
                                set: { newHours in
                                    let currentMinutes = (Int(selectedDuration) % 3600) / 60
                                    
                                    // Separado para o compilador não chorar
                                    let hoursInSeconds = Double(newHours * 3600)
                                    let minutesInSeconds = Double(currentMinutes * 60)
                                    let newTotal = hoursInSeconds + minutesInSeconds
                                    
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
                                    
                                    // Separado para o compilador não chorar
                                    let hoursInSeconds = Double(currentHours * 3600)
                                    let minutesInSeconds = Double(newMinutes * 60)
                                    let newTotal = hoursInSeconds + minutesInSeconds
                                    
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
                
                .sheet(isPresented: $stopwatchViewModel.showProgressSheet) {
                    if let currentBook = selectedBook {
                        BottomSheet(
                            minutesPerDay: .constant(0),
                            isPickerShown: false,
                            readedPages: $tempReadedPages,
                            onDismiss: {
                                stopwatchViewModel.showProgressSheet = false
                            },
                            onSave: {
                                if let newPage = Int16(tempReadedPages) {
                                    currentBook.bookCurrentPage = newPage
                                    
                                    do {
                                        try booksViewModel.saveBook()
                                    } catch let error as LocalizedError {
                                        errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                                        showErrorAlert = true
                                    } catch {
                                        errorMessage = "Erro inesperado."
                                        showErrorAlert = true
                                    }
                                }
                                
                                let minutesRead = Int(stopwatchViewModel.totalTime / 60)
                                userSettingsViewModel.addCompletedReadingTime(minutes: minutesRead)
                                
                                booksViewModel.fetchBooks()
                                tempReadedPages = ""
                                stopwatchViewModel.showProgressSheet = false
                            }
                        )
                        .presentationDetents([.height(340)])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Color("BackgroundColorViews"))
                    }
                }
                
                .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
                    Button("Tentar novamente", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                
                .onAppear {
                    booksViewModel.fetchBooks()
                    userSettingsViewModel.fetchUserSettings()
                    
                    if selectedBook == nil {
                        selectedBook = userSettingsViewModel.lastBookReaded
                    }
                    
                    if let safeBook = selectedBook {
                        stopwatchViewModel.getTotalPages(book: safeBook)
                        stopwatchViewModel.getCurrentPage(book: safeBook)
                    }
                }
                //utilizado para atualizar o cronometro caso haja modificacoes 
                .onChange(of: selectedBook) { newBook in
                                    if let safeBook = newBook {
                                        stopwatchViewModel.getTotalPages(book: safeBook)
                                        stopwatchViewModel.getCurrentPage(book: safeBook)
                                    }
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
        .environmentObject(UserSettingsViewModel())
        .environmentObject(StopwatchViewModel())
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(NotesViewModel())
}
