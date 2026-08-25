//
//  PulsingRingsView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 24/08/26.
//

import SwiftUI

struct PulsingRingsView: View {
    /// Pulsa quando a leitura está rodando; para quando pausada
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
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var pulse = false
    
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
        
        let local = (p - start) / slice          // 0 antes da fatia, 1 depois dela
        let clamped = min(max(local, 0), 1)
        
        return dimOpacity + clamped * (1 - dimOpacity)
    }
    
    var body: some View {
        ZStack {
            // Anéis externos — acendem um a um conforme o tempo passa
            ForEach(1...ringCount, id: \.self) { index in
                let step = CGFloat(index)
                
                Circle()
                    .stroke(ringGradient, lineWidth: lineWidth)
                    .frame(width: baseDiameter + step * 130,
                           height: baseDiameter + step * 130)
                    .opacity(opacity(forRing: index))
                    .scaleEffect(pulse ? 1.04 : 0.98)
                    .animation(
                        isAnimating
                        ? .easeInOut(duration: 2.6)
                            .repeatForever(autoreverses: true)
                            //.delay(Double(index) * 0.18)
                        : .default,
                        value: pulse
                    )
                    .animation(.easeInOut(duration: 1.0), value: timeProgress)
            }
            
            // Anel principal — sempre em 100%
            Circle()
                .stroke(ringGradient, lineWidth: lineWidth)
                .frame(width: baseDiameter, height: baseDiameter)
                .shadow(color: Color.orange.opacity(0.6), radius: 20)
                .scaleEffect(pulse ? 1.015 : 1.0)
                .animation(
                    isAnimating
                    ? .easeInOut(duration: 2.6).repeatForever(autoreverses: true)
                    : .default,
                    value: pulse
                )
        }
        .frame(width: baseDiameter + CGFloat(ringCount) * 130,
                   height: baseDiameter + CGFloat(ringCount) * 130)
        .onAppear { pulse = isAnimating }
        .onChange(of: isAnimating) { _, newValue in
            pulse = newValue
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, isAnimating else { return }
            
            // o sistema descarta o repeatForever ao ir para background;
            // reinicia o ciclo ao voltar
            pulse = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                pulse = true
            }
        }
    }
}

#Preview {
    VStack {
        PulsingRingsView(isAnimating: true, timeProgress: 0.0)
        PulsingRingsView(isAnimating: true, timeProgress: 0.5)
        PulsingRingsView(isAnimating: true, timeProgress: 1.0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color("BackgroundColorViews"))
}
