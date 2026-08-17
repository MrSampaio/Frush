//
//  NotesHeaderview.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI

struct NotesHeaderview: View {
    var body: some View {
        HStack {
            Text("Anotações")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)    }
}

#Preview {
    NotesHeaderview()
}
