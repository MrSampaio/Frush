//
//  CardTotalPages.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 18/08/26.
//

import Foundation
import SwiftUI

struct CardTotalPages: View {
    let totalPages: Int16
    
    var body: some View {

        HStack (spacing: 10) {
            Image("frush_logo_1x")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 52)
                .padding(.bottom, 10)
            
            VStack (alignment: .leading, spacing: 4){
                
                if totalPages >= 1 {
                    Text("\(totalPages) páginas lidas")
                        .font(.bitter(.bold, style: .headline))
                        .foregroundStyle(Color("ColorTextCard"))
                    
                    Text(" continue assim!")
                        .font(.bitter(.regular, style: .subheadline))
                        .foregroundStyle(Color("ColorTextCard"))
                } else {
                    Text("Novo hábito de leitura")
                        .font(.bitter(.bold, style: .headline))
                        .foregroundStyle(Color("ColorTextCard"))
                    
                    Text("Inicie agora mesmo!")
                        .font(.bitter(.regular, style: .subheadline))
                        .foregroundStyle(Color("ColorTextCard"))
                }
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
    CardTotalPages(totalPages: 0)
}
