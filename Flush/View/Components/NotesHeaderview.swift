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
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                // fazer logica de nota
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color(red: 0.89, green: 0.49, blue: 0.12)) // Laranja
                    .clipShape(Circle())
            }
        }
    }
}
