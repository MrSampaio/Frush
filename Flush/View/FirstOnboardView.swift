//
//  FirstOnboardView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 17/08/26.
//

import SwiftUI

struct FirstOnboardView: View {
    var body: some View {
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                    Image("Onboarding")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    Text("Olá, seja bem-vindo(a)!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 30)
                        .multilineTextAlignment(.center)
                    
                    Rectangle()
                    .frame(width: 100, height: 2.5)
                        .foregroundColor(Color("ActionColor"))
                        .padding(.bottom, 30)
                    
                    Text("No Frush você consegue cadastrar seus livros, registrar seus momentos de leitura e alcançar suas metas no seu próprio ritmo.")
                        .font(.body)
                        .fontWeight(.light)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Spacer()
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Text("Avançar")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .fontWeight(.medium)
                            .padding(.vertical, 14)
                            .background(Color("ActionColor"))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 30)
                    
                }
                .padding(.horizontal, 26)
            }
        
       
    }
}

#Preview {
    FirstOnboardView()
}
