//
//  BooksDetailsToolbar.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 18/08/26.
//

import Foundation

import SwiftUI

struct BooksDetailsToolbar: ToolbarContent {
    
    var onEdit: () -> Void
  
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
               onEdit()
            }) {
                Image(systemName: "pencil")
                    
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color("ActionColor"))
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
                        BooksDetailsToolbar(onEdit: {})
                    }
            }
        }
    }
    
    return PreviewWrapper()
}
