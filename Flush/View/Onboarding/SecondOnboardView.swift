//
//  SecondOnboardView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 17/08/26.
//
/*
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
 */

import SwiftUI

struct SecondOnboardView: View {
    @EnvironmentObject var booksViewModel: BooksViewModel
    @State private var selectedGoal: String = ""
    var onStart: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // Fundo escuro base
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            // Ilustração dos arcos no topo (supondo que seja a mesma imagem ou similar com máscara)
            Image("OnboardingOficial2")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
               
            
            // Conteúdo principal
            VStack(spacing: 20) {
                Spacer()
                
                // Título principal
                VStack(spacing: 2) {
                    Text("Defina a sua ")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .foregroundColor(.white) +
                    Text("meta")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Text("diária")
                            .font(.bitter(.bold, style: .largeTitle))
                            .foregroundColor(.white)
                        
                        Text("de leitura")
                            .font(.largeTitle)
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.top, 350)
                
                // Subtítulo com destaque amarelo
                (Text("Definir um tempo diário ajuda\nem ")
                    .foregroundColor(.white.opacity(0.85)) +
                 Text("manter a consistência")
                    .foregroundColor(Color("ProgressBar"))
                    .bold())
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                
                // Picker / Menu de Seleção
                MenuSheetPickerOnboarding(
                    title: "",
                    placeholder: "Selecione uma meta",
                    selectedValue: $selectedGoal,
                    options: booksViewModel.goalOptions,
                    formatOption: { "\($0) minutos" }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Texto informativo logo abaixo do Picker
                Text("Você pode alterar isso a qualquer momento")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Botão de ação "Iniciar jornada"
                ButtonAction(text: "Iniciar jornada") {
                    onStart?()
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 26)
            
        }
    }
}

#Preview {
    SecondOnboardView()
        .environmentObject(BooksViewModel())
}
