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
        VStack(alignment: .leading, spacing: 14) {
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.system(.title3, weight: .medium))
                    .foregroundColor(Color("LinesColor"))
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
                        .foregroundColor(selectedValue.isEmpty ? Color("TextFieldPlaceholderColor") : .white)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color("LinesColor"))
                }
                .padding()
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color("LinesColor"), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }
}



