//
//  ConcentricRingsView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 16/08/26.
//

import SwiftUI

struct ConcentricRingsView: View {
    var progress: Double
    private let totalRings = 5

    var body: some View {
        GeometryReader { geometry in
            let baseWidth = geometry.size.width * 0.60
            let baseHeight = geometry.size.height * 0.40

            ZStack {
                ForEach(0..<totalRings, id: \.self) { index in
                    //espaçamento entre cada anel
                    let step = CGFloat(index) * 38.0
                    let cornerRadius = 70.0 + CGFloat(index) * 16.0
                    let isAcendido = isRingActive(for: index)

                    //opacidade bem para não cansar a vista
                    let ringOpacity = isAcendido ? max(0.25, 0.7 - (Double(index) * 0.12)) : 0.08

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color("StopWatchColor1"),
                                    Color("StopWatchColor2")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: index == 0 ? 3.5 : 2.0 
                        )
                        .opacity(ringOpacity)
                        .frame(
                            width: baseWidth + (step * 2),
                            height: baseHeight + (step * 2)
                        )
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func isRingActive(for index: Int) -> Bool {
        if index == 0 { return true }
        let stepProgress = 1.0 / Double(totalRings - 1)
        let threshold = Double(index) * stepProgress
        return progress >= threshold
    }
}
