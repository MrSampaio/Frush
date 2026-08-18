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
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                isPresentedAddNote = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
//                    .frame(width: 36, height: 36)
                    //.background(Color(.orange))
                    .clipShape(Circle())
                    
            }
            .tint(Color(.orange))
            .background(Color(.orange))
            .clipShape(Circle())
            //.padding()
            .buttonStyle(.glass)
            
        }
    }
}
#Preview {
    NotesHeaderview(isPresentedAddNote: .constant(false))
}
