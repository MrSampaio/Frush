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
    
    private var progress: Double {
        guard targetPages > 0 else { return 0 }
        return min(Double(pagesReadToday) / Double(targetPages), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.system(.body, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("Meta diária de leitura")
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(.white)
                }

                Spacer()
                
                Button(action: onEditAction) {
                    Image(systemName: "pencil")
                        .font(.system(.title2))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(6)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .padding(.trailing, 0)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(targetPages)")
                    .font(.bitter(.medium, style: .largeTitle))
                    .foregroundColor(.white)
                
                Text("minutos")
                    .font(.bitter(.regular, style: .title3))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 8)
                    
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
            .padding(.bottom, 6)
            
            
            HStack {
                HStack(spacing: 4) {
                    Text("\(pagesReadToday)")
                        .font(.system(.callout))
                        .foregroundColor(.orange)
                    
                    Text("minutos de leitura hoje")
                        .font(.system(.callout))
                        .foregroundColor(Color("TextPagesColor"))
                }
                
                Spacer()
                
                Text("\(targetPages)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color("TextPagesColor"))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial) // Ou .thinMaterial / .regularMaterial
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("DailyGoalCardColor"))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
}

#Preview {
    ZStack {
        Color("BackgroundColorViews")
            .ignoresSafeArea()
        
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
