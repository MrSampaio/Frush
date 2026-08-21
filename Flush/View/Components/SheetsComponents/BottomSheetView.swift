//
//  BottomSheetView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 20/08/26.
//

import Foundation
import SwiftUI

struct BottomSheetView: View {
    

    var body: some View {
        
        NavigationStack{
            VStack(spacing: 20) {
                Text("Ação Rápida")
                    .font(.headline)
                Button("Confirmar") {
                    //showSheet = false
                }
            }
            .padding()
            .presentationDetents([.height(200)])
            .toolbar{
                BottomSheetToolbar(
                    title: "Meta diária",
                    onClose: {},
                    onEdit: {}
                )
            }
    //        .sheet(isPresented: $showSheet) {
    //
    //
    //
    //        }
            
            // .presentationDetents([.medium, .large]) -> Para em 50% ou 100%
            // .presentationDetents([.fraction(0.3)]) -> Ocupa 30% da tela
        }
    }
        
}

