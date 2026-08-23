//
//  MyNotesTollBar.swift
//  CH4-Books
//
//  Created by Lucas on 19/08/26.
//

import SwiftUI

struct MyNotesToolBar: ToolbarContent {
    var onBackClick: () -> Void
    var onAddClick: () -> Void
    
    var body: some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                onBackClick()
            }) {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .buttonBorderShape(.circle)
            .tint(Color.white.opacity(0.2))
        }
        
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
        
//        ToolbarItem(placement: .topBarTrailing) {
//            Button(action: {
//                onAddClick()
//            }) {
//                Image(systemName: "plus")
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//            }
//            .tint(Color("ActionColor"))
//            .buttonStyle(.glass)
//            .buttonBorderShape(.circle)
//        }
    }
}

