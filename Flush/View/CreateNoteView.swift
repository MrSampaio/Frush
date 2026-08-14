//
//  create-note-view.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 14/08/26.
//

import Foundation
import SwiftUI

struct CreateNoteView: View {
    var body: some View {
        Button(action: {
           
        }) {
            HStack {
                Text("Adicione uma foto")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "camera")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    CreateNoteView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
