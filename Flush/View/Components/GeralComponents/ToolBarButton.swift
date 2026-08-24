//
//  StopwatchToolbar.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

//
//  StopwatchToolbar.swift
//  CH4-Books
//

import SwiftUI

struct ToolBarButton: ToolbarContent {
    var action: () -> Void
    var icon: String
    var colorName: String?

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            
            Button(action: {
                action()
            }) {
                Image(systemName: icon)
                        .font(icon == "square.and.pencil" ? .body : .body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.bottom, icon == "square.and.pencil" ? 5 : 0)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(colorName != nil ? Color(colorName!) : Color(""))
            
          
        }
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
            .toolbar {
                ToolBarButton(action: {}, icon: "square.and.pencil")
            }
    }
    .preferredColorScheme(.dark)
}
