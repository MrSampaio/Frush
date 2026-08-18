//
//  CardTotalPages.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 18/08/26.
//

import Foundation
import SwiftUI

struct CardTotalPages: View {
    let totalPages: Int
    
    var body: some View {

        HStack {
            Image("BookPagesReadCard")
                .resizable()
                .scaledToFit()
                .frame(width: 98, height: 51)
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 4){
                Text("\(totalPages) páginas lidas")
                    .font(.bitter(.bold, style: .title3))
                    .foregroundStyle(Color.black)
                
                Text(" neste mês")
                    .font(.bitter(.regular, style: .footnote))
                    .foregroundStyle(Color.black)
            }
            
            Spacer()
            
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color("PagesReadCard2"),
                    Color("PagesReadCard1")
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        
    }
}

#Preview {
    CardTotalPages(totalPages: 100)
}
