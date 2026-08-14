//
//  SheetHeaderView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 14/08/26.
//
 
import SwiftUI

struct SheetHeaderView: View {
    let title: String
    let actionIcon: String
    
    //acoes passadas por quen chamar o componente
    var onCancel: () -> Void
    var onAction: () -> Void
  
    var body: some View {
        HStack {
            //botão de cancelar
            Button(action: onCancel){
                Image(systemName: "xmark")
                    .font(.body.bold())
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            //titulo
            Text(title)
                .font(.title2)
                .bold()
            
            Spacer()
            
            //botão de ação
            Button(action: onAction){
                Image(systemName: actionIcon)
                    .font(.body.bold())
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(Circle())
            }
            
        }
        .padding(.horizontal)
        .padding(.top)
        
    }
}


#Preview {
    SheetHeaderView (
        title: "Cadastrar Livro",
        actionIcon: "checkmark",
        onCancel: {
            print("Clicou no X")
        },
        onAction: {
            print("Clicou no Check")
        }
    )
    
}
 
