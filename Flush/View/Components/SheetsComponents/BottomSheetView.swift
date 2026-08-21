//
//  BottomSheetView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 20/08/26.
//

import SwiftUI

struct BottomSheetView: View {
    
    var onClose: (() -> Void)
    var onEdit: (() -> Void)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Ação Rápida")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Button("Confirmar") {
                        //showSheet = false
                    }
                }
                .padding()
            }
            .toolbar {
                BottomSheetToolbar(
                    title: "Meta diária",
                    onClose: onClose,
                    onEdit: onEdit
                )
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.fraction(0.3)])
        .presentationDragIndicator(.visible)
    }
}
