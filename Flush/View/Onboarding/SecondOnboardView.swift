//
//  SecondOnboardView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 17/08/26.
//

import SwiftUI

struct SecondOnboardView: View {
    @EnvironmentObject var booksViewModel: BooksViewModel
    @State private var selectedGoal: String = ""
    
    var body: some View {
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Spacer()
                
                    Text("Quanto tempo você \n deseja por dia?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 30)
                        .multilineTextAlignment(.center)
                    
                    Rectangle()
                    .frame(width: 100, height: 2.5)
                        .foregroundColor(Color("ActionColor"))
                        .padding(.bottom, 30)
                    
                    Text("Definir um tempo diário ajuda a manter a consistência. Você pode alterar isso a qualquer momento")
                        .font(.body)
                        .fontWeight(.light)
                        .padding(.bottom, 30)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                
                
                    MenuSheetPicker(
                        title: "",
                        placeholder: "Selecione seu objetivo diário",
                        selectedValue: $selectedGoal,
                        options: booksViewModel.goalOptions,
                        formatOption: { "\($0) minutos" }
                    )
                
                    
                    Spacer()
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Text("Iniciar jornada")
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
    SecondOnboardView()
        .environmentObject(BooksViewModel())
}
