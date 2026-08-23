//
//  DailyGoalCard.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 19/08/26.
//

import SwiftUI

struct DailyGoalCardView: View {
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    
    var onEditAction: () -> Void
    
    // puxando o progresso pela viewmodel
    private var progress: Double {
        let target = Double(userSettingsViewModel.dailyGoal)
        guard target > 0 else { return 0 }
        return min(Double(userSettingsViewModel.minutesReadToday) / target, 1.0)
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
                Text("\(userSettingsViewModel.dailyGoal)")
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
                    Text("\(userSettingsViewModel.minutesReadToday)")
                        .font(.system(.callout))
                        .foregroundColor(.orange)
                    
                    Text("minutos de leitura hoje")
                        .font(.system(.callout))
                        .foregroundColor(Color("TextPagesColor"))
                }
               
                Spacer()
                
                Text("\(userSettingsViewModel.dailyGoal)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color("TextPagesColor"))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
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
            onEditAction: {
                print("Editar meta clicado")
            }
        )
        .environmentObject(UserSettingsViewModel())
        .padding()
    }
}
