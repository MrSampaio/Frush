//
//  ProgressBookView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI

struct ProgressBookView: View {
    var currentPage: Int
    var totalPages: Int
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "book.fill")
                .font(.system(size: 40))
                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("fazer Logica")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1))
                
                Text("nesta semana")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.8))
            }
            Spacer()
        }
        .padding(24)
        .background(Color(.yellow))
        .opacity(0.9)
        .cornerRadius(20)
    }
}
#Preview {
    ProgressBookView(currentPage: 10, totalPages: 100)
}
