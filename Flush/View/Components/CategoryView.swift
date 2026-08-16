//
//  CategoryView.swift
//  CH4-Books
//
//  Created by Lucas on 14/08/26.
//

import SwiftUI

struct CategoryRow: View {
    let title: String
    let hasDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(.body, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }
            .padding()
            .contentShape(Rectangle())

            if hasDivider {
                Divider()
                    .padding(.horizontal)
                    .overlay(Color.white)
            }
        }
    }
}
#Preview {
    CategoryRow(title: "Category", hasDivider: true)
}
