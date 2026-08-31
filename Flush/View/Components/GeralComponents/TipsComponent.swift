//
//  TipsComponent.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 16/08/26.
//

import Foundation
import SwiftUI

struct TipsComponent: View {
    let content: String
    
    var body: some View {
        Text(content)
            .font(.caption)
           .fontWeight(.regular)
           .foregroundColor(.secondary)
           .padding(.horizontal, 5)
    }
}

#Preview {
    TipsComponent(
        content: "Tips"
    )
}
