//
//  NotesHeaderview.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI

struct NotesHeaderview: View {
    @Binding var isPresentedAddNote: Bool
    var body: some View {
        HStack {
            Text("Anotações")
                .font(.bitter(.medium,style: .title3))
                .foregroundColor(Color("Texts"))
            Spacer()
            Button(action: {
                isPresentedAddNote = true
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.all, 4)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
        //.padding(.horizontal,24)
    }
}
#Preview {
    NotesHeaderview(isPresentedAddNote: .constant(false))
}
