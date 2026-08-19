//
//  DailyGoalCard.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI

struct DailyGoalCardView: View {
    let pagesReadToday: Int
    let targetPages: Int
    var onEditAction: () -> Void
    
    // Cálculo do progresso entre 0.0 e 1.0
    private var progress: Double {
        guard targetPages > 0 else { return 0 }
        return min(Double(pagesReadToday) / Double(targetPages), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cabeçalho: Ícone, Título e Botão de Editar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("Meta diária de leitura")
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Botão de Editar (Lápis com fundo circular escuro)
                Button(action: onEditAction) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.12))
                        )
                }
            }
            
            // Valor da Meta (30 páginas)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(targetPages)")
                    .font(.bitter(.medium, style: .largeTitle))
                    
                    .foregroundColor(.white)
                
                Text("páginas")
                    .font(.bitter(.regular, style: .title3)) // Usando sua fonte Bitter ou .serif
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Barra de Progresso Customizada com Gradiente
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Trilha de fundo
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 8)
                    
                    // Progresso preenchido
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.vertical, 2)
            
            // Rodapé: Páginas lidas hoje vs Meta
            HStack {
                HStack(spacing: 4) {
                    Text("\(pagesReadToday)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("páginas lidas hoje")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text("\(targetPages)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(white: 0.12)) // Fundo escuro do card
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        DailyGoalCardView(
            pagesReadToday: 12,
            targetPages: 30,
            onEditAction: {
                print("Editar meta clicado")
            }
        )
        .padding()
    }
}
