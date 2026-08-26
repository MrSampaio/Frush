//
//  SplashView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 20/08/26.
//

import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void = {}
    
    var body: some View {
        ZStack(alignment: .center){
            
            Color("SplashBackground")
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                VideoPlayerView(
                    fileName: "animation",
                    fileExtension: "mov",
                    onFinish: onFinish
                )
                .frame(width: 250, height: 200)
                
                Image("FrushLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 120)
                    .padding(.top, -40)
            }
            .padding(.bottom, 80)
        }
        .task {
            try? await Task.sleep(for: .milliseconds(500))
            SoundManager.shared.playSound(named: .splash)
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
