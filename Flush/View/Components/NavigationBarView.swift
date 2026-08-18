//
//  NavigationBarView.swift
//  CH4-Books
//
//  Created by Lucas on 14/08/26.
//

import SwiftUI

struct NavigationBarView: View {
    var body: some View {
                
            HStack {
                
                Button(action: {
                    // Ação do botão
                }) {
                    Image(systemName: "xmark")
                        .font(.system(.title, weight: .semibold))
                        .foregroundStyle(Color("TitleColor"))
                        .frame(width: 48, height: 48)
                        .background(Color.black.opacity(0.3), in: Circle())
                }
                .glassEffect(.regular, in: Circle())
                
                Spacer()
                
                Text("Adicionar nota")
                    .font(.bitter(.semibold, style: .title))
                    .foregroundStyle(Color("TitleColor"))
                
                Spacer()
                
                
                Button(action: {
                    // Ação do botão
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(.title, weight: .semibold))
                        .foregroundStyle(Color("TitleColor"))
                        .frame(width: 48, height: 48)
                        .background(Color("ActionColor").opacity(0.8), in: Circle())
                }
                .glassEffect(.regular, in: Circle())
            }
            .background(Color("BackgroundColorViews"))
        }
    }

#Preview {
    NavigationBarView()
}
