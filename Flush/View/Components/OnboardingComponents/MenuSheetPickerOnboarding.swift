//
//  MenuSheetPickerOnboarding.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//

import SwiftUI

struct MenuSheetPickerOnboarding: View {
    var title: String? = nil
    var placeholder: String
    
    @Binding var selectedTotalMinutes: Int?

    @State private var isShowingSheet = false
    @State private var tempHours: Int = 0
    @State private var tempMinutes: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(Color("LinesColor"))
                    .padding(.leading, 4)
            }

            Button {
                if let total = selectedTotalMinutes {
                    tempHours = total / 60
                    tempMinutes = total % 60
                } else {
                    tempHours = 0
                    tempMinutes = 0
                }
                isShowingSheet = true
            } label: {
                HStack {
                    Text(formattedDuration)
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(selectedTotalMinutes == nil ? Color("TextFieldPlaceholderColor") : .white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("ActionColor"))
                }
                .padding()
                .background(
                    Capsule()
                        .fill(Color("StopwatchSelectors").opacity(0.20))
                )
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color("LinesColor"), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $isShowingSheet) {
            pickerSheetContent
        }
    }

    private var pickerSheetContent: some View {
        NavigationView {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Picker("Horas", selection: $tempHours) {
                        ForEach(0..<24) { i in
                            Text("\(i) h").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: geometry.size.width / 2)
                    .clipped()

                    Picker("Minutos", selection: $tempMinutes) {
                        ForEach(0..<60) { i in
                            Text("\(i) m").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: geometry.size.width / 2)
                    .clipped()
                }
            }
            .navigationTitle(title ?? "Duração")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isShowingSheet = false
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Concluir") {
                        // Apenas salva e fecha o Picker
                        selectedTotalMinutes = (tempHours * 60) + tempMinutes
                        isShowingSheet = false
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.height(300), .medium])
    }

    private var formattedDuration: String {
        guard let total = selectedTotalMinutes else { return placeholder }
        let h = total / 60
        let m = total % 60
        
        if h > 0 && m > 0 {
            return "\(h)h \(m)m"
        } else if h > 0 {
            return "\(h)h"
        } else {
            return "\(m)m"
        }
    }
}
