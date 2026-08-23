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
    @State var isPickerShown: Bool = false
    
    @Binding var readedPages: String
    
    @State private var showCustomDiscardAlert = false
    
    var onDismiss: () -> Void = {}
    var onSave: () -> Void = {}

    private var hours: Int {
        minutesPerDay / 60
    }
    
    private var minutes: Int {
        minutesPerDay % 60
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
                                set: { newHours in minutesPerDay = (newHours * 60) + minutes }
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
                                ForEach(0..<60, id: \.self) { minute in
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
//                        .foregroundColor(Color("ActionColor"))
//                        Button("Cancelar") {
//                            
//                        }
                        
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            onSave()
                        }) {
                            Image(systemName: "checkmark")
                                .fontWeight(.bold)
                                .foregroundColor(Color("ActionColor"))
                        }
                        .tint(Color("ActionColor"))
                    }
                }
            }
            .interactiveDismissDisabled(!isPickerShown)
            
            .alert("Atenção", isPresented: $showCustomDiscardAlert) {
                Button("Descartar tempo", role: .destructive) {
                    onDismiss()
                }
                Button("Voltar", role: .cancel) { }
            } message: {
                Text("Tem certeza que deseja não colocar a última página lida? Se fizer isso, seu tempo de leitura será desconsiderado e não pode ser recuperado.")
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
