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
    
    private var rawProgress: Double {
        let target = Double(userSettingsViewModel.dailyGoal)
        guard target > 0 else { return 0 }
        return Double(userSettingsViewModel.minutesReadToday) / target
    }
    
    private var progress: Double {
        min(rawProgress, 1.0)
    }
    
    private var isGoalCompleted: Bool {
        let target = userSettingsViewModel.dailyGoal
        return target > 0 && userSettingsViewModel.minutesReadToday >= target
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: isGoalCompleted ? "checkmark.circle.fill" : "target")
                        .font(.system(.body, weight: .bold))
                        .foregroundColor(isGoalCompleted ? .action : .orange)
                    
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
                                colors: isGoalCompleted ? [.yellow, .orange] : [.yellow.opacity(0.9), .orange.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
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
                        .foregroundColor(isGoalCompleted ? .action : .orange)
                    
                    Text(isGoalCompleted ? "minutos • Meta concluída!" : "minutos de leitura hoje")
                        .font(.system(.callout))
                        .foregroundColor(isGoalCompleted ? .action.opacity(0.9) : Color("TextPagesColor"))
                }
               
                Spacer()
               
                Text("\(userSettingsViewModel.dailyGoal) min")
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
//                    .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                    LinearGradient(
                        colors: isGoalCompleted ? [.yellow, .orange] : [.white.opacity(0.3), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isGoalCompleted ? 1.0 : 0.5
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
