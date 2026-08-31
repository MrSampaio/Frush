//
//  PulsingRingsView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 24/08/26.
//

import SwiftUI
import Foundation

struct PulsingRingsView: View {
    /// Pulsa quando a leitura está rodando; congela quando pausada
    var isAnimating: Bool = true
    /// Diâmetro do anel principal — os demais são calculados a partir dele
    var baseDiameter: CGFloat = 360
    /// Quantidade de anéis externos
    var ringCount: Int = 3
    /// 0 = início da leitura, 1 = tempo esgotado. Acende os arcos externos em sequência.
    var timeProgress: Double = 0
    /// Espessura única para todos os arcos
    var lineWidth: CGFloat = 6
    /// Opacidade de um arco que ainda não acendeu
    var dimOpacity: Double = 0.15
    
    /// Duração de um ciclo completo de respiração, em segundos
    private let cycleDuration: Double = 2.6
    /// Distância entre um anel e o seguinte
    private let ringSpacing: CGFloat = 130
    
    private var outerDiameter: CGFloat {
        baseDiameter + CGFloat(ringCount) * ringSpacing
    }
    
    private var ringGradient: LinearGradient {
        LinearGradient(
            colors: [Color.yellow, Color.orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Cada arco externo acende dentro da sua própria fatia do tempo.
    /// Arco 1 vai de 0 a 1/n, arco 2 de 1/n a 2/n, e assim por diante.
    private func opacity(forRing index: Int) -> Double {
        let p = min(max(timeProgress, 0), 1)
        let slice = 1.0 / Double(ringCount)
        let start = Double(index - 1) * slice
        
        let local = (p - start) / slice
        let clamped = min(max(local, 0), 1)
        
        return dimOpacity + clamped * (1 - dimOpacity)
    }
    
    /// Oscila suavemente entre 0 e 1, derivado do relógio.
    /// Não guarda estado: em qualquer instante o valor é o mesmo para a mesma hora.
    private func pulsePhase(at date: Date) -> Double {
        let seconds = date.timeIntervalSinceReferenceDate
        let angle = (seconds / cycleDuration) * 2 * .pi
        return (sin(angle) + 1) / 2
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !isAnimating)) { context in
            let phase = pulsePhase(at: context.date)
            
            ZStack {
                // Anéis externos — acendem um a um conforme o tempo passa
                ForEach(1...ringCount, id: \.self) { index in
                    let step = CGFloat(index)
                    
                    Circle()
                        .stroke(ringGradient, lineWidth: lineWidth)
                        .frame(width: baseDiameter + step * ringSpacing,
                               height: baseDiameter + step * ringSpacing)
                        .opacity(opacity(forRing: index))
                        .scaleEffect(0.98 + 0.06 * phase)
                }
                
                // Anel principal — sempre em 100%
                Circle()
                    .stroke(ringGradient, lineWidth: lineWidth)
                    .frame(width: baseDiameter, height: baseDiameter)
                    .shadow(color: Color.orange.opacity(0.6), radius: 20)
                    .scaleEffect(1.0 + 0.015 * phase)
            }
            .frame(width: outerDiameter, height: outerDiameter)
        }
        .frame(width: outerDiameter, height: outerDiameter)
    }
}

#Preview {
    ZStack {
        Color("BackgroundColorViews").ignoresSafeArea()
        PulsingRingsView(isAnimating: true, timeProgress: 0.5)
    }
}
