//
//  SplashView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "FEF4C7"), location: 0.00),
                    .init(color: Color(hex: "FEF0B8"), location: 0.05),
                    .init(color: Color(hex: "FEE78F"), location: 0.20),
                    .init(color: Color(hex: "FEDF6C"), location: 0.35),
                    .init(color: Color(hex: "FED952"), location: 0.51),
                    .init(color: Color(hex: "FED53F"), location: 0.66),
                    .init(color: Color(hex: "FED233"), location: 0.83),
                    .init(color: Color(hex: "FFD230"), location: 1.00)
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image("FrushLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 222, height: 184)
                    .foregroundColor(Color(red: 0.15, green: 0.10, blue: 0.05))
                
            }
            .onAppear {
                SoundManager.shared.playSound(named: .splash)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: 1
        )
    }
}

#Preview {
    SplashView()
}
