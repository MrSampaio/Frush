//
//  EditDailyGoalSheet.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//
import SwiftUI

struct EditDailyGoalContent: View {
    // binding atualizado para representar o tempo total em minutos
    @Binding var minutesPerDay: Int
    @State private var showAlert = false
    var onDismiss: () -> Void = {}
    var onSave: () -> Void = {}

    // computadas locais para facilitar o bind das rodas do Picker
    private var hours: Int {
        minutesPerDay / 60
    }
    
    private var minutes: Int {
        minutesPerDay % 60
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Título e Subtítulo
                VStack(spacing: 4) {
                    Text("Editar objetivo diário")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)

                    Text("Defina quantos minutos você\ndeseja ler por dia")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // selector estilo cronômetro hrs e min
                VStack(spacing: 0) {
                    Text("Tempo por dia")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.top, 12)

                    HStack(spacing: 0) {
                        // picker de hrs
                        Picker("Horas", selection: Binding(
                            get: { hours },
                            set: { newHours in
                                minutesPerDay = (newHours * 60) + minutes
                            }
                        )) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour) h").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)

                        // picker de mins
                        Picker("Minutos", selection: Binding(
                            get: { minutes },
                            set: { newMinutes in
                                minutesPerDay = (hours * 60) + newMinutes
                            }
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal, 20)
            .toolbar {
                SheetHeaderView(
                    title: "",
                    actionIcon: "checkmark",
                    hasChanges: false,
                    showingDiscardAlert: $showAlert,
                    onCancel: { onDismiss() },
                    onConfirm: { onSave() },
                    onDiscard: { onDismiss() }
                )
            }
        }
    }
}

#Preview("Edit Daily Goal - SheetHeaderView") {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        @State private var goalMinutes = 15 // exemplo 0h 15min

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                Button("Abrir Sheet") {
                    isPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $isPresented) {
                EditDailyGoalContent(
                    minutesPerDay: $goalMinutes,
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
