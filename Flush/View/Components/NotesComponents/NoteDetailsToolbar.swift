//
//  NoteDetailsToolbar.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 20/08/26.
//

import Foundation
import SwiftUI

struct NoteDetailsToolbar: ToolbarContent {
    var title: String
//    var hasReturn: Bool
    //var onClose: () -> Void
    var onEdit: () -> Void
    
    
    var body: some ToolbarContent {
//        if hasReturn{
//            ToolbarItem(placement: .topBarLeading) {
//                Button(action: {
////                    dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                }
//                .buttonStyle(.plain)
//                .buttonBorderShape(.circle)
//                .tint(Color.white.opacity(0.2))
//            }
//        }
        
        
        ToolbarItem(placement: .principal) {
            Text(title)
                .foregroundColor(Color("LinesColor"))
                .font(.bitter(.semibold, style: .title2))
        }
        
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
