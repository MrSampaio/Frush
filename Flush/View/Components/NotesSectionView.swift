//
//  teste.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//
import SwiftUI
import CoreData

struct NotesSectionView: View {
    var notes: [Notes]
    
    var body: some View {
        VStack(spacing: 0) {
            NoteRowView(title: "Sociedade", subtitle: "Esse livro fala como a...", isLast: false)
            NoteRowView(title: "Homem", subtitle: "O homem em sociedade...", isLast: false)
            NoteRowView(title: "José Saramago", subtitle: "Esse autor é sensacional...", isLast: true)
        }
        .background(Color(red: 0.16, green: 0.14, blue: 0.10))
        .cornerRadius(20)
    }
}

struct NoteRowView: View {
    var title: String
    var subtitle: String
    var isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding()
            
            if !isLast {
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 82) 
            }
        }
    }
}
