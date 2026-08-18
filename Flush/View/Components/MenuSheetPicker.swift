//
//  MenuSheetPicker.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 16/08/26.
//

import SwiftUI

struct MenuSheetPicker: View {
    var title: String? = nil
    var placeholder: String
    @Binding var selectedValue: String
    var options: [String]
    var formatOption: (String) -> String = { $0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.leading, 4)
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(formatOption(option)) {
                        selectedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selectedValue.isEmpty ? placeholder : formatOption(selectedValue))
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(selectedValue.isEmpty ? .white.opacity(0.7) : .white)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white)
                }
                .padding()
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
