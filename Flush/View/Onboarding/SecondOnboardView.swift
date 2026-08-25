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
import SwiftData

struct SecondOnboardView: View {
    @EnvironmentObject var booksViewModel: BooksViewModel
    var onStart: (() -> Void)? = nil
    @Environment(\.modelContext) private var modelContext
    @State private var minutosDeLeitura: Int? = nil
    
    @State private var showingZeroTimeAlert = false

    var body: some View {
        ZStack {
            Color("BackgroundColorViews")
                .ignoresSafeArea()
            
            Image("OnboardingOficial2")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
                
            VStack(spacing: 20) {
                Spacer()
                
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
                
                (Text("Definir um tempo diário ajuda\nem ")
                    .foregroundColor(.white.opacity(0.85)) +
                 Text("manter a consistência")
                    .foregroundColor(Color("ProgressBar"))
                    .bold())
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                
                MenuSheetPickerOnboarding(
                    title: "Meta Diária",
                    placeholder: "Selecione o tempo",
                    selectedTotalMinutes: $minutosDeLeitura
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Text("Você pode alterar isso a qualquer momento")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                ButtonAction(text: "Iniciar jornada", colorButton: "ActionColor"){
                    if let minutes = minutosDeLeitura, minutes > 0 {
                        print(minutes)
                        booksViewModel.saveDailyGoal(minutes: minutes, context: modelContext)
                        onStart?()
                    } else {
                        showingZeroTimeAlert = true
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 26)
            
        }
        .alert(isPresented: $showingZeroTimeAlert) {
            Alert(
                title: Text("Tempo Inválido"),
                message: Text("A meta diária precisa ser de pelo menos 1 minuto."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    SecondOnboardView()
        .environmentObject(BooksViewModel())
}
