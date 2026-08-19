//
//  ToolBarAddButton.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 16/08/26.
//

import Foundation
import SwiftUI

struct BookCaseToolbar: ToolbarContent {
    var onAddClick: () -> Void
  
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                onAddClick()
            }) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color("ActionColor"))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                //onAddClick()
            }) {
                Image(systemName: "ellipsis")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .buttonBorderShape(.circle)
            //.tint(Color("ActionColor"))
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showAlert = false
        
        var body: some View {
            NavigationStack {
                Text("Conteúdo da sua Sheet aqui")
                    .toolbar {
                        BookCaseToolbar (
                            onAddClick: { print("Clicou no add") },
                        )
                    }
            }
        }
    }
    
    return PreviewWrapper()
}

