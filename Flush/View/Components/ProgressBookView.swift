//
//  ProgressBookView.swift
//  CH4-Books
//
//  Created by Lucas on 17/08/26.
//

import SwiftUI
struct ProgressSectionView: View {
    let currentPage: Int
    let totalPages: Int
    
    var progressPercentage: Int {
        guard totalPages > 0 else { return 0 }
        let calc = (Double(currentPage) / Double(totalPages)) * 100.0
        return min(max(Int(calc), 0), 100)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(currentPage) de \(totalPages) páginas")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(progressPercentage)%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(Color.orange)
                        .frame(
                            width: geometry.size.width * (CGFloat(progressPercentage) / 100.0),
                            height: 10
                        )
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 32)
    }
}
#Preview {
    ProgressSectionView(currentPage: 10, totalPages: 100)
}
