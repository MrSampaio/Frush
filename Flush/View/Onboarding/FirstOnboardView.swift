//
//  FirstOnboardView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 17/08/26.
//

import SwiftUI

struct FirstOnboardView: View {
    var onAdvance: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            Image("OnboardingOficial")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black, location: 0.68),
                            .init(color: .clear, location: 0.52)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 16) {
                Spacer()
        
                Capsule()
                    .fill(Color("ProgressBar"))
                    .frame(width: 36, height: 4)
                    .padding(.top, 8)
                

                VStack(spacing: 2) {
                    Text("Bem-vindo(a)")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Text("ao")
                            .font(.largeTitle)
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                        
                        Text("Frush")
                            .font(.bitter(.bold, style: .largeTitle))
                            .foregroundColor(.white)
 
                    }
                }
                
                // Subtítulo com destaque final em amarelo
                (Text("Venha cadastrar seus livros, registrar suas notas de leitura e alcançar suas metas ")
                    .foregroundColor(.white.opacity(0.85)) +
                 Text("no seu próprio ritmo.")
                    .foregroundColor(Color("ProgressBar"))
                    .bold())
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                
                Spacer()
                
                ButtonAction(text: "Avançar", colorButton: "ActionColor"){
                    onAdvance?()
                }
                .padding(.bottom, 40)
                
            }
            .padding(.horizontal, 26)
            .padding(.top, 420)
        }
    }
}

#Preview {
    FirstOnboardView()
}
