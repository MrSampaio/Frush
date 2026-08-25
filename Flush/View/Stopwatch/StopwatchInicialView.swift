//
//  StopwatchInitialView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI
import SwiftData

struct StopwatchInitialView: View {
    var namespace: Namespace.ID
    @Binding var selectedBook: Books?
    
    @EnvironmentObject var stopwatchViewModel: StopwatchViewModel
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var isShowingNoteSheet = false
    @State private var isShowingSelectBookSheet = false
    @State private var isShowingTimerPicker = false
    @State private var isShowingNoBookAlert = false
    
    @State private var selectedDuration: TimeInterval = 15 * 60
    
    private var pickedHours: Int {
        Int(selectedDuration) / 3600
    }
    
    private var pickedMinutes: Int {
        (Int(selectedDuration) % 3600) / 60
    }
    private var minMinuteAllowed: Int {
        pickedHours == 0 ? 1 : 0
    }
    
    
    private var timePickerSection: some View {
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
                    .background(timerCapsuleBackground)
                    .overlay(timerCapsuleBorder)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                backgroundWithGradient(geometry)
                
                VStack(spacing: 20) {
                    Spacer()
                    timePickerSection
                    
                    VStack(spacing: 24) {
                        bookSelectionButton
                        
                        if let existingBook = selectedBook {
                            bookProgressSection(existingBook)
                        }
                        
                        VStack(spacing: 12) {
                            ButtonAction(text: "Iniciar leitura", colorButton: "ActionColor"){
                                guard selectedBook != nil && stopwatchViewModel.timerFormater() != "00:00" else {
                                    isShowingNoBookAlert = true
                                    return
                                }
                                
                                stopwatchViewModel.startTimer()
                            }
                            .padding(.top, 8)
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
                Text("Selecione um livro e um tempo de leitura.")
            }
            
            .sheet(isPresented: $isShowingSelectBookSheet) {
                SelectBookSheetView(selectedBook: self.$selectedBook)
                    .environmentObject(self.booksViewModel)
            }
            
            .sheet(isPresented: $isShowingTimerPicker) {
                timerPickerSheet
            }
            
            .onAppear {
                booksViewModel.fetchBooks(context: modelContext)
                userSettingsViewModel.fetchUserSettings(context: modelContext)
                
                if selectedBook == nil {
                    selectedBook = userSettingsViewModel.lastBookReaded
                }
                
                if let safeBook = selectedBook {
                    stopwatchViewModel.getTotalPages(book: safeBook)
                    stopwatchViewModel.getCurrentPage(book: safeBook)
                }
            }
            // utilizado para atualizar o cronometro caso haja modificacoes
            .onChange(of: selectedBook) { _, newBook in
                if let safeBook = newBook {
                    stopwatchViewModel.getTotalPages(book: safeBook)
                    stopwatchViewModel.getCurrentPage(book: safeBook)
                }
            }
        }
    }
    
    var timerCapsuleBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 100, style: .continuous)
                .fill(Color("StopwatchSelectors").opacity(0.2))
        }
    }
    
    var timerCapsuleBorder: some View {
        RoundedRectangle(cornerRadius: 100, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.5
            )
    }
    
    var bookSelectionButton: some View {
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
                        RoundedRectangle(cornerRadius: 100, style: .continuous)
                            .fill(Color("StopwatchSelectors").opacity(0.20))
                    }
                )
                .overlay(
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
    }
    
    @ViewBuilder
    func bookProgressSection(_ book: Books) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("Progresso do livro")
                    .font(.body)
                    .foregroundColor(.white)
                Text("\(Int(stopwatchViewModel.getBookProgress(book: book) * 100))%")
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
                        .frame(width: barGeo.size.width * CGFloat(stopwatchViewModel.getBookProgress(book: book)))
                }
            }
            .frame(height: 10)
            .padding(.horizontal, 28)
        }
    }
    
    func backgroundWithGradient(_ geometry: GeometryProxy) -> some View {
        Group {
            if let imageData = selectedBook?.bookCover, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                Image("defaultBook")
                    .resizable()
            }
        }
        .scaledToFill()
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
    }
    
    private var timerPickerSheet: some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                Picker("Horas", selection: Binding(
                    get: { Int(selectedDuration) / 3600 },
                    set: { newHours in
                        var newMinutes = pickedMinutes          // era: let currentMinutes = (Int(selectedDuration) % 3600) / 60
                        if newHours == 0 && newMinutes == 0 {   // ← linha nova
                            newMinutes = 1                       // ← linha nova
                        }
                        let newTotal = Double(newHours * 3600) + Double(newMinutes * 60)  // era "currentMinutes"
                        selectedDuration = newTotal
                        stopwatchViewModel.setDuration(newTotal)
                    }
                    
                )) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text("\(hour) h").tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                
                Picker("Minutos", selection: Binding(
                    get: { (Int(selectedDuration) % 3600) / 60 },
                    set: { newMinutes in
                        let newTotal = Double(pickedHours * 3600) + Double(newMinutes * 60)
                        selectedDuration = newTotal
                        stopwatchViewModel.setDuration(newTotal)
                    }
                )) {
                    ForEach(minMinuteAllowed..<60, id: \.self) { minute in
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
#Preview {
    struct PreviewWrapper: View {
        // 1. Criando a Namespace para a animação
        @Namespace var namespace
        
        // 2. Estado local para o Binding
        @State private var mockSelectedBook: Books? = nil
        
        // 3. Instanciando todas as dependências (ViewModels)
        @StateObject private var stopwatchVM = StopwatchViewModel()
        @StateObject private var photoLibraryVM = PhotoLibraryViewModel()
        @StateObject private var booksVM = BooksViewModel()
        @StateObject private var notesVM = NotesViewModel()
        @StateObject private var userSettingsVM = UserSettingsViewModel()
        
        var body: some View {
            StopwatchInitialView(
                namespace: namespace,
                selectedBook: $mockSelectedBook
            )
            // 4. Injetando os EnvironmentObjects
            .environmentObject(stopwatchVM)
            .environmentObject(photoLibraryVM)
            .environmentObject(booksVM)
            .environmentObject(notesVM)
            .environmentObject(userSettingsVM)
            
            // 5. Injetando o contexto do SwiftData em memória RAM para o Preview não crashar
            // ATENÇÃO: Substitua os nomes das classes dentro da array caso não sejam exatamente esses
            .modelContainer(for: [Books.self], inMemory: true)
        }
    }
    
    return PreviewWrapper()
}
