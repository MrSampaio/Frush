//
//  EditDailyGoalSheet.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//

import SwiftUI
struct BottomSheet: View {
    @Binding var minutesPerDay: Int
    @State private var showAlert = false
    var isPickerShown: Bool = false
    var maxPages: Int16? = nil
    var allowDismissWhenEmpty: Bool = true
    
    @Binding var readedPages: String
    
    @State private var showCustomDiscardAlert = false
    //@State var mimMinute: Int = 0
    private var minMinuteAllowed: Int {
        hours == 0 ? 1 : 0
    }
    private var isPageValid: Bool {
        guard let maxPages else { return true }
        guard let page = Int16(readedPages), page > 0 else { return false }
        return page <= maxPages
    }

    var onDismiss: () -> Void = {}
    var onSave: () -> Void = {}

    private var hours: Int {
        minutesPerDay / 60
    }
    
    private var minutes: Int {
        minutesPerDay % 60
    }
    
    private var discardAlertMessage: String {
        allowDismissWhenEmpty
            ? "Tem certeza que deseja não colocar a última página lida? Se fizer isso, a página não será salva."
            : "Tem certeza que deseja não colocar a última página lida? Se fizer isso, seu tempo de leitura será desconsiderado e não pode ser recuperado."
    }
    private var discardAlertMessageButton: String {
        allowDismissWhenEmpty
            ? "Descartar alteração"
            : "Descartar tempo"
    }


    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isPickerShown {
                    VStack(spacing: 4) {
                        Text("Editar objetivo diário")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                        Text("Defina quantos minutos você\ndeseja ler por dia")
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    VStack(spacing: 0) {
                        Text("Tempo por dia")
                            .font(.callout)
                            .foregroundColor(.white)
                            .padding(.top, 12)
                        HStack(spacing: 0) {
                            Picker("Horas", selection: Binding(
                                get: { hours },
                                set: { newHours in
                                    var newMinutes = minutes
                                            if newHours == 0 && newMinutes == 0 {
                                                newMinutes = 1
                                            }
                                    minutesPerDay = (newHours * 60) + minutes }
                            )) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text("\(hour) h").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            
                            Picker("Minutos", selection: Binding(
                                get: { minutes },
                                set: { newMinutes in minutesPerDay = (hours * 60) + newMinutes }
                            )) {
                                ForEach(minMinuteAllowed..<60, id: \.self) { minute in
                                    Text("\(minute) min").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .frame(height: 120)
                        .padding(.horizontal, 8)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("LinesColor"), lineWidth: 0.3)
                    )
                    Spacer()
                } else {
                    VStack(spacing: 4) {
                        Text("Adicionar leitura do livro")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                        Text("Qual foi a última página lida?")
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    VStack(spacing: 0) {
                        TextFieldSheets(text: $readedPages, placeholder: "Informe a última página lida")
                            .keyboardType(.numberPad)
                        
                        if let maxPages, !readedPages.isEmpty, !isPageValid {
                            Text("Informe um número entre 1 e \(maxPages).")
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal, 20)
            .toolbar {
                if isPickerShown {
                    SheetHeaderView(
                        title: "",
                        actionIcon: "checkmark",
                        hasChanges: false,
                        showingDiscardAlert: $showAlert,
                        onCancel: { onDismiss() },
                        onConfirm: { onSave() },
                        onDiscard: { onDismiss() }
                    )
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showCustomDiscardAlert = true
                        }) {
                            Image(systemName: "xmark")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                    }
                    
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            onSave()
                        }) {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                                .font(.body.bold())
                                .foregroundColor(.title)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .tint(Color("ActionColor"))
                        .disabled(!isPageValid)
                        .opacity(isPageValid ? 1 : 0.4)
                    }
                    
                    
                }
            }
            .interactiveDismissDisabled(!isPickerShown && (!allowDismissWhenEmpty || !readedPages.isEmpty))

            
            .alert("Atenção", isPresented: $showCustomDiscardAlert) {
                Button("\(discardAlertMessageButton)", role: .destructive) {
                    onDismiss()
                }
                Button("Voltar", role: .cancel) { }
            } message: {
                Text("\(discardAlertMessage)")
            }
        }
    }
}

#Preview("Edit Daily Goal - SheetHeaderView") {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        @State private var goalMinutes = 15 // exemplo 0h 15min
        @State private var tempPages = ""

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                Button("Abrir Sheet") {
                    isPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $isPresented) {
                BottomSheet(
                    minutesPerDay: $goalMinutes,
                    isPickerShown: true,
                    readedPages: $tempPages,
                    onDismiss: { isPresented = false },
                    onSave: { isPresented = false }
                )
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color("BackgroundColorViews"))
            }
        }
    }

    return PreviewWrapper()
}
